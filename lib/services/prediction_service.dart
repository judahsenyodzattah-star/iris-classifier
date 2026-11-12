import 'package:dio/dio.dart';
import '../core/models/iris_models.dart';

/// Replace this service with your model/API adapter. Screens depend only on this contract.
abstract interface class PredictionService {
  Future<PredictionResponse> predict(PredictionRequest request);
}

class PredictionUnavailableException implements Exception {
  const PredictionUnavailableException([this.message = 'Prediction service not connected.']);
  final String message;
  @override
  String toString() => message;
}

/// Safe default: no prediction is fabricated. Replace when a real model is available.
class UnavailablePredictionService implements PredictionService {
  const UnavailablePredictionService();
  @override
  Future<PredictionResponse> predict(PredictionRequest request) async => throw const PredictionUnavailableException();
}

/// Ready-to-configure HTTP adapter. Set IRIS_API_BASE_URL using --dart-define.
class DioPredictionService implements PredictionService {
  DioPredictionService({required String baseUrl, Dio? dio}) : _dio = dio ?? Dio(BaseOptions(
    baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ));
  final Dio _dio;
  @override
  Future<PredictionResponse> predict(PredictionRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/predict', data: request.toJson());
      if (response.data == null) throw const FormatException('Empty prediction response.');
      return PredictionResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw PredictionUnavailableException(e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout
        ? 'The prediction service took too long. Please try again.'
        : 'Could not reach the prediction service. Check your connection and try again.');
    } on FormatException {
      throw const PredictionUnavailableException('The prediction service returned an invalid response.');
    }
  }
}
