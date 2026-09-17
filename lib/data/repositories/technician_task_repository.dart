import '../../models/technician_task_model.dart';
import '../mock/datasources/mock_data_source.dart';
import '../remote/datasources/remote_data_source.dart';

class TechnicianTaskRepository {
  TechnicianTaskRepository({
    required this.remoteDataSource,
  });

  final RemoteDataSource remoteDataSource;

  /// Fetches technician tasks (currently uses Mock Data)
  Future<List<TechnicianTaskModel>> getTasksForTechnician(int technicianId) async {
    return MockDataSource.technicianTasks
        .where((task) => task.technicianId == technicianId)
        .toList();
  }
}
