import '../../core/exceptions/app_exception.dart';
import '../../models/user_model.dart';
import '../local/datasources/shared_prefs_service.dart';
import '../mock/datasources/mock_data_source.dart';

/// Repository for handling authentication state locally.
///
/// Phase 3: exposes [mockLogin] for prototype plain-string credential check.
/// Replace [mockLogin] with a real API call during Laravel integration.
class AuthRepository {
  AuthRepository(this._prefsService);

  final SharedPrefsService _prefsService;

  bool get isLoggedIn => _prefsService.isLoggedIn;
  String? get userRole => _prefsService.userRole;
  int? get userId => _prefsService.userId;

  /// Phase 3 prototype login.
  ///
  /// Compares [email] and [password] as plain strings against [MockDataSource].
  /// On success, persists the session via [SharedPrefsService] and returns the
  /// matching [UserModel].
  ///
  /// Throws [AuthException] when credentials are invalid.
  ///
  /// Replace entirely during Laravel API integration — no production
  /// authentication or security mechanism is implemented here.
  Future<UserModel> mockLogin(String email, String password) async {
    final user = MockDataSource.findByCredentials(email, password);
    if (user == null) throw const AuthException();
    await loginLocally(user.id, user.role, 'mock-token');
    return user;
  }

  /// Persists session data after a successful login.
  /// [token] is a non-secret placeholder in Phase 3 ('mock-token').
  Future<void> loginLocally(int id, String role, String token) async {
    await _prefsService.setUserId(id);
    await _prefsService.setUserRole(role);
    await _prefsService.setAuthToken(token);
    await _prefsService.setLoggedIn(true);
  }

  /// Clears all session data. Navigating to /login is the caller's responsibility.
  Future<void> logout() async {
    await _prefsService.clearSession();
  }
}
