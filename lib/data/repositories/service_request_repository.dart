import '../../models/service_request_model.dart';
import '../local/datasources/local_data_source.dart';
import '../mock/datasources/mock_data_source.dart';
import '../remote/datasources/remote_data_source.dart';

class ServiceRequestRepository {
  ServiceRequestRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  /// Fetches service requests (currently uses Mock Data)
  Future<List<ServiceRequestModel>> getCustomerRequests(int customerId) async {
    return MockDataSource.serviceRequests
        .where((req) => req.customerId == customerId)
        .toList();
  }

  /// Creates a new service request and assigns a ticket number
  Future<ServiceRequestModel> createServiceRequest(
      ServiceRequestModel request) async {
    // Generate ticket number: REQ-YYYYMM-XXX
    final now = DateTime.now();
    final yearMonth =
        '${now.year}${now.month.toString().padLeft(2, '0')}';
    
    // Find highest existing sequence for this month
    int nextSeq = 1;
    final currentMonthRequests = MockDataSource.serviceRequests.where(
        (r) => r.ticketNumber.startsWith('REQ-$yearMonth-'));
    
    for (var r in currentMonthRequests) {
      final parts = r.ticketNumber.split('-');
      if (parts.length == 3) {
        final seq = int.tryParse(parts[2]);
        if (seq != null && seq >= nextSeq) {
          nextSeq = seq + 1;
        }
      }
    }
    
    final ticketNumber = 'REQ-$yearMonth-${nextSeq.toString().padLeft(3, '0')}';
    
    // Assign ID (mock)
    final newId = MockDataSource.serviceRequests.isEmpty
        ? 1
        : MockDataSource.serviceRequests.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;

    final newRequest = request.copyWith(
      id: newId,
      ticketNumber: ticketNumber,
      status: 'Pending',
      createdAt: now,
    );

    // Save to mock database
    MockDataSource.serviceRequests.add(newRequest);

    // Persist to local SQLite
    await localDataSource.insertServiceRequest(newRequest);

    return newRequest;
  }
}
