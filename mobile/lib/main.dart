import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/core/api_client.dart';
import 'app/core/app_logger.dart';
import 'app/core/app_settings_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar, dark icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A2015),
    ),
  );

  // Register global services
  AppLogger.configure();
  await Get.put(AppSettingsService(), permanent: true).initialize();
  final apiClient = Get.put(ApiClient(), permanent: true);
  await apiClient.initialize();

  runApp(const RiceGuardApp());
}

class RiceGuardApp extends StatelessWidget {
  const RiceGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsService>();
    return Obx(() {
      final appThemeMode = settings.themeMode.value;
      final systemBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final isDark = appThemeMode == ThemeMode.dark ||
          (appThemeMode == ThemeMode.system && systemBrightness == Brightness.dark);

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor:
              isDark ? const Color(0xFF0A2015) : const Color(0xFFF7FCF8),
        ),
      );

      return GetMaterialApp(
        title: 'RiceGuard AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(fontFamily: settings.fontFamily.value),
        darkTheme: AppTheme.dark(fontFamily: settings.fontFamily.value),
        themeMode: appThemeMode,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              textScaler: TextScaler.linear(settings.fontScale.value),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
        defaultTransition: Transition.fadeIn,
      );
    });
  }
}
