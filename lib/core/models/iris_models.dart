import 'dart:convert';

class Measurements {
  const Measurements({required this.sepalLength, required this.sepalWidth, required this.petalLength, required this.petalWidth});
  final double sepalLength, sepalWidth, petalLength, petalWidth;

  Map<String, dynamic> toJson() => {
    'sepal_length': sepalLength, 'sepal_width': sepalWidth,
    'petal_length': petalLength, 'petal_width': petalWidth,
  };

  factory Measurements.fromJson(Map<String, dynamic> json) => Measurements(
    sepalLength: _number(json['sepal_length']), sepalWidth: _number(json['sepal_width']),
    petalLength: _number(json['petal_length']), petalWidth: _number(json['petal_width']),
  );

  static double _number(dynamic value) {
    final n = value is num ? value.toDouble() : double.tryParse('$value');
    if (n == null || !n.isFinite || n <= 0) throw const FormatException('Measurements must be finite positive numbers.');
    return n;
  }
}

class PredictionRequest {
  const PredictionRequest(this.measurements);
  final Measurements measurements;
  Map<String, dynamic> toJson() => measurements.toJson();
}

class PredictionResponse {
  const PredictionResponse({required this.species, this.confidence, this.probabilities});
  final String species;
  final double? confidence;
  final Map<String, double>? probabilities;
  static const supportedSpecies = {'setosa', 'versicolor', 'virginica'};

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    final species = json['species'];
    if (species is! String || !supportedSpecies.contains(species.toLowerCase())) {
      throw const FormatException('Unsupported species identifier.');
    }
    final confidence = json['confidence'];
    final parsedConfidence = confidence == null ? null : _probability(confidence);
    Map<String, double>? parsed;
    final raw = json['probabilities'];
    if (raw != null) {
      if (raw is! Map) throw const FormatException('Invalid probabilities.');
      parsed = {};
      for (final entry in raw.entries) {
        final key = entry.key.toString().toLowerCase();
        if (!supportedSpecies.contains(key)) throw const FormatException('Unsupported probability species.');
        parsed[key] = _probability(entry.value);
      }
    }
    return PredictionResponse(species: species.toLowerCase(), confidence: parsedConfidence, probabilities: parsed);
  }

  static double _probability(dynamic value) {
    final n = value is num ? value.toDouble() : double.tryParse('$value');
    if (n == null || !n.isFinite || n < 0 || n > 1) throw const FormatException('Probability must be between zero and one.');
    return n;
  }
}

class HistoryRecord {
  const HistoryRecord({required this.id, required this.species, required this.measurements, required this.createdAt, this.confidence, this.probabilities});
  final String id, species;
  final Measurements measurements;
  final DateTime createdAt;
  final double? confidence;
  final Map<String, double>? probabilities;

  Map<String, dynamic> toJson() => {
    'id': id, 'species': species, 'measurements': measurements.toJson(),
    'created_at': createdAt.toIso8601String(), 'confidence': confidence, 'probabilities': probabilities,
  };
  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    final species = (json['species'] as String).toLowerCase();
    if (!PredictionResponse.supportedSpecies.contains(species)) throw const FormatException('Unsupported history species.');
    final confidenceValue = json['confidence'];
    final confidence = confidenceValue == null ? null : PredictionResponse._probability(confidenceValue);
    final rawProbabilities = json['probabilities'] as Map?;
    final probabilities = rawProbabilities?.map((key, value) {
      final name = key.toString().toLowerCase();
      if (!PredictionResponse.supportedSpecies.contains(name)) throw const FormatException('Unsupported history probability species.');
      return MapEntry(name, PredictionResponse._probability(value));
    });
    return HistoryRecord(
      id: json['id'] as String, species: species,
      measurements: Measurements.fromJson(Map<String, dynamic>.from(json['measurements'] as Map)),
      createdAt: DateTime.parse(json['created_at'] as String), confidence: confidence, probabilities: probabilities,
    );
  }
  String encode() => jsonEncode(toJson());
}

String speciesTitle(String id) => switch (id.toLowerCase()) {
  'setosa' => 'Iris setosa', 'versicolor' => 'Iris versicolor', 'virginica' => 'Iris virginica', _ => 'Unknown Iris',
};
