import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'app_config.dart';
import 'app_logger.dart';

class ApiClient extends getx.GetxService {
  static const String _apiPrefix = '/api/v1';
  late final Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
        headers: {'Accept': 'application/json'},
      ),
    );
  }

  Future<void> initialize() async {
    AppLogger.i('ApiClient', 'API client initialized.', fields: {
      'env': AppConfig.env,
    });
  }

  /// POST /predict with multipart image file
  Future<Response<dynamic>> predictDisease(String filePath) async {
    const maxAttempts = 2;
    DioException? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath),
        });
        return await _dio.post('$_apiPrefix/predict', data: formData);
      } on DioException catch (e) {
        lastError = e;
        final canRetry = attempt < maxAttempts && _isRetriable(e);
        if (!canRetry) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
    throw lastError ?? Exception('Prediction request failed.');
  }

  /// GET /health
  Future<Response<dynamic>> health() => _dio.get('$_apiPrefix/health');

  bool _isRetriable(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }
    final status = error.response?.statusCode;
    return status != null && status >= 500;
  }
}
