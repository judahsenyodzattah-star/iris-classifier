from __future__ import annotations

import math
import os
import re
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Any

import joblib
import numpy as np
from fastapi import FastAPI, HTTPException, Request, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ConfigDict, Field, field_validator


FEATURES = ("sepal_length", "sepal_width", "petal_length", "petal_width")
SPECIES = ("setosa", "versicolor", "virginica")
DEFAULT_MODEL_PATH = Path(__file__).with_name("iris_knn_model.pkl")


class PredictionInput(BaseModel):
    model_config = ConfigDict(extra="forbid")

    sepal_length: float = Field(gt=0)
    sepal_width: float = Field(gt=0)
    petal_length: float = Field(gt=0)
    petal_width: float = Field(gt=0)

    @field_validator("sepal_length", "sepal_width", "petal_length", "petal_width", mode="before")
    @classmethod
    def require_json_number(cls, value: Any) -> float:
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise ValueError("measurement must be a numeric JSON value")
        number = float(value)
        if not math.isfinite(number):
            raise ValueError("measurement must be finite")
        return number


class PredictionOutput(BaseModel):
    species: str
    confidence: float = Field(ge=0, le=1)
    probabilities: dict[str, float]


class ModelCompatibilityError(RuntimeError):
    """Raised when the pickle cannot satisfy the API contract."""


def _normalise_name(value: Any) -> str:
    return re.sub(r"[^a-z0-9]", "", str(value).lower())


def _species_for_label(label: Any) -> str:
    if isinstance(label, (int, np.integer)) and int(label) in range(3):
        return SPECIES[int(label)]
    normalised = _normalise_name(label)
    for species in SPECIES:
        if normalised == species or normalised.endswith(species):
            return species
    raise ModelCompatibilityError(
        f"Model class {label!r} is not one of setosa, versicolor, or virginica"
    )


def _fitted_feature_names(model: Any) -> list[str] | None:
    names = getattr(model, "feature_names_in_", None)
    if names is None and hasattr(model, "named_steps"):
        names = getattr(model, "feature_names_in_", None)
    if names is None:
        return None
    names = [str(name) for name in names]
    if len(names) != len(FEATURES):
        raise ModelCompatibilityError(
            f"Model expects {len(names)} named features; expected exactly four Iris measurements"
        )
    return names


class IrisModel:
    def __init__(self, model: Any, path: Path):
        self.model = model
        self.path = path
        self.feature_names = _fitted_feature_names(model)
        if not callable(getattr(model, "predict", None)):
            raise ModelCompatibilityError("Pickle does not contain a predict-capable model or pipeline")
        if not callable(getattr(model, "predict_proba", None)):
            raise ModelCompatibilityError("KNN model must expose predict_proba()")
        classes = getattr(model, "classes_", None)
        if classes is None:
            raise ModelCompatibilityError("Model must expose classes_ for probability mapping")
        self.class_species = [_species_for_label(label) for label in classes]
        if set(self.class_species) != set(SPECIES) or len(self.class_species) != 3:
            raise ModelCompatibilityError("Model must contain exactly the three Iris species classes")

    def _features(self, values: dict[str, float]) -> Any:
        ordered = [values[name] for name in FEATURES]
        if self.feature_names is None:
            return np.asarray([ordered], dtype=float)

        by_normalised_name = {_normalise_name(name): name for name in FEATURES}
        row: dict[str, float] = {}
        for fitted_name in self.feature_names:
            canonical = by_normalised_name.get(_normalise_name(fitted_name))
            if canonical is None:
                raise ModelCompatibilityError(
                    f"Cannot map fitted feature {fitted_name!r} to the four API measurements"
                )
            row[fitted_name] = values[canonical]
        try:
            import pandas as pd
        except ImportError as exc:
            raise ModelCompatibilityError(
                "This named-column model requires pandas; export an array-trained pipeline or install pandas"
            ) from exc
        return pd.DataFrame([row], columns=self.feature_names)

    def predict(self, values: dict[str, float]) -> PredictionOutput:
        features = self._features(values)
        predicted_label = self.model.predict(features)[0]
        predicted_species = _species_for_label(predicted_label)
        scores = np.asarray(self.model.predict_proba(features)[0], dtype=float)
        if len(scores) != len(self.class_species) or not np.all(np.isfinite(scores)):
            raise ModelCompatibilityError("Model returned invalid probability scores")
        probabilities = dict.fromkeys(SPECIES, 0.0)
        for species, score in zip(self.class_species, scores, strict=True):
            if score < 0 or score > 1:
                raise ModelCompatibilityError("Model returned a probability outside 0..1")
            probabilities[species] = float(score)
        return PredictionOutput(
            species=predicted_species,
            confidence=probabilities[predicted_species],
            probabilities=probabilities,
        )


def load_model(path: Path) -> IrisModel:
    if not path.is_file():
        raise FileNotFoundError(
            f"Model file not found at {path}. Export the complete fitted scikit-learn Pipeline, "
            "including preprocessing and the KNN classifier, to this path."
        )
    try:
        model = joblib.load(path)
    except Exception as exc:
        raise ModelCompatibilityError(
            "Could not load the pickle. Use the same Python/scikit-learn environment used to export it, "
            "then re-export the complete fitted pipeline."
        ) from exc
    return IrisModel(model, path)


def _model_path(override: str | None = None) -> Path:
    value = override or os.getenv("IRIS_MODEL_PATH")
    return Path(value).expanduser().resolve() if value else DEFAULT_MODEL_PATH


@asynccontextmanager
async def lifespan(app: FastAPI):
    path = _model_path(getattr(app.state, "model_path_override", None))
    try:
        app.state.iris_model = load_model(path)
        app.state.model_error = None
    except (FileNotFoundError, ModelCompatibilityError) as exc:
        app.state.iris_model = None
        app.state.model_error = str(exc)
    yield


def create_app(model_path: str | Path | None = None) -> FastAPI:
    app = FastAPI(title="Iris Classifier API", version="1.0.0", lifespan=lifespan)
    app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        origin.strip()
        for origin in os.getenv("CORS_ORIGINS", "").split(",")
        if origin.strip()
    ],
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["*"]
)
    
    if model_path is not None:
        app.state.model_path_override = str(model_path)

    @app.get("/health")
    def health(request: Request) -> dict[str, Any]:
        if getattr(request.app.state, "iris_model", None) is None:
            raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=request.app.state.model_error)
        return {"status": "ok", "model_loaded": True}

    @app.post("/predict", response_model=PredictionOutput)
    def predict(payload: PredictionInput, request: Request) -> PredictionOutput:
        model = getattr(request.app.state, "iris_model", None)
        if model is None:
            raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=request.app.state.model_error)
        try:
            return model.predict(payload.model_dump())
        except ModelCompatibilityError as exc:
            raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=str(exc)) from exc

    return app


app = create_app()
