import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/data_providers.dart';
import '../../../../models/service_request_model.dart';

/// Fetches service requests for the given customer ID
final customerRequestsProvider =
    FutureProvider.family<List<ServiceRequestModel>, int>((ref, customerId) async {
  final repository = ref.watch(serviceRequestRepositoryProvider);
  final requests = await repository.getCustomerRequests(customerId);
  // Sort by created descending
  requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return requests;
});

class CustomerDashboardController extends StateNotifier<AsyncValue<void>> {
  CustomerDashboardController(this.ref) : super(const AsyncValue.data(null));
  
  final Ref ref;

  Future<void> refreshDashboard(int customerId) async {
    state = const AsyncValue.loading();
    try {
      // Refresh requests
      ref.invalidate(customerRequestsProvider(customerId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final customerDashboardControllerProvider =
    StateNotifierProvider<CustomerDashboardController, AsyncValue<void>>((ref) {
  return CustomerDashboardController(ref);
});
