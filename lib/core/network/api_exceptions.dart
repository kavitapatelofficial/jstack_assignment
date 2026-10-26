class ApiException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  const ApiException({
    required this.message,
    this.errorCode,
    this.statusCode,
  });

  @override
  String toString() => message;
}

class InsufficientFundsException extends ApiException {
  const InsufficientFundsException({
    super.message = 'Insufficient wallet balance to complete this transfer',
    super.errorCode = 'INSUFFICIENT_FUNDS',
    super.statusCode = 409,
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Invalid credentials or session expired',
    super.errorCode = 'AUTH_UNAUTHORIZED',
    super.statusCode = 401,
  });
}

class ValidationException extends ApiException {
  const ValidationException({
    required super.message,
    super.errorCode = 'VALIDATION_ERROR',
    super.statusCode = 400,
  });
}

class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Requested resource not found',
    super.errorCode = 'NOT_FOUND',
    super.statusCode = 404,
  });
}

class NetworkConnectionException extends ApiException {
  const NetworkConnectionException({
    super.message = 'Unable to connect to the server. Please check if mock backend is running.',
    super.errorCode = 'NETWORK_ERROR',
  });
}

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException({
    super.message = 'Connection timed out. Please try again.',
    super.errorCode = 'TIMEOUT_ERROR',
    super.statusCode = 408,
  });
}
