class TopPrediction {
  final String className;
  final double confidence;

  const TopPrediction({required this.className, required this.confidence});

  factory TopPrediction.fromJson(Map<String, dynamic> json) => TopPrediction(
    className: json['class'] as String,
    confidence: (json['confidence'] as num).toDouble(),
  );
}

class DiseaseInfo {
  final String key;
  final String label;
  final String icon;
  final String severity; // none | low | medium | high
  final String description;
  final String treatment;

  const DiseaseInfo({
    required this.key,
    required this.label,
    required this.icon,
    required this.severity,
    required this.description,
    required this.treatment,
  });
}

class PredictionResult {
  final String predictedClass;
  final double confidence;
  final List<TopPrediction> topPredictions;
  final DiseaseInfo info;
  final bool isUncertain;
  final List<String> possibleClasses;

  const PredictionResult({
    required this.predictedClass,
    required this.confidence,
    required this.topPredictions,
    required this.info,
    required this.isUncertain,
    required this.possibleClasses,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final cls = json['predicted_class'] as String;
    return PredictionResult(
      predictedClass: cls,
      confidence: (json['confidence'] as num).toDouble(),
      topPredictions: (json['top_predictions'] as List)
          .map((e) => TopPrediction.fromJson(e as Map<String, dynamic>))
          .toList(),
      info: DiseaseDatabase.info(cls),
      isUncertain: json['is_uncertain'] == true,
      possibleClasses: (json['possible_classes'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

/// Static disease knowledge base
class DiseaseDatabase {
  static const _db = {
    'healthy': DiseaseInfo(
      key: 'healthy',
      label: 'Healthy',
      icon: '✅',
      severity: 'none',
      description:
          'Leaf looks healthy. Continue normal care and weekly checks.',
      treatment:
          'Today: keep current irrigation. This week: continue balanced fertilizer and monitor field.',
    ),
    'bacterial_leaf_blight': DiseaseInfo(
      key: 'bacterial_leaf_blight',
      label: 'Bacterial Leaf Blight',
      icon: '🦠',
      severity: 'high',
      description:
          'Likely bacterial blight. Leaf edges turn yellow then dry quickly.',
      treatment:
          'Today: remove heavily infected leaves, improve drainage. Next spray: copper-based bactericide as advised locally.',
    ),
    'leaf_blast': DiseaseInfo(
      key: 'leaf_blast',
      label: 'Leaf Blast',
      icon: '💥',
      severity: 'high',
      description:
          'Likely leaf blast. Lesions are gray center with dark border.',
      treatment:
          'Today: avoid extra nitrogen. Next spray: recommended blast fungicide from local agronomy shop.',
    ),
    'brown_spot': DiseaseInfo(
      key: 'brown_spot',
      label: 'Brown Spot',
      icon: '🟤',
      severity: 'medium',
      description:
          'Likely brown spot. Oval brown patches may spread in weak plants.',
      treatment:
          'This week: improve balanced fertilizer (especially potassium). Use suitable fungicide if spread increases.',
    ),
    'leaf_scald': DiseaseInfo(
      key: 'leaf_scald',
      label: 'Leaf Scald',
      icon: '🔥',
      severity: 'medium',
      description:
          'Likely leaf scald. Damage often starts from leaf tips downward.',
      treatment:
          'Today: improve spacing/airflow if possible. Apply suitable fungicide and avoid excess nitrogen.',
    ),
    'narrow_brown_spot': DiseaseInfo(
      key: 'narrow_brown_spot',
      label: 'Narrow Brown Spot',
      icon: '🟫',
      severity: 'low',
      description:
          'Likely narrow brown spot. Usually mild but should be monitored.',
      treatment:
          'Monitor for 3-5 days. Keep balanced nutrition and water. Spray only if symptoms spread quickly.',
    ),
  };

  static DiseaseInfo info(String key) =>
      _db[key] ??
      DiseaseInfo(
        key: key,
        label: key.replaceAll('_', ' '),
        icon: '🌾',
        severity: 'unknown',
        description: '',
        treatment: '',
      );
}
