import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../data/providers/data_providers.dart';
import '../../../../models/daily_activity_model.dart';

class DailyActivityState {
  const DailyActivityState({
    this.activities = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<DailyActivityModel> activities;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  DailyActivityState copyWith({
    List<DailyActivityModel>? activities,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return DailyActivityState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class DailyActivityController extends StateNotifier<DailyActivityState> {
  DailyActivityController(this._ref) : super(const DailyActivityState());

  final Ref _ref;

  Future<void> loadActivities(int technicianId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = _ref.read(dailyActivityRepositoryProvider);
      final activities = await repo.getActivitiesByTechnician(technicianId);
      state = state.copyWith(activities: activities, isLoading: false, errorMessage: null);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Unable to load daily activities.');
    }
  }

  Future<void> createActivity(int technicianId, DailyActivityModel activity) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final repo = _ref.read(dailyActivityRepositoryProvider);
      final validatedActivity = activity.copyWith(
        technicianId: technicianId,
        createdAt: activity.createdAt,
        updatedAt: activity.updatedAt,
      );
      await repo.createActivity(validatedActivity);
      await loadActivities(technicianId);
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      rethrow;
    } catch (_) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Unable to create daily activity.');
      rethrow;
    }
  }

  Future<void> updateActivity(int technicianId, DailyActivityModel activity) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final repo = _ref.read(dailyActivityRepositoryProvider);
      await repo.updateActivity(activity, technicianId);
      await loadActivities(technicianId);
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      rethrow;
    } catch (_) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Unable to update daily activity.');
      rethrow;
    }
  }

  Future<void> deleteActivity(int technicianId, int activityId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final repo = _ref.read(dailyActivityRepositoryProvider);
      await repo.deleteActivity(activityId, technicianId);
      await loadActivities(technicianId);
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      rethrow;
    } catch (_) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Unable to delete daily activity.');
      rethrow;
    }
  }

  Future<void> refreshActivities(int technicianId) async {
    await loadActivities(technicianId);
  }
}

final dailyActivityControllerProvider =
    StateNotifierProvider<DailyActivityController, DailyActivityState>((ref) {
  return DailyActivityController(ref);
});
