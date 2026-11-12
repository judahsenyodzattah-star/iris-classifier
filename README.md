# J’Iris

A cross-platform Flutter application for entering Iris measurements, learning about three Iris species, and saving real classification results. **No classifier or sample predictions are bundled.** Until a real model is connected, submit displays an explicit “Prediction service not connected” result with the entered measurements.

## Included

- Material 3 interface with botanical green/lavender palette, original vector-style flower illustrations, system/light/dark themes, and adaptive safe-area layouts.
- First-run, three-page onboarding stored in SharedPreferences.
- Persistent Home / Classify / History / Explore navigation and dedicated species detail pages.
- Positive finite decimal validation for all four measurements; no species-specific or arbitrary range limits.
- Search and species filtering for locally saved results; per-record deletion and confirmed clear-all.
- Local settings and history storage, with malformed history records ignored safely.
- Typed request/response models, replaceable `PredictionService`, optional confidence/probability parsing, and Dio HTTP adapter with timeouts and friendly error handling.
- Widget and unit tests for onboarding, models, request/response handling, unavailable service, and local persistence.

## Requirements and run

Install the current stable Flutter SDK with Android and/or iOS tooling configured. From this directory:

```sh
flutter pub get
flutter run
```

This source snapshot contains the application code and package configuration. Flutter platform wrapper directories (`android/` and `ios/`) are generated from the installed Flutter SDK; if they are not present in your checkout, generate them once before building:

```sh
flutter create --platforms=android,ios .
flutter pub get
```

Open the generated project in Android Studio or Xcode to configure the local SDK, signing, and simulator/device. iOS builds require macOS and Xcode.

## Checks

```sh
flutter analyze
flutter test
```

## Connect your model later

The integration boundary is `lib/services/prediction_service.dart`:

- `PredictionService.predict(PredictionRequest)` is the contract used by the UI.
- `UnavailablePredictionService` is intentionally the default and never invents a prediction.
- `DioPredictionService` posts JSON to `/predict` and parses typed, validated responses.
- `lib/core/providers.dart` selects the HTTP adapter only when `IRIS_API_BASE_URL` is supplied. It can also be replaced with a local/in-process implementation by overriding `predictionServiceProvider` in a `ProviderScope`.

Configure the base URL at run time, for example:

```sh
flutter run --dart-define=IRIS_API_BASE_URL=https://your-service.example/api
```

The adapter sends a request shaped like this (values below are **illustrative API-contract examples only**, not predictions):

```json
{
  "sepal_length": 5.1,
  "sepal_width": 3.5,
  "petal_length": 1.4,
  "petal_width": 0.2
}
```

The endpoint is `POST <base URL>/predict`. Expected response shape:

```json
{
  "species": "setosa",
  "confidence": 0.98,
  "probabilities": {
    "setosa": 0.98,
    "versicolor": 0.015,
    "virginica": 0.005
  }
}
```

`confidence` and `probabilities` are optional; when absent, the app omits them. The service accepts only `setosa`, `versicolor`, and `virginica`, and validates probability values. Adapt the URL/path or payload mapping **inside the service adapter**, not in screens. Use HTTPS for a deployed service, apply any authentication/TLS/network policies required by your deployment, and review its data handling before sending user measurements. The current app has no account, analytics, or cloud storage.

A successful response can be saved explicitly from the result screen. Unavailable/error states never enter history and never display an invented species.

## Build Android APK

After Android tooling and platform wrappers are set up:

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`. For Play Store distribution, configure signing and use `flutter build appbundle --release`.

## Source layout

```text
lib/
  app/                 app root, GoRouter, theme
  core/models/         measurements, prediction contract, history record
  core/storage/        SharedPreferences-backed local store
  core/widgets/        reusable original flower art and controls
  features/screens.dart onboarding, shell, home, classify, result,
                       history, species guide, and settings
  services/            replaceable prediction adapters
  main.dart
```

The Iris drawings are original lightweight Flutter canvas illustrations; no remote images or image licenses are needed. Species summaries are concise general botanical descriptions; natural traits vary across populations and cultivars.
