import 'package:get/get.dart';

import 'app_settings_service.dart';
import 'tr_key.dart';

class AppText {
  static bool get isKhmer {
    final settings = Get.find<AppSettingsService>();
    return settings.languageCode.value == 'km';
  }

  static String t(String key) => key.tr;

  static String severityLabel(String severity) {
    return switch (severity) {
      'none' => TrKey.severityNone.tr,
      'low' => TrKey.severityLow.tr,
      'medium' => TrKey.severityMedium.tr,
      'high' => TrKey.severityHigh.tr,
      _ => TrKey.severityUnknown.tr,
    };
  }
}
