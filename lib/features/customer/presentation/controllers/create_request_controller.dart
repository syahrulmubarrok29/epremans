import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/data_providers.dart';
import '../../../../models/service_request_model.dart';
import 'customer_dashboard_controller.dart';

class CreateRequestController extends StateNotifier<AsyncValue<void>> {
  CreateRequestController(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<bool> createRequest(ServiceRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(serviceRequestRepositoryProvider);
      await repo.createServiceRequest(request);
      
      // Invalidate the request list so it refreshes
      ref.invalidate(customerRequestsProvider(request.customerId));
      
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final createRequestControllerProvider =
    StateNotifierProvider<CreateRequestController, AsyncValue<void>>((ref) {
  return CreateRequestController(ref);
});
