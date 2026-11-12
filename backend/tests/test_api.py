from pathlib import Path

import joblib
import numpy as np
import pytest
from fastapi.testclient import TestClient
from sklearn.datasets import load_iris
from sklearn.neighbors import KNeighborsClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

from backend.main import create_app


@pytest.fixture()
def model_path(tmp_path: Path) -> Path:
    iris = load_iris()
    labels = np.asarray([("setosa", "versicolor", "virginica")[value] for value in iris.target])
    pipeline = Pipeline([("scaler", StandardScaler()), ("knn", KNeighborsClassifier(n_neighbors=3))])
    pipeline.fit(iris.data, labels)
    path = tmp_path / "iris_knn_model.pkl"
    joblib.dump(pipeline, path)
    return path


def test_startup_and_health(model_path: Path) -> None:
    with TestClient(create_app(model_path)) as client:
        response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "model_loaded": True}


def test_missing_model_reports_unavailable(tmp_path: Path) -> None:
    with TestClient(create_app(tmp_path / "missing.pkl")) as client:
        health = client.get("/health")
        prediction = client.post(
            "/predict",
            json={"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2},
        )
    assert health.status_code == 503
    assert prediction.status_code == 503
    assert "Model file not found" in health.json()["detail"]


@pytest.mark.parametrize(
    "payload",
    [
        {"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4},
        {"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2, "extra": 1},
        {"sepal_length": "5.1", "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2},
        {"sepal_length": 0, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2},
    ],
)
def test_invalid_requests_are_422(model_path: Path, payload: dict) -> None:
    with TestClient(create_app(model_path)) as client:
        response = client.post("/predict", json=payload)
    assert response.status_code == 422


def test_prediction_matches_direct_pipeline_call(model_path: Path) -> None:
    pipeline = joblib.load(model_path)
    values = np.asarray([[5.1, 3.5, 1.4, 0.2]])
    expected_label = pipeline.predict(values)[0]
    expected_scores = pipeline.predict_proba(values)[0]
    expected_classes = pipeline.classes_

    with TestClient(create_app(model_path)) as client:
        response = client.post(
            "/predict",
            json={"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2},
        )
    body = response.json()
    assert response.status_code == 200
    assert body["species"] == expected_label
    assert body["confidence"] == body["probabilities"][body["species"]]
    assert body["probabilities"] == {
        str(label): pytest.approx(float(score)) for label, score in zip(expected_classes, expected_scores, strict=True)
    }
