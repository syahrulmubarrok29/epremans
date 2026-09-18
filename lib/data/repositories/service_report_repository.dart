import '../../models/service_report_model.dart';
import '../local/datasources/local_data_source.dart';
import '../mock/datasources/mock_data_source.dart';
import '../remote/datasources/remote_data_source.dart';

class ServiceReportRepository {
  ServiceReportRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;

  /// Fetches a report by ID from local SQLite, fallback to mock data
  Future<ServiceReportModel?> getReportById(int id) async {
    final local = await localDataSource.getServiceReportById(id);
    if (local != null) return local;

    try {
      return MockDataSource.serviceReports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ServiceReportModel>> getServiceReportsForTask(int taskId) async {
    final all = await localDataSource.getAllServiceReports();
    final byTask = all.where((r) => r.taskId == taskId).toList();

    final fullReports = <ServiceReportModel>[];
    for (final report in byTask) {
      final full = await localDataSource.getServiceReportById(report.id);
      if (full != null) {
        fullReports.add(full);
      } else {
        fullReports.add(report);
      }
    }

    return fullReports;
  }

  /// Saves a report locally (e.g., Draft or Completed before sync)
  Future<int> saveReportLocally(ServiceReportModel report) async {
    if (report.id == 0) {
      // New report insertion
      return await localDataSource.insertServiceReport(report);
    } else {
      // Update existing
      await localDataSource.updateServiceReport(report);
      return report.id;
    }
  }

  /// Example sync method for future implementation
  Future<void> syncReportToRemote(ServiceReportModel report) async {
    // throw UnimplementedError('API integration not ready (Phase 2).');
  }
}
