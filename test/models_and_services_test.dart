import 'package:flutter_test/flutter_test.dart';
import 'package:iris_classifier/core/models/iris_models.dart';
import 'package:iris_classifier/services/prediction_service.dart';

void main() {
  const measurements = Measurements(
      sepalLength: 5.1, sepalWidth: 3.5, petalLength: 1.4, petalWidth: 0.2);
  test('prediction request uses documented snake_case API keys', () {
    expect(const PredictionRequest(measurements).toJson(), {
      'sepal_length': 5.1,
      'sepal_width': 3.5,
      'petal_length': 1.4,
      'petal_width': 0.2
    });
  });
  test('response parses optional confidence and class probabilities', () {
    final response = PredictionResponse.fromJson({
      'species': 'setosa',
      'confidence': 0.98,
      'probabilities': {'setosa': 0.98, 'versicolor': 0.015, 'virginica': 0.005}
    });
    expect(response.species, 'setosa');
    expect(response.confidence, 0.98);
    expect(response.probabilities!['virginica'], 0.005);
  });
  test('response rejects an unsupported species and invalid probabilities', () {
    expect(() => PredictionResponse.fromJson({'species': 'rose'}),
        throwsFormatException);
    expect(
        () =>
            PredictionResponse.fromJson({'species': 'setosa', 'confidence': 2}),
        throwsFormatException);
  });
  test('measurement model rejects missing, non-finite, and non-positive values',
      () {
    expect(
        () => Measurements.fromJson({
              'sepal_length': 0,
              'sepal_width': 2,
              'petal_length': 2,
              'petal_width': 1
            }),
        throwsFormatException);
    expect(
        () => Measurements.fromJson({
              'sepal_length': 'NaN',
              'sepal_width': 2,
              'petal_length': 2,
              'petal_width': 1
            }),
        throwsFormatException);
  });
  test('default service returns explicit unavailable rather than a fake result',
      () async {
    expect(
        const UnavailablePredictionService()
            .predict(const PredictionRequest(measurements)),
        throwsA(isA<PredictionUnavailableException>()));
  });
}
