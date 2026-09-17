import '../../models/customer_notification_model.dart';
import '../mock/datasources/mock_data_source.dart';

class CustomerNotificationRepository {
  /// Fetches notifications for a customer
  Future<List<CustomerNotificationModel>> getCustomerNotifications(
      int customerId) async {
    // In Phase 4, we use MockDataSource directly for notifications
    final notifications = MockDataSource.customerNotifications
        .where((n) => n.customerId == customerId)
        .toList();
    
    // Sort by createdAt descending
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  /// Marks all notifications as read for a customer
  Future<void> markAllAsRead(int customerId) async {
    for (int i = 0; i < MockDataSource.customerNotifications.length; i++) {
      if (MockDataSource.customerNotifications[i].customerId == customerId &&
          !MockDataSource.customerNotifications[i].isRead) {
        MockDataSource.customerNotifications[i] =
            MockDataSource.customerNotifications[i].copyWith(isRead: true);
      }
    }
  }

  /// Marks a specific notification as read
  Future<void> markAsRead(int notificationId) async {
    final index = MockDataSource.customerNotifications
        .indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      MockDataSource.customerNotifications[index] =
          MockDataSource.customerNotifications[index].copyWith(isRead: true);
    }
  }
}
