import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/data_providers.dart';
import '../../../../data/repositories/technician_task_repository.dart';
import '../../../../models/technician_task_model.dart';

class TechnicianTaskDetailState {
  const TechnicianTaskDetailState({
    this.task,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.successMessage,
    this.isEquipmentVerified = false,
  });

  final TechnicianTaskModel? task;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final String? successMessage;
  final bool isEquipmentVerified;

  TechnicianTaskDetailState copyWith({
    TechnicianTaskModel? task,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    String? successMessage,
    bool? isEquipmentVerified,
  }) {
    return TechnicianTaskDetailState(
      task: task ?? this.task,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isEquipmentVerified: isEquipmentVerified ?? this.isEquipmentVerified,
    );
  }

  List<String> get allowedNextStatuses =>
      task != null ? TechnicianTaskRepository.allowedNextStatuses(task!.status) : [];

  bool canTransitionTo(String newStatus) =>
      task != null && TechnicianTaskRepository.isValidTransition(task!.status, newStatus);
}

class TechnicianTaskDetailController extends StateNotifier<TechnicianTaskDetailState> {
  TechnicianTaskDetailController(this._ref) : super(const TechnicianTaskDetailState());

  final Ref _ref;

  Future<void> loadTask(int taskId) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(technicianTaskRepositoryProvider);
      final task = await repo.getTaskById(taskId);
      state = state.copyWith(task: task, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Task not found.');
    }
  }

  /// Called when the QR scanner confirms the equipment matches.
  void markEquipmentVerified() {
    state = state.copyWith(isEquipmentVerified: true);
  }

  /// Updates task status with full validation chain.
  ///
  /// Returns true if successful.
  Future<bool> updateStatus(String newStatus, int technicianId) async {
    final task = state.task;
    if (task == null) return false;

    // Enforce verification gate before "In Progress"
    if (newStatus == TechnicianTaskRepository.statusInProgress && !state.isEquipmentVerified) {
      state = state.copyWith(errorMessage: 'Equipment must be verified via QR before starting.');
      return false;
    }

    state = state.copyWith(isUpdating: true);
    try {
      final repo = _ref.read(technicianTaskRepositoryProvider);
      final updated = await repo.updateTaskStatus(
        taskId: task.id,
        technicianId: technicianId,
        newStatus: newStatus,
        currentStatus: task.status,
      );
      state = state.copyWith(
        task: updated,
        isUpdating: false,
        successMessage: 'Status updated to $newStatus.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}

final technicianTaskDetailControllerProvider =
    StateNotifierProvider.autoDispose<TechnicianTaskDetailController, TechnicianTaskDetailState>(
  (ref) => TechnicianTaskDetailController(ref),
);
