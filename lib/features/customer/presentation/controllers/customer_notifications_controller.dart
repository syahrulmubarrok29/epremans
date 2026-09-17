import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/data_providers.dart';
import '../../../../models/customer_notification_model.dart';

final customerNotificationsProvider = FutureProvider.family<List<CustomerNotificationModel>, int>((ref, customerId) async {
  final repo = ref.watch(customerNotificationRepositoryProvider);
  return repo.getCustomerNotifications(customerId);
});

class CustomerNotificationsController extends StateNotifier<AsyncValue<void>> {
  CustomerNotificationsController(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> markAllAsRead(int customerId) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(customerNotificationRepositoryProvider);
      await repo.markAllAsRead(customerId);
      
      // Refresh the provider
      ref.invalidate(customerNotificationsProvider(customerId));
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(int customerId, int notificationId) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(customerNotificationRepositoryProvider);
      await repo.markAsRead(notificationId);
      
      // Refresh the provider
      ref.invalidate(customerNotificationsProvider(customerId));
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final customerNotificationsControllerProvider =
    StateNotifierProvider<CustomerNotificationsController, AsyncValue<void>>((ref) {
  return CustomerNotificationsController(ref);
});
