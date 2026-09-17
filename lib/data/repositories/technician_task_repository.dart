import '../../core/exceptions/auth_exception.dart';
import '../../models/technician_task_model.dart';
import '../local/datasources/local_data_source.dart';
import '../mock/datasources/mock_data_source.dart';
import '../remote/datasources/remote_data_source.dart';

class TechnicianTaskRepository {
  TechnicianTaskRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  // Supported status values
  static const String statusAssigned = 'Assigned';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';

  /// Returns valid next statuses for a given current status.
  static List<String> allowedNextStatuses(String currentStatus) {
    switch (currentStatus) {
      case statusAssigned:
        return [statusInProgress];
      case statusInProgress:
        return [statusCompleted, statusCancelled];
      default:
        return [];
    }
  }

  /// Validates that [newStatus] is a permitted transition from [currentStatus].
  static bool isValidTransition(String currentStatus, String newStatus) {
    return allowedNextStatuses(currentStatus).contains(newStatus);
  }

  /// Fetches technician tasks (Mock first, then Local SQLite).
  Future<List<TechnicianTaskModel>> getTasksForTechnician(int technicianId) async {
    final mockTasks = MockDataSource.technicianTasks
        .where((task) => task.technicianId == technicianId)
        .toList();
    if (mockTasks.isNotEmpty) return mockTasks;

    return await localDataSource.getTechnicianTasksByTechnicianId(technicianId);
  }

  /// Gets a single task by [taskId]. Throws if not found.
  Future<TechnicianTaskModel> getTaskById(int taskId) async {
    try {
      return MockDataSource.technicianTasks.firstWhere((t) => t.id == taskId);
    } catch (_) {}
    throw const AuthException(
      'Task not found.',
      'task_not_found',
    );
  }

  /// Updates task status with validation.
  ///
  /// Throws [AuthException] for invalid transitions.
  /// Updates both MockDataSource (session) and SQLite (persistence).
  Future<TechnicianTaskModel> updateTaskStatus({
    required int taskId,
    required int technicianId,
    required String newStatus,
    required String currentStatus,
  }) async {
    // 1. Enforce transition rule (server-side equivalent)
    if (!isValidTransition(currentStatus, newStatus)) {
      throw AuthException(
        'Invalid status transition: $currentStatus → $newStatus',
        'invalid_transition',
      );
    }

    final completedAt = newStatus == statusCompleted ? DateTime.now() : null;

    // 2. Update session state in MockDataSource
    final index = MockDataSource.technicianTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      MockDataSource.technicianTasks[index] = MockDataSource.technicianTasks[index].copyWith(
        status: newStatus,
        completedAt: completedAt,
      );
    }

    // 3. Persist to SQLite
    await localDataSource.updateTechnicianTaskStatus(
      taskId,
      newStatus,
      completedAt: completedAt,
    );

    // 4. Return updated task
    return await getTaskById(taskId);
  }
}
