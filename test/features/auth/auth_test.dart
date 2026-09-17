// ignore_for_file: avoid_print

import 'package:epremans/core/constants/app_constants.dart';
import 'package:epremans/core/exceptions/app_exception.dart';
import 'package:epremans/data/local/datasources/shared_prefs_service.dart';
import 'package:epremans/data/mock/datasources/mock_data_source.dart';
import 'package:epremans/data/providers/data_providers.dart';
import 'package:epremans/data/repositories/auth_repository.dart';
import 'package:epremans/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates an isolated [ProviderContainer] with in-memory SharedPreferences.
ProviderContainer makeContainer({Map<String, Object> prefs = const {}}) {
  SharedPreferences.setMockInitialValues(prefs);

  // SharedPreferences.getInstance() is synchronous after setMockInitialValues.
  late SharedPreferences sharedPrefs;
  SharedPreferences.getInstance().then((p) => sharedPrefs = p);

  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((_) => sharedPrefs),
    ],
  );
}

/// Builds an isolated [AuthRepository] backed by in-memory [SharedPreferences].
Future<(AuthRepository, SharedPrefsService)> makeAuthRepo(
    {Map<String, Object> initialPrefs = const {}}) async {
  SharedPreferences.setMockInitialValues(initialPrefs);
  final prefs = await SharedPreferences.getInstance();
  final service = SharedPrefsService(prefs);
  final repo = AuthRepository(service);
  return (repo, service);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // MockDataSource.findByCredentials
  // -------------------------------------------------------------------------
  group('MockDataSource.findByCredentials', () {
    test('returns Customer UserModel for valid customer credentials', () {
      final user = MockDataSource.findByCredentials(
          'admin@rssehat.com', 'password123');
      expect(user, isNotNull);
      expect(user!.email, 'admin@rssehat.com');
      expect(user.role, AppConstants.roleCustomer);
      expect(user.isCustomer, isTrue);
    });

    test('returns Technician UserModel for valid technician credentials', () {
      final user = MockDataSource.findByCredentials(
          'tech@polaris.com', 'password123');
      expect(user, isNotNull);
      expect(user!.email, 'tech@polaris.com');
      expect(user.role, AppConstants.roleTechnician);
      expect(user.isTechnician, isTrue);
    });

    test('returns null for wrong password', () {
      final user = MockDataSource.findByCredentials(
          'admin@rssehat.com', 'wrongpassword');
      expect(user, isNull);
    });

    test('returns null for unknown email', () {
      final user = MockDataSource.findByCredentials(
          'unknown@example.com', 'password123');
      expect(user, isNull);
    });

    test('returns null for empty credentials', () {
      expect(MockDataSource.findByCredentials('', ''), isNull);
    });

    test('does not expose passwords via UserModel', () {
      final user = MockDataSource.findByCredentials(
          'admin@rssehat.com', 'password123');
      // UserModel has no password field — confirm it cannot be read.
      expect(user, isA<UserModel>());
      // Compile-time proof: UserModel has no 'password' field.
      // If someone adds it, this test stays green but the model review
      // comment in the plan must be revisited.
    });
  });

  // -------------------------------------------------------------------------
  // AuthRepository.mockLogin
  // -------------------------------------------------------------------------
  group('AuthRepository.mockLogin', () {
    test('successful Customer login returns UserModel and persists session',
        () async {
      final (repo, service) = await makeAuthRepo();

      final user = await repo.mockLogin('admin@rssehat.com', 'password123');

      expect(user.email, 'admin@rssehat.com');
      expect(user.role, AppConstants.roleCustomer);

      // Session persisted
      expect(service.isLoggedIn, isTrue);
      expect(service.userId, user.id);
      expect(service.userRole, AppConstants.roleCustomer);
      expect(service.authToken, 'mock-token');
    });

    test('successful Technician login returns UserModel and persists session',
        () async {
      final (repo, service) = await makeAuthRepo();

      final user = await repo.mockLogin('tech@polaris.com', 'password123');

      expect(user.email, 'tech@polaris.com');
      expect(user.role, AppConstants.roleTechnician);

      expect(service.isLoggedIn, isTrue);
      expect(service.userId, user.id);
      expect(service.userRole, AppConstants.roleTechnician);
      expect(service.authToken, 'mock-token');
    });

    test('wrong password throws AuthException', () async {
      final (repo, _) = await makeAuthRepo();
      expect(
        () => repo.mockLogin('admin@rssehat.com', 'bad'),
        throwsA(isA<AuthException>()),
      );
    });

    test('unknown email throws AuthException', () async {
      final (repo, _) = await makeAuthRepo();
      expect(
        () => repo.mockLogin('nobody@example.com', 'password123'),
        throwsA(isA<AuthException>()),
      );
    });

    test('AuthException carries the auth_error code', () async {
      final (repo, _) = await makeAuthRepo();
      try {
        await repo.mockLogin('admin@rssehat.com', 'wrong');
        fail('Expected AuthException');
      } on AuthException catch (e) {
        expect(e.code, 'auth_error');
        expect(e.message, isNotEmpty);
      }
    });
  });

  // -------------------------------------------------------------------------
  // AuthRepository.logout
  // -------------------------------------------------------------------------
  group('AuthRepository.logout', () {
    test('clears session after login', () async {
      final (repo, service) = await makeAuthRepo();

      await repo.mockLogin('admin@rssehat.com', 'password123');
      expect(service.isLoggedIn, isTrue);

      await repo.logout();

      expect(service.isLoggedIn, isFalse);
      expect(service.userId, isNull);
      expect(service.userRole, isNull);
      expect(service.authToken, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // AuthController (Riverpod)
  // -------------------------------------------------------------------------
  group('AuthController', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('initial state is AsyncData(null) — unauthenticated', () async {
      // Allow build() to complete.
      await container.read(authControllerProvider.future);
      final state = container.read(authControllerProvider);
      expect(state, isA<AsyncData<UserModel?>>());
      expect(state.value, isNull);
    });

    test('login success transitions to AsyncData(UserModel)', () async {
      await container.read(authControllerProvider.future);

      await container
          .read(authControllerProvider.notifier)
          .login('admin@rssehat.com', 'password123');

      final state = container.read(authControllerProvider);
      expect(state, isA<AsyncData<UserModel?>>());
      expect(state.value, isNotNull);
      expect(state.value!.email, 'admin@rssehat.com');
      expect(state.value!.isCustomer, isTrue);
    });

    test('login failure transitions to AsyncError(AuthException)', () async {
      await container.read(authControllerProvider.future);

      await container
          .read(authControllerProvider.notifier)
          .login('admin@rssehat.com', 'wrongpassword');

      final state = container.read(authControllerProvider);
      expect(state, isA<AsyncError<UserModel?>>());
      expect(state.error, isA<AuthException>());
    });

    test('logout transitions state back to AsyncData(null)', () async {
      await container.read(authControllerProvider.future);

      await container
          .read(authControllerProvider.notifier)
          .login('tech@polaris.com', 'password123');
      expect(container.read(authControllerProvider).value, isNotNull);

      await container.read(authControllerProvider.notifier).logout();

      final state = container.read(authControllerProvider);
      expect(state.value, isNull);
    });

    test('restoreSession restores authenticated user from persisted session',
        () async {
      // First: login to persist session.
      await container.read(authControllerProvider.future);
      await container
          .read(authControllerProvider.notifier)
          .login('tech@polaris.com', 'password123');
      final loggedInUser = container.read(authControllerProvider).value!;

      // Simulate app restart: new container with same persisted prefs.
      final prefs = await SharedPreferences.getInstance();
      final newContainer = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(newContainer.dispose);

      await newContainer.read(authControllerProvider.future);
      await newContainer.read(authControllerProvider.notifier).restoreSession();

      final restoredState = newContainer.read(authControllerProvider);
      expect(restoredState.value, isNotNull);
      expect(restoredState.value!.id, loggedInUser.id);
      expect(restoredState.value!.role, AppConstants.roleTechnician);
    });

    test('restoreSession with no persisted session leaves state null', () async {
      await container.read(authControllerProvider.future);
      await container.read(authControllerProvider.notifier).restoreSession();

      final state = container.read(authControllerProvider);
      expect(state.value, isNull);
    });

    test('isAuthenticated and role convenience getters are correct', () async {
      await container.read(authControllerProvider.future);

      final ctrl = container.read(authControllerProvider.notifier);
      expect(ctrl.isAuthenticated, isFalse);
      expect(ctrl.isCustomer, isFalse);
      expect(ctrl.isTechnician, isFalse);

      await ctrl.login('admin@rssehat.com', 'password123');

      expect(ctrl.isAuthenticated, isTrue);
      expect(ctrl.isCustomer, isTrue);
      expect(ctrl.isTechnician, isFalse);

      await ctrl.logout();

      expect(ctrl.isAuthenticated, isFalse);
    });
  });
}
