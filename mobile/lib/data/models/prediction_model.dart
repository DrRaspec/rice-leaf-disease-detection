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

  const PredictionResult({
    required this.predictedClass,
    required this.confidence,
    required this.topPredictions,
    required this.info,
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
          'No disease detected. Your rice plant appears to be in excellent health.',
      treatment:
          'Continue regular monitoring, proper irrigation and balanced fertilization.',
    ),
    'bacterial_leaf_blight': DiseaseInfo(
      key: 'bacterial_leaf_blight',
      label: 'Bacterial Leaf Blight',
      icon: '🦠',
      severity: 'high',
      description:
          'Caused by Xanthomonas oryzae pv. oryzae. Yellowing and drying of leaf margins.',
      treatment:
          'Apply copper-based bactericides. Improve field drainage. Use resistant varieties.',
    ),
    'leaf_blast': DiseaseInfo(
      key: 'leaf_blast',
      label: 'Leaf Blast',
      icon: '💥',
      severity: 'high',
      description:
          'Caused by Magnaporthe oryzae. Diamond-shaped gray lesions. Most destructive rice disease worldwide.',
      treatment:
          'Apply tricyclazole or isoprothiolane. Reduce nitrogen application.',
    ),
    'brown_spot': DiseaseInfo(
      key: 'brown_spot',
      label: 'Brown Spot',
      icon: '🟤',
      severity: 'medium',
      description:
          'Fungal disease causing oval brown spots with yellow halos. Associated with nutritional deficiencies.',
      treatment:
          'Apply fungicides (iprodione, propiconazole). Ensure balanced K fertilization.',
    ),
    'leaf_scald': DiseaseInfo(
      key: 'leaf_scald',
      label: 'Leaf Scald',
      icon: '🔥',
      severity: 'medium',
      description:
          'Caused by Microdochium oryzae. Scalded light-brown lesions from leaf tip downward.',
      treatment:
          'Apply propiconazole fungicide. Avoid excessive nitrogen. Improve air circulation.',
    ),
    'narrow_brown_spot': DiseaseInfo(
      key: 'narrow_brown_spot',
      label: 'Narrow Brown Spot',
      icon: '🟫',
      severity: 'low',
      description:
          'Caused by Cercospora janseana. Narrow brown linear spots on leaf blade.',
      treatment:
          'Apply mancozeb or carbendazim. Maintain balanced nutrition. Avoid water stress.',
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
