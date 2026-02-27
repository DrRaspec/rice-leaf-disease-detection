import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shadow_log/shadow_log.dart';

class AppLogger {
  static bool _configured = false;

  static void configure() {
    if (_configured) return;
    const outputs = kReleaseMode
        ? <ShadowLogOutput>[]
        : <ShadowLogOutput>[ShadowDebugPrintOutput()];

    ShadowLog.configure(
      const ShadowLogConfig(
        name: 'RiceGuard',
        minLevel: kReleaseMode ? ShadowLogLevel.info : ShadowLogLevel.debug,
        enabledInRelease: true,
        formatter: ShadowPrettyFormatter(),
        outputs: outputs,
      ),
    );

    if (kReleaseMode) {
      debugPrint = (String? _, {int? wrapWidth}) {};
    }

    ShadowLog.installFlutterErrorHandler(
      callOriginalHandlers: !kReleaseMode,
    );
    _configured = true;
  }

  static Future<void> runWithPrintGuard(FutureOr<void> Function() body) async {
    await runZonedGuarded(
      () async => await body(),
      (error, stackTrace) {
        AppLogger.e(
          'Zone',
          'Uncaught zone error',
          error: error,
          stackTrace: stackTrace,
        );
      },
      zoneSpecification: const ZoneSpecification(
        print: _swallowPrint,
      ),
    );
  }

  static void _swallowPrint(
    Zone self,
    ZoneDelegate parent,
    Zone zone,
    String line,
  ) {}

  static void d(String scope, String message, {Map<String, Object?>? fields}) {
    ShadowLog.logger(scope).d(message, fields: fields);
  }

  static void i(String scope, String message, {Map<String, Object?>? fields}) {
    ShadowLog.logger(scope).i(message, fields: fields);
  }

  static void w(
    String scope,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    ShadowLog.logger(
      scope,
    ).w(message, error: error, stackTrace: stackTrace, fields: fields);
  }

  static void e(
    String scope,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    ShadowLog.logger(
      scope,
    ).e(message, error: error, stackTrace: stackTrace, fields: fields);
  }
}
