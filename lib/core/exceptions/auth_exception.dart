/// Thrown when mock credential validation fails.
/// Replace with API error mapping during Laravel integration.
class AuthException implements Exception {
  const AuthException([
    this.message = 'Invalid email or password.',
    this.code = 'auth_error',
  ]);

  final String message;
  final String? code;

  @override
  String toString() => message;
}
