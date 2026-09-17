import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../models/user_model.dart';
import '../local/datasources/local_data_source.dart';
import '../local/datasources/shared_prefs_service.dart';
import '../remote/datasources/api_client.dart';
import '../remote/datasources/remote_data_source.dart';
import '../repositories/auth_repository.dart';
import '../repositories/equipment_repository.dart';
import '../repositories/service_report_repository.dart';
import '../repositories/service_request_repository.dart';
import '../repositories/technician_task_repository.dart';

// ---------------------------------------------------------------------------
// External Dependencies
// ---------------------------------------------------------------------------
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

// ---------------------------------------------------------------------------
// Data Sources
// ---------------------------------------------------------------------------
final sharedPrefsServiceProvider = Provider<SharedPrefsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsService(prefs);
});

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource();
});

final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  final dio = ApiClient.getDio();
  return RemoteDataSource(dio);
});

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(sharedPrefsServiceProvider));
});

final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  return EquipmentRepository(
    localDataSource: ref.watch(localDataSourceProvider),
    remoteDataSource: ref.watch(remoteDataSourceProvider),
  );
});

final serviceRequestRepositoryProvider = Provider<ServiceRequestRepository>((ref) {
  return ServiceRequestRepository(
    remoteDataSource: ref.watch(remoteDataSourceProvider),
  );
});

final technicianTaskRepositoryProvider = Provider<TechnicianTaskRepository>((ref) {
  return TechnicianTaskRepository(
    remoteDataSource: ref.watch(remoteDataSourceProvider),
  );
});

final serviceReportRepositoryProvider = Provider<ServiceReportRepository>((ref) {
  return ServiceReportRepository(
    localDataSource: ref.watch(localDataSourceProvider),
    remoteDataSource: ref.watch(remoteDataSourceProvider),
  );
});

// ---------------------------------------------------------------------------
// Auth Controller (Phase 3)
// ---------------------------------------------------------------------------

/// Provides [AuthController] — the single source of truth for auth state.
///
/// Consumers use [authControllerProvider] to read login/logout state
/// and [authControllerProvider.notifier] to call [login]/[logout].
final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserModel?>(AuthController.new);

/// Tracks whether the splash screen display animation has completed.
/// Used by GoRouter redirect to resolve destination only after splash ends.
class SplashCompletedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void complete() => state = true;
}

final splashCompletedProvider =
    NotifierProvider<SplashCompletedNotifier, bool>(SplashCompletedNotifier.new);

