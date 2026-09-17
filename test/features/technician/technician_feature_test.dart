import 'package:flutter_test/flutter_test.dart';
import 'package:epremans/data/local/datasources/local_data_source.dart';
import 'package:epremans/data/mock/datasources/mock_data_source.dart';
import 'package:epremans/data/remote/datasources/api_client.dart';
import 'package:epremans/data/remote/datasources/remote_data_source.dart';
import 'package:epremans/data/repositories/technician_task_repository.dart';
import 'package:epremans/core/exceptions/auth_exception.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('TechnicianTaskRepository — Phase 5 Logic', () {
    late TechnicianTaskRepository repo;
    late LocalDataSource localDataSource;

    setUp(() {
      localDataSource = LocalDataSource();
      repo = TechnicianTaskRepository(
        remoteDataSource: RemoteDataSource(ApiClient.getDio()),
        localDataSource: localDataSource,
      );
    });

    // -----------------------------------------------------------------------
    // 1. Task filtering by authenticated technician
    // -----------------------------------------------------------------------
    test('Returns only tasks assigned to technicianId 1', () async {
      final tasks = await repo.getTasksForTechnician(1);
      expect(tasks, isNotEmpty);
      expect(tasks.every((t) => t.technicianId == 1), isTrue);
    });

    test('Returns empty list for technicianId with no tasks', () async {
      final tasks = await repo.getTasksForTechnician(999);
      expect(tasks, isEmpty);
    });

    // -----------------------------------------------------------------------
    // 2. Task retrieval
    // -----------------------------------------------------------------------
    test('getTaskById returns task for valid id', () async {
      final task = await repo.getTaskById(1);
      expect(task.id, 1);
    });

    test('getTaskById throws AuthException for unknown id', () async {
      expect(
        () async => await repo.getTaskById(999),
        throwsA(isA<AuthException>()),
      );
    });

    // -----------------------------------------------------------------------
    // 3. Valid status transitions
    // -----------------------------------------------------------------------
    test('isValidTransition: Assigned → In Progress = valid', () {
      expect(
        TechnicianTaskRepository.isValidTransition('Assigned', 'In Progress'),
        isTrue,
      );
    });

    test('isValidTransition: In Progress → Completed = valid', () {
      expect(
        TechnicianTaskRepository.isValidTransition('In Progress', 'Completed'),
        isTrue,
      );
    });

    test('isValidTransition: In Progress → Cancelled = valid', () {
      expect(
        TechnicianTaskRepository.isValidTransition('In Progress', 'Cancelled'),
        isTrue,
      );
    });

    // -----------------------------------------------------------------------
    // 4. Invalid status transitions
    // -----------------------------------------------------------------------
    test('isValidTransition: Completed → In Progress = invalid', () {
      expect(
        TechnicianTaskRepository.isValidTransition('Completed', 'In Progress'),
        isFalse,
      );
    });

    test('isValidTransition: Cancelled → In Progress = invalid', () {
      expect(
        TechnicianTaskRepository.isValidTransition('Cancelled', 'In Progress'),
        isFalse,
      );
    });

    test('isValidTransition: Completed → Cancelled = invalid', () {
      expect(
        TechnicianTaskRepository.isValidTransition('Completed', 'Cancelled'),
        isFalse,
      );
    });

    test('updateTaskStatus throws AuthException for invalid transition', () async {
      expect(
        () async => await repo.updateTaskStatus(
          taskId: 1,
          technicianId: 1,
          newStatus: 'Assigned', // Trying to go backwards — invalid
          currentStatus: 'In Progress',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    // -----------------------------------------------------------------------
    // 5. QR verification logic (repository level)
    // -----------------------------------------------------------------------
    test('allowedNextStatuses for Assigned = [In Progress]', () {
      expect(
        TechnicianTaskRepository.allowedNextStatuses('Assigned'),
        equals(['In Progress']),
      );
    });

    test('allowedNextStatuses for Completed = []', () {
      expect(
        TechnicianTaskRepository.allowedNextStatuses('Completed'),
        isEmpty,
      );
    });

    // -----------------------------------------------------------------------
    // 6. Unauthorized task access prevention
    // -----------------------------------------------------------------------
    test('getTasksForTechnician does not return tasks from another technician', () async {
      final tasks = await repo.getTasksForTechnician(1);
      // All tasks in mock are for technicianId == 1; none should have technicianId == 2
      expect(tasks.every((t) => t.technicianId != 2), isTrue);
    });

    // -----------------------------------------------------------------------
    // 7. SQLite persistence
    // -----------------------------------------------------------------------
    test('updateTaskStatus persists status to MockDataSource session', () async {
      // Ensure task starts as 'Assigned'
      final taskBefore = await repo.getTaskById(1);
      if (taskBefore.status != 'Assigned') {
        // Reset for test isolation
        final idx = MockDataSource.technicianTasks.indexWhere((t) => t.id == 1);
        if (idx != -1) {
          MockDataSource.technicianTasks[idx] =
              MockDataSource.technicianTasks[idx].copyWith(status: 'Assigned');
        }
      }

      final updated = await repo.updateTaskStatus(
        taskId: 1,
        technicianId: 1,
        newStatus: 'In Progress',
        currentStatus: 'Assigned',
      );

      expect(updated.status, 'In Progress');
      // Also verify session state
      final sessionTask =
          MockDataSource.technicianTasks.firstWhere((t) => t.id == 1);
      expect(sessionTask.status, 'In Progress');

      // Reset for subsequent tests
      final idx = MockDataSource.technicianTasks.indexWhere((t) => t.id == 1);
      if (idx != -1) {
        MockDataSource.technicianTasks[idx] =
            MockDataSource.technicianTasks[idx].copyWith(status: 'Assigned');
      }
    });
  });
}
