import 'package:shared_preferences/shared_preferences.dart';

/// Service for interacting with SharedPreferences.
/// Used ONLY for lightweight preferences and session-related values.
class SharedPrefsService {
  SharedPrefsService(this._prefs);

  final SharedPreferences _prefs;

  // ---------------------------------------------------------------------------
  // Keys
  // ---------------------------------------------------------------------------
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId = 'userId';
  static const String _keyUserRole = 'userRole';
  static const String _keyAuthToken = 'authToken';
  static const String _keyLastSelectedRole = 'lastSelectedRole';
  static const String _keyFirstLaunch = 'firstLaunch';

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------
  
  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;
  int? get userId => _prefs.getInt(_keyUserId);
  String? get userRole => _prefs.getString(_keyUserRole);
  String? get authToken => _prefs.getString(_keyAuthToken);
  String? get lastSelectedRole => _prefs.getString(_keyLastSelectedRole);
  bool get isFirstLaunch => _prefs.getBool(_keyFirstLaunch) ?? true;

  // ---------------------------------------------------------------------------
  // Setters
  // ---------------------------------------------------------------------------

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_keyIsLoggedIn, value);
  }

  Future<void> setUserId(int value) async {
    await _prefs.setInt(_keyUserId, value);
  }

  Future<void> setUserRole(String value) async {
    await _prefs.setString(_keyUserRole, value);
  }

  Future<void> setAuthToken(String value) async {
    await _prefs.setString(_keyAuthToken, value);
  }

  Future<void> setLastSelectedRole(String value) async {
    await _prefs.setString(_keyLastSelectedRole, value);
  }

  Future<void> setFirstLaunch(bool value) async {
    await _prefs.setBool(_keyFirstLaunch, value);
  }

  // ---------------------------------------------------------------------------
  // Clear
  // ---------------------------------------------------------------------------

  /// Clears all session data, typically used on logout.
  /// Does NOT clear [isFirstLaunch].
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserRole);
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyLastSelectedRole);
  }
}
