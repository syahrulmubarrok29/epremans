export 'auth_exception.dart';

/// Base exception class for e-PREMANS.
///
/// All application-level exceptions extend this class.
/// Repository methods throw [AppException] subclasses — never raw [Exception].
sealed class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;

  /// Optional machine-readable error code (e.g. HTTP status or DB error code).
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

// ---------------------------------------------------------------------------
// Network exceptions
// ---------------------------------------------------------------------------

/// Thrown when the network request fails (timeout, no connectivity, etc.).
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error. Please check your connection.'])
      : super(code: 'network_error');
}

/// Thrown when the server returns an unexpected response.
class ServerException extends AppException {
  const ServerException([super.message = 'Server error. Please try again later.', String? code])
      : super(code: code ?? 'server_error');
}

/// Thrown when the server returns 401 Unauthorized.
class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired. Please log in again.'])
      : super(code: 'unauthorized');
}

/// Thrown when the server returns 404 Not Found.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'The requested resource was not found.'])
      : super(code: 'not_found');
}

// ---------------------------------------------------------------------------
// Local data exceptions
// ---------------------------------------------------------------------------

/// Thrown when a local database operation fails.
class DatabaseException extends AppException {
  const DatabaseException([super.message = 'A local database error occurred.'])
      : super(code: 'db_error');
}

/// Thrown when data validation fails.
class ValidationException extends AppException {
  const ValidationException(super.message) : super(code: 'validation_error');
}

/// Thrown when a required entity is not found locally.
class LocalNotFoundException extends AppException {
  const LocalNotFoundException([super.message = 'Data not found locally.'])
      : super(code: 'local_not_found');
}

// ---------------------------------------------------------------------------
// Business logic exceptions
// ---------------------------------------------------------------------------

/// Thrown when an operation is attempted in an invalid state.
/// Example: trying to END SERVICE before START SERVICE.
class InvalidStateException extends AppException {
  const InvalidStateException(super.message) : super(code: 'invalid_state');
}
