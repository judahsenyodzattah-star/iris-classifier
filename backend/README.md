# Iris Classifier API

This backend implements the Flutter app's existing `DioPredictionService` contract:

- `GET /health`
- `POST /predict`
- request fields: `sepal_length`, `sepal_width`, `petal_length`, `petal_width` in centimeters
- response fields: `species`, `confidence`, and `probabilities`

## Install and run

From the Flutter project root:

```powershell
..\.venv\Scripts\python.exe -m pip install -r backend\requirements.txt
..\.venv\Scripts\python.exe -m uvicorn backend.main:app --host 0.0.0.0 --port 8000
```

The Flutter project root is `IrisClassifier-source\iris_classifier`, not its parent workspace. If your terminal is currently at `IrisClassifier-source`, use either:

```powershell
cd .\iris_classifier
& ..\.venv\Scripts\python.exe -m uvicorn backend.main:app --reload
```

or keep the parent directory as the working directory and set the application directory explicitly:

```powershell
& .\.venv\Scripts\python.exe -m uvicorn backend.main:app --app-dir .\iris_classifier --reload
```

Place the trusted export at `backend/iris_knn_model.pkl`, or override it:

```powershell
$env:IRIS_MODEL_PATH = 'C:\path\to\iris_knn_model.pkl'
..\.venv\Scripts\python.exe -m uvicorn backend.main:app --host 0.0.0.0 --port 8000
```

The pickle must be the complete fitted scikit-learn pipeline, including preprocessing and the KNN classifier. The API passes raw centimeter measurements to that pipeline. If the pickle contains only a classifier, re-export the pipeline from the notebook, for example:

```python
from joblib import dump
dump(fitted_pipeline, "backend/iris_knn_model.pkl")
```

The checked-in pins are a Python 3.14-compatible baseline for this development environment, but the model export takes precedence: use the same Python, NumPy, joblib, pandas (if named columns are used), and scikit-learn versions used to create the pickle. If the model was trained with named columns, the backend maps common names such as `sepal length (cm)` in the pipeline's fitted order.

## Example request

```powershell
Invoke-RestMethod http://127.0.0.1:8000/predict -Method Post -ContentType 'application/json' -Body '{"sepal_length":5.1,"sepal_width":3.5,"petal_length":1.4,"petal_width":0.2}'
```

Expected shape:

```json
{"species":"setosa","confidence":0.98,"probabilities":{"setosa":0.98,"versicolor":0.01,"virginica":0.01}}
```

## Connect Flutter

The checked-out app already uses `IRIS_API_BASE_URL` and posts to `/predict`:

```powershell
flutter run --dart-define=IRIS_API_BASE_URL=http://127.0.0.1:8000
```

For Chrome, the API enables localhost/127.0.0.1 CORS for local development. For the Android emulator, use the host loopback alias:

```powershell
flutter run --dart-define=IRIS_API_BASE_URL=http://10.0.2.2:8000
```

For a physical phone, put the phone and computer on the same network, find the computer's LAN address, and use it:

```powershell
flutter run --dart-define=IRIS_API_BASE_URL=http://192.168.1.10:8000
```

The debug Android manifest permits local cleartext HTTP. Allow inbound TCP port 8000 through the development machine firewall. Use HTTPS and authentication outside a trusted local network; do not carry the debug cleartext setting into a production build.
