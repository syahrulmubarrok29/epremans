import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/app_router.dart';
import 'controllers/customer_notifications_controller.dart';

class CustomerNotificationsScreen extends ConsumerWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerId = 1;
    final notificationsAsync = ref.watch(customerNotificationsProvider(customerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark all as read',
            onPressed: () {
              ref.read(customerNotificationsControllerProvider.notifier).markAllAsRead(customerId);
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications.'));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              return ListTile(
                tileColor: n.isRead ? null : Colors.blue.withAlpha(20),
                leading: Icon(
                  n.isRead ? Icons.notifications_none : Icons.notifications_active,
                  color: n.isRead ? Colors.grey : Colors.blue,
                ),
                title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(n.message),
                onTap: () {
                  if (!n.isRead) {
                    ref.read(customerNotificationsControllerProvider.notifier).markAsRead(customerId, n.id);
                  }
                  if (n.serviceRequestId != null) {
                    context.pushNamed(
                      AppRoutes.customerRequestDetail,
                      pathParameters: {'id': n.serviceRequestId.toString()},
                    );
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
