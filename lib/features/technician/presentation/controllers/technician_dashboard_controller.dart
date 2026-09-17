import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/data_providers.dart';
import '../../../../models/technician_task_model.dart';

/// State: summary counts for the dashboard.
class TechnicianDashboardState {
  const TechnicianDashboardState({
    required this.tasks,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<TechnicianTaskModel> tasks;
  final bool isLoading;
  final String? errorMessage;

  int get assignedCount => tasks.where((t) => t.status == 'Assigned').length;
  int get inProgressCount => tasks.where((t) => t.status == 'In Progress').length;
  int get completedCount => tasks.where((t) => t.status == 'Completed').length;
  int get activeCount => tasks.where((t) => t.status != 'Completed' && t.status != 'Cancelled').length;

  TechnicianDashboardState copyWith({
    List<TechnicianTaskModel>? tasks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TechnicianDashboardState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class TechnicianDashboardController extends StateNotifier<TechnicianDashboardState> {
  TechnicianDashboardController(this._ref)
      : super(const TechnicianDashboardState(tasks: []));

  final Ref _ref;

  Future<void> loadDashboard(int technicianId) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(technicianTaskRepositoryProvider);
      final tasks = await repo.getTasksForTechnician(technicianId);
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load tasks.');
    }
  }
}

final technicianDashboardControllerProvider =
    StateNotifierProvider<TechnicianDashboardController, TechnicianDashboardState>(
  (ref) => TechnicianDashboardController(ref),
);
