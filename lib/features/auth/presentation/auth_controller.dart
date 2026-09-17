import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/mock/datasources/mock_data_source.dart';
import '../../../data/providers/data_providers.dart';
import '../../../models/user_model.dart';

/// Riverpod [AsyncNotifier] that manages authentication state for Phase 3.
///
/// State: [AsyncValue<UserModel?>]
///   - [AsyncLoading] — login or session restore in progress
///   - [AsyncData(UserModel)] — authenticated
///   - [AsyncData(null)] — unauthenticated / logged out
///   - [AsyncError] — login failed (carries [AuthException])
///
/// Passwords are NEVER stored in state.
class AuthController extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    // Initial state: unauthenticated (session restored via restoreSession()).
    return null;
  }

  /// Restores a persisted session from [SharedPrefsService].
  ///
  /// Called by [SplashScreen] before GoRouter resolves the destination.
  /// If [isLoggedIn] and a matching user is found in [MockDataSource],
  /// state is set to that user. Otherwise state remains null (unauthenticated).
  Future<void> restoreSession() async {
    final repo = ref.read(authRepositoryProvider);
    if (!repo.isLoggedIn) {
      state = const AsyncData(null);
      return;
    }

    final userId = repo.userId;
    if (userId == null) {
      await repo.logout();
      state = const AsyncData(null);
      return;
    }

    try {
      final user = MockDataSource.users.firstWhere(
        (u) => u.id == userId,
        orElse: () => throw StateError('Stored userId $userId not found in MockDataSource.'),
      );
      state = AsyncData(user);
    } catch (_) {
      // Stored user no longer present — clear stale session.
      await repo.logout();
      state = const AsyncData(null);
    }
  }

  /// Attempts mock login with [email] and [password].
  ///
  /// On success: state → [AsyncData(UserModel)]
  /// On failure: state → [AsyncError(AuthException)]
  ///
  /// Passwords are never stored in state.
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).mockLogin(email, password),
    );
  }

  /// Logs out the current user and clears the persisted session.
  ///
  /// State → [AsyncData(null)].
  /// GoRouter redirect handles navigation to /login.
  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  /// Convenience getter: true if state contains a non-null [UserModel].
  bool get isAuthenticated => state.valueOrNull != null;

  /// Convenience getter: current role, or null if unauthenticated.
  String? get currentRole => state.valueOrNull?.role;

  /// True if authenticated as technician.
  bool get isTechnician => currentRole == AppConstants.roleTechnician;

  /// True if authenticated as customer.
  bool get isCustomer => currentRole == AppConstants.roleCustomer;
}
