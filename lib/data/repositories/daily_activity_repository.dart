import '../../core/exceptions/app_exception.dart';
import '../../data/mock/datasources/mock_data_source.dart';
import '../../models/daily_activity_model.dart';
import '../local/datasources/local_data_source.dart';

class DailyActivityRepository {
  DailyActivityRepository({required this.localDataSource});

  final LocalDataSource localDataSource;

  Future<List<DailyActivityModel>> getActivitiesByTechnician(int technicianId) async {
    try {
      final local = await localDataSource.getDailyActivitiesByTechnician(technicianId);
      if (local.isNotEmpty) return local;
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to read daily activities.');
    }

    final mockActivities = MockDataSource.dailyActivities
        .where((activity) => activity.technicianId == technicianId)
        .toList();

    if (mockActivities.isEmpty) return const [];

    for (final activity in mockActivities) {
      try {
        await localDataSource.insertDailyActivity(activity);
      } on AppException {
        rethrow;
      } catch (_) {
        throw DatabaseException('Failed to seed daily activity data locally.');
      }
    }

    return mockActivities;
  }

  Future<DailyActivityModel> getActivityById(int activityId, int technicianId) async {
    try {
      final activity = await localDataSource.getDailyActivityById(activityId);
      if (activity == null) {
        throw LocalNotFoundException('Daily activity not found.');
      }
      if (activity.technicianId != technicianId) {
        throw UnauthorizedException('You are not allowed to access this activity.');
      }
      return activity;
    } on AppException {
      rethrow;
    } catch (_) {
      throw DatabaseException('Failed to load daily activity.');
    }
  }

  Future<DailyActivityModel> createActivity(DailyActivityModel activity) async {
    if (!DailyActivityModel.activityTypes.contains(activity.activityType)) {
      throw ValidationException('Activity type is invalid.');
    }
    if (!DailyActivityModel.methods.contains(activity.method)) {
      throw ValidationException('Activity method is invalid.');
    }
    if (activity.title.trim().isEmpty) {
      throw ValidationException('Title is required.');
    }
    if (activity.activityDate == DateTime.fromMillisecondsSinceEpoch(0)) {
      throw ValidationException('Activity date is required.');
    }

    final created = activity.copyWith(
      createdAt: activity.createdAt,
      updatedAt: activity.updatedAt,
    );

    try {
      final id = await localDataSource.insertDailyActivity(created);
      final saved = created.copyWith(id: id);
      return saved;
    } on AppException {
      rethrow;
    } catch (_) {
      throw DatabaseException('Failed to create daily activity.');
    }
  }

  Future<DailyActivityModel> updateActivity(DailyActivityModel activity, int technicianId) async {
    final existing = await getActivityById(activity.id, technicianId);
    if (existing.technicianId != technicianId) {
      throw UnauthorizedException('You are not allowed to edit this activity.');
    }

    if (!DailyActivityModel.activityTypes.contains(activity.activityType)) {
      throw ValidationException('Activity type is invalid.');
    }
    if (!DailyActivityModel.methods.contains(activity.method)) {
      throw ValidationException('Activity method is invalid.');
    }
    if (activity.title.trim().isEmpty) {
      throw ValidationException('Title is required.');
    }
    if (activity.activityDate == DateTime.fromMillisecondsSinceEpoch(0)) {
      throw ValidationException('Activity date is required.');
    }

    final updated = activity.copyWith(
      technicianId: technicianId,
      updatedAt: DateTime.now(),
    );

    try {
      final rows = await localDataSource.updateDailyActivity(updated, technicianId);
      if (rows == 0) {
        throw DatabaseException('Failed to update daily activity.');
      }
      return updated;
    } on AppException {
      rethrow;
    } catch (_) {
      throw DatabaseException('Failed to update daily activity.');
    }
  }

  Future<void> deleteActivity(int activityId, int technicianId) async {
    final existing = await getActivityById(activityId, technicianId);
    if (existing.technicianId != technicianId) {
      throw UnauthorizedException('You are not allowed to delete this activity.');
    }

    try {
      final rows = await localDataSource.deleteDailyActivity(activityId, technicianId: technicianId);
      if (rows == 0) {
        throw DatabaseException('Failed to delete daily activity.');
      }
    } on AppException {
      rethrow;
    } catch (_) {
      throw DatabaseException('Failed to delete daily activity.');
    }
  }
}
