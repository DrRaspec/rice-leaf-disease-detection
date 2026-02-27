import '../../../app/core/core_i18n.dart';

class DiseaseInfo {
  final String key;
  final String label;
  final String icon;
  final String severity;
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

class DiseaseInfoCatalog {
  static const _en = {
    'healthy': DiseaseInfo(
      key: 'healthy',
      label: 'Healthy',
      icon: '🌿',
      severity: 'none',
      description: 'Leaf looks healthy. Continue normal care and weekly checks.',
      treatment:
          'Keep irrigation and balanced fertilization. Continue monitoring.',
    ),
    'bacterial_leaf_blight': DiseaseInfo(
      key: 'bacterial_leaf_blight',
      label: 'Bacterial Leaf Blight',
      icon: '🦠',
      severity: 'high',
      description: 'Leaf edges yellow and dry quickly.',
      treatment:
          'Remove heavily infected leaves and improve drainage. Use approved bactericide.',
    ),
    'leaf_blast': DiseaseInfo(
      key: 'leaf_blast',
      label: 'Leaf Blast',
      icon: '💥',
      severity: 'high',
      description: 'Gray-centered lesions with dark borders.',
      treatment:
          'Avoid excess nitrogen and apply recommended fungicide for blast.',
    ),
    'brown_spot': DiseaseInfo(
      key: 'brown_spot',
      label: 'Brown Spot',
      icon: '🟤',
      severity: 'medium',
      description: 'Oval brown spots, sometimes with yellow halo.',
      treatment:
          'Improve balanced nutrition (especially potassium) and monitor spread.',
    ),
    'leaf_scald': DiseaseInfo(
      key: 'leaf_scald',
      label: 'Leaf Scald',
      icon: '🔥',
      severity: 'medium',
      description: 'Scald-like brown lesions often starting from tips.',
      treatment:
          'Improve airflow and apply suitable fungicide if symptoms progress.',
    ),
    'narrow_brown_spot': DiseaseInfo(
      key: 'narrow_brown_spot',
      label: 'Narrow Brown Spot',
      icon: '🟫',
      severity: 'low',
      description: 'Narrow linear lesions on the leaf blade.',
      treatment:
          'Monitor for a few days and spray only if disease spreads rapidly.',
    ),
  };

  static const _km = {
    'healthy': DiseaseInfo(
      key: 'healthy',
      label: 'Healthy',
      icon: '🌿',
      severity: 'none',
      description: 'Leaf looks healthy. Continue normal care and weekly checks.',
      treatment:
          'Keep irrigation and balanced fertilization. Continue monitoring.',
    ),
    'bacterial_leaf_blight': DiseaseInfo(
      key: 'bacterial_leaf_blight',
      label: 'Bacterial Leaf Blight',
      icon: '🦠',
      severity: 'high',
      description: 'Leaf edges yellow and dry quickly.',
      treatment:
          'Remove heavily infected leaves and improve drainage. Use approved bactericide.',
    ),
    'leaf_blast': DiseaseInfo(
      key: 'leaf_blast',
      label: 'Leaf Blast',
      icon: '💥',
      severity: 'high',
      description: 'Gray-centered lesions with dark borders.',
      treatment:
          'Avoid excess nitrogen and apply recommended fungicide for blast.',
    ),
    'brown_spot': DiseaseInfo(
      key: 'brown_spot',
      label: 'Brown Spot',
      icon: '🟤',
      severity: 'medium',
      description: 'Oval brown spots, sometimes with yellow halo.',
      treatment:
          'Improve balanced nutrition (especially potassium) and monitor spread.',
    ),
    'leaf_scald': DiseaseInfo(
      key: 'leaf_scald',
      label: 'Leaf Scald',
      icon: '🔥',
      severity: 'medium',
      description: 'Scald-like brown lesions often starting from tips.',
      treatment:
          'Improve airflow and apply suitable fungicide if symptoms progress.',
    ),
    'narrow_brown_spot': DiseaseInfo(
      key: 'narrow_brown_spot',
      label: 'Narrow Brown Spot',
      icon: '🟫',
      severity: 'low',
      description: 'Narrow linear lesions on the leaf blade.',
      treatment:
          'Monitor for a few days and spray only if disease spreads rapidly.',
    ),
  };

  static DiseaseInfo byClass(String key) {
    final db = AppText.isKhmer ? _km : _en;
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
