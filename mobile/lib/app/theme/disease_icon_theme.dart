import 'package:flutter/material.dart';

class DiseaseIconTheme {
  static IconData data(String key) {
    return switch (key) {
      'healthy' => Icons.verified_rounded,
      'bacterial_leaf_blight' => Icons.bug_report_rounded,
      'leaf_blast' => Icons.bolt_rounded,
      'brown_spot' => Icons.trip_origin_rounded,
      'leaf_scald' => Icons.local_fire_department_rounded,
      'narrow_brown_spot' => Icons.linear_scale_rounded,
      _ => Icons.spa_rounded,
    };
  }

  static Color color(String key) {
    return switch (key) {
      'healthy' => const Color(0xFF3A9F63),
      'bacterial_leaf_blight' => const Color(0xFFC74C3C),
      'leaf_blast' => const Color(0xFFDE6A1F),
      'brown_spot' => const Color(0xFF9A6A47),
      'leaf_scald' => const Color(0xFFE86B2A),
      'narrow_brown_spot' => const Color(0xFF7B5E48),
      _ => const Color(0xFF4F8A6A),
    };
  }
}
