import '../../app/core/core_i18n.dart';

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
  static const _dbEn = {
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

  static const _dbKh = {
    'healthy': DiseaseInfo(
      key: 'healthy',
      label: 'សុខភាពល្អ',
      icon: '✅',
      severity: 'none',
      description: 'ស្លឹកមានសុខភាពល្អ។ បន្តថែទាំធម្មតា និងពិនិត្យជារៀងរាល់សប្តាហ៍។',
      treatment: 'ថ្ងៃនេះ: រក្សាការស្រោចទឹកដដែល។ សប្តាហ៍នេះ: បន្តដាក់ជីសមស្រប និងតាមដានស្រែ។',
    ),
    'bacterial_leaf_blight': DiseaseInfo(
      key: 'bacterial_leaf_blight',
      label: 'រលាកស្លឹកបាក់តេរី',
      icon: '🦠',
      severity: 'high',
      description: 'សង្ស័យជំងឺរលាកស្លឹកបាក់តេរី។ គែមស្លឹកលឿង ហើយស្ងួតលឿន។',
      treatment:
          'ថ្ងៃនេះ: ដកស្លឹកដែលឆ្លងខ្លាំង និងកែលម្អការបង្ហូរទឹក។ បាញ់ថ្នាំប្រភេទស្ពាន់តាមការណែនាំមូលដ្ឋាន។',
    ),
    'leaf_blast': DiseaseInfo(
      key: 'leaf_blast',
      label: 'ជំងឺប្លាស',
      icon: '💥',
      severity: 'high',
      description: 'សង្ស័យជំងឺប្លាស។ ស្នាមមានកណ្ដាលប្រផេះ និងគែមងងឹត។',
      treatment:
          'ថ្ងៃនេះ: ជៀសវាងជីនីត្រូសែនលើស។ បន្ទាប់មកប្រើថ្នាំកម្ចាត់ផ្សិតសមស្របតាមការណែនាំអ្នកជំនាញ។',
    ),
    'brown_spot': DiseaseInfo(
      key: 'brown_spot',
      label: 'ចំណុចត្នោត',
      icon: '🟤',
      severity: 'medium',
      description: 'សង្ស័យជំងឺចំណុចត្នោត។ ចំណុចអូវ៉ាល់អាចរាលដាលលើដំណាំខ្សោយ។',
      treatment:
          'សប្តាហ៍នេះ: កែលម្អការដាក់ជីឱ្យសមតុល្យ (ជាពិសេសប៉ូតាស្យូម) ហើយប្រើថ្នាំបង្ការផ្សិតបើរាលដាលខ្លាំង។',
    ),
    'leaf_scald': DiseaseInfo(
      key: 'leaf_scald',
      label: 'ដំបៅស្លឹក',
      icon: '🔥',
      severity: 'medium',
      description: 'សង្ស័យដំបៅស្លឹក។ ខូចខាតភាគច្រើនចាប់ផ្តើមពីចុងស្លឹកចុះក្រោម។',
      treatment:
          'ថ្ងៃនេះ: កែលម្អខ្យល់ចេញចូលរវាងដើម។ ប្រើថ្នាំសមស្រប និងជៀសវាងជីនីត្រូសែនលើស។',
    ),
    'narrow_brown_spot': DiseaseInfo(
      key: 'narrow_brown_spot',
      label: 'ចំណុចត្នោតចង្អៀត',
      icon: '🟫',
      severity: 'low',
      description: 'សង្ស័យចំណុចត្នោតចង្អៀត។ ជាទូទៅស្រាល ប៉ុន្តែត្រូវតាមដាន។',
      treatment:
          'តាមដានរយៈពេល ៣-៥ ថ្ងៃ។ រក្សាអាហារូបត្ថម្ភ និងទឹកឱ្យសមស្រប។ បាញ់ថ្នាំតែពេលរាលដាលលឿន។',
    ),
  };

  static DiseaseInfo info(String key) {
    final db = AppText.isKhmer ? _dbKh : _dbEn;
    return db[key] ??
        DiseaseInfo(
          key: key,
          label: key.replaceAll('_', ' '),
          icon: '🌾',
          severity: 'unknown',
          description: '',
          treatment: '',
        );
  }
}
