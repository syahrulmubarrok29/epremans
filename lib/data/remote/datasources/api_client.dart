import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';

/// Provides a configured Dio client for connecting to the Laravel backend.
class ApiClient {
  ApiClient._();

  static Dio getDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Logging interceptor (only in debug mode, conceptually)
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }
}
