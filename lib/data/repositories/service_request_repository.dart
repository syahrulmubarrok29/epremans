import '../../models/service_request_model.dart';
import '../mock/datasources/mock_data_source.dart';
import '../remote/datasources/remote_data_source.dart';

class ServiceRequestRepository {
  ServiceRequestRepository({
    required this.remoteDataSource,
  });

  final RemoteDataSource remoteDataSource;

  /// Fetches service requests (currently uses Mock Data)
  Future<List<ServiceRequestModel>> getCustomerRequests(int customerId) async {
    return MockDataSource.serviceRequests
        .where((req) => req.customerId == customerId)
        .toList();
  }
}
