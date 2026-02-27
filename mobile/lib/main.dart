import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_kit/flutter_adaptive_kit.dart';
import 'package:get/get.dart';
import 'app/core/core_i18n.dart';
import 'app/core/core_network.dart';
import 'app/core/core_services.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.configure();
  await AppLogger.runWithPrintGuard(() async {
    await AdaptiveUtils.ensureScreenSize();

    const breakpoints = AdaptiveBreakpoints(useShortestSide: true);
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    final logicalSize = view == null
        ? Size.zero
        : view.physicalSize / view.devicePixelRatio;
    final deviceType = breakpoints.getDeviceType(
      logicalSize.width,
      logicalSize.height,
    );

    // Phone: portrait only. Tablet/desktop/foldable: allow both.
    final orientations = deviceType == DeviceType.phone
        ? const [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]
        : const [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ];
    await SystemChrome.setPreferredOrientations(orientations);

    // Transparent status bar, dark icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFFCFFFD),
      ),
    );

    // Register global services
    await Get.put(AppSettingsService(), permanent: true).initialize();
    final apiClient = Get.put(ApiClient(), permanent: true);
    await apiClient.initialize();

    runApp(const RiceGuardApp());
  });
}

class RiceGuardApp extends StatelessWidget {
  const RiceGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsService>();
    return Obx(() {
      final appThemeMode = settings.themeMode.value;
      final selectedLanguage = settings.languageCode.value;
      final systemBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final isDark = appThemeMode == ThemeMode.dark ||
          (appThemeMode == ThemeMode.system && systemBrightness == Brightness.dark);

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor:
              isDark ? const Color(0xFF163024) : const Color(0xFFFCFFFD),
        ),
      );

      return AdaptiveScope(
        child: GetMaterialApp(
          title: 'RiceGuard AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(fontFamily: settings.fontFamily.value),
          darkTheme: AppTheme.dark(fontFamily: settings.fontFamily.value),
          themeMode: appThemeMode,
          translations: AppTranslations(),
          fallbackLocale: const Locale('en', 'US'),
          builder: (context, child) {
            final media = MediaQuery.of(context);
            final textScale =
                (settings.fontSize.value / 14.0) * settings.zoomScale.value;
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(textScale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
          defaultTransition: Transition.fadeIn,
          locale: selectedLanguage == 'km'
              ? const Locale('km', 'KH')
              : const Locale('en', 'US'),
        ),
      );
    });
  }
}
