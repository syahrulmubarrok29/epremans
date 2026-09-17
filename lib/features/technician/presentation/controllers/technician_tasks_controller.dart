import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/data_providers.dart';
import '../../../../models/technician_task_model.dart';

class TechnicianTasksController extends StateNotifier<AsyncValue<List<TechnicianTaskModel>>> {
  TechnicianTasksController(this._ref) : super(const AsyncValue.loading());

  final Ref _ref;

  Future<void> loadTasks(int technicianId) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(technicianTaskRepositoryProvider);
      final tasks = await repo.getTasksForTechnician(technicianId);
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final technicianTasksControllerProvider =
    StateNotifierProvider<TechnicianTasksController, AsyncValue<List<TechnicianTaskModel>>>(
  (ref) => TechnicianTasksController(ref),
);
