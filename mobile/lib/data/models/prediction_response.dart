class TopPrediction {
  final String className;
  final double confidence;

  const TopPrediction({required this.className, required this.confidence});

  factory TopPrediction.fromJson(Map<String, dynamic> json) => TopPrediction(
        className: json['class'] as String,
        confidence: (json['confidence'] as num).toDouble(),
      );
}

class PredictionResult {
  final String predictedClass;
  final double confidence;
  final List<TopPrediction> topPredictions;
  final bool isUncertain;
  final List<String> possibleClasses;

  const PredictionResult({
    required this.predictedClass,
    required this.confidence,
    required this.topPredictions,
    required this.isUncertain,
    required this.possibleClasses,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      predictedClass: json['predicted_class'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      topPredictions: (json['top_predictions'] as List<dynamic>)
          .map((e) => TopPrediction.fromJson(e as Map<String, dynamic>))
          .toList(),
      isUncertain: json['is_uncertain'] == true,
      possibleClasses: (json['possible_classes'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
