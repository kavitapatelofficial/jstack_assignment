import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorageService storageService;

  ApiClient({
    required this.storageService,
    String? baseUrl,
  }) {
    final effectiveBaseUrl = baseUrl ??
        storageService.getCustomBaseUrl() ??
        ApiEndpoints.getDefaultBaseUrl();

    dio = Dio(
      BaseOptions(
        baseUrl: effectiveBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add Auth and Error Interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          final customError = _mapDioException(e);
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: customError,
              message: customError.message,
            ),
          );
        },
      ),
    );
  }

  void updateBaseUrl(String newBaseUrl) {
    dio.options.baseUrl = newBaseUrl;
  }

  ApiException _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ApiTimeoutException();
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NetworkConnectionException();
    }

    final response = e.response;
    if (response != null) {
      final statusCode = response.statusCode;
      String message = 'An unexpected error occurred';
      String? errorCode;

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        message = data['message'] as String? ?? message;
        errorCode = data['errorCode'] as String?;
      }

      switch (statusCode) {
        case 400:
          return ValidationException(message: message, errorCode: errorCode);
        case 401:
          return UnauthorizedException(message: message, errorCode: errorCode);
        case 404:
          return NotFoundException(message: message, errorCode: errorCode);
        case 409:
          return InsufficientFundsException(message: message, errorCode: errorCode);
        case 500:
        default:
          return ApiException(
            message: message,
            errorCode: errorCode ?? 'SERVER_ERROR',
            statusCode: statusCode,
          );
      }
    }

    return ApiException(
      message: e.message ?? 'Network communication error',
      errorCode: 'UNKNOWN_ERROR',
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'Request failed');
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'Request failed');
    }
  }
}
