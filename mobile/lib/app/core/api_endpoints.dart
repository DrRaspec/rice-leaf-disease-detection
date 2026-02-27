abstract final class ApiEndpoints {
  static const version = 'v1';
  static const prefix = '/api/$version';

  static const predict = '$prefix/predict';
  static const health = '$prefix/health';
  static const authLogin = '$prefix/auth/login';
  static const authRefresh = '$prefix/auth/refresh';
}
