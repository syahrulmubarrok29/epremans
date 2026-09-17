import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/data_providers.dart';
import '../../../routes/app_router.dart';
import 'controllers/technician_tasks_controller.dart';

class TechnicianTasksScreen extends ConsumerStatefulWidget {
  const TechnicianTasksScreen({super.key});

  @override
  ConsumerState<TechnicianTasksScreen> createState() =>
      _TechnicianTasksScreenState();
}

class _TechnicianTasksScreenState extends ConsumerState<TechnicianTasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  void _load() {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user != null) {
      ref.read(technicianTasksControllerProvider.notifier).loadTasks(user.id);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Assigned':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(technicianTasksControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        leading: BackButton(
          onPressed: () => context.goNamed(AppRoutes.technicianDashboard),
        ),
      ),
      body: tasksState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('Failed to load tasks.\n$e',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.assignment_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No tasks assigned to you.',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      onPressed: _load, child: const Text('Refresh')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final statusColor = _statusColor(task.status);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withAlpha(30),
                      child: Icon(Icons.assignment_rounded,
                          color: statusColor),
                    ),
                    title: Text(
                      '${task.equipmentBrand ?? ''} ${task.equipmentModel ?? ''}'.trim(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.customerName != null)
                          Text(task.customerName!,
                              style: const TextStyle(fontSize: 12)),
                        Text(task.assignedAt.toString().substring(0, 16),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(task.status,
                          style: TextStyle(
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.bold)),
                      backgroundColor: statusColor.withAlpha(20),
                      side: BorderSide(color: statusColor.withAlpha(80)),
                    ),
                    onTap: () => context.pushNamed(
                      AppRoutes.technicianTaskDetail,
                      pathParameters: {'id': task.id.toString()},
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
