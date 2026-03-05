class TopPrediction {
  final String className;
  final double confidence;

  const TopPrediction({required this.className, required this.confidence});

  factory TopPrediction.fromJson(Map<String, dynamic> json) => TopPrediction(
        className: json['class'] as String,
        confidence: (json['confidence'] as num).toDouble(),
      );
}

class ApiDiseaseInfo {
  final String key;
  final String label;
  final String icon;
  final String severity;
  final String description;
  final String treatment;

  const ApiDiseaseInfo({
    required this.key,
    required this.label,
    required this.icon,
    required this.severity,
    required this.description,
    required this.treatment,
  });

  factory ApiDiseaseInfo.fromJson(Map<String, dynamic> json) {
    return ApiDiseaseInfo(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      icon: (json['icon'] ?? 'unknown').toString(),
      severity: (json['severity'] ?? 'unknown').toString(),
      description: (json['description'] ?? '').toString(),
      treatment: (json['treatment'] ?? '').toString(),
    );
  }
}

class PredictionResult {
  final String predictedClass;
  final double confidence;
  final List<TopPrediction> topPredictions;
  final bool isUncertain;
  final List<String> possibleClasses;
  final ApiDiseaseInfo? diseaseInfo;

  const PredictionResult({
    required this.predictedClass,
    required this.confidence,
    required this.topPredictions,
    required this.isUncertain,
    required this.possibleClasses,
    this.diseaseInfo,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final diseaseInfoMap = json['disease_info'];
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
      diseaseInfo: diseaseInfoMap is Map<String, dynamic>
          ? ApiDiseaseInfo.fromJson(diseaseInfoMap)
          : null,
    );
  }
}
