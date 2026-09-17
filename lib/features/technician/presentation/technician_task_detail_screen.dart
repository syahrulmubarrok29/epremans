import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/data_providers.dart';
import '../../../data/repositories/technician_task_repository.dart';
import '../../../routes/app_router.dart';
import 'controllers/technician_task_detail_controller.dart';

class TechnicianTaskDetailScreen extends ConsumerStatefulWidget {
  const TechnicianTaskDetailScreen({super.key, required this.taskId});
  final int taskId;

  @override
  ConsumerState<TechnicianTaskDetailScreen> createState() =>
      _TechnicianTaskDetailScreenState();
}

class _TechnicianTaskDetailScreenState
    extends ConsumerState<TechnicianTaskDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(technicianTaskDetailControllerProvider.notifier)
          .loadTask(widget.taskId);
    });
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

  Future<void> _handleStatusUpdate(String newStatus) async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;
    final success = await ref
        .read(technicianTaskDetailControllerProvider.notifier)
        .updateStatus(newStatus, user.id);
    if (!mounted) return;
    final state = ref.read(technicianTaskDetailControllerProvider);
    if (success && state.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.successMessage!),
              backgroundColor: Colors.green));
    } else if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!),
              backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(technicianTaskDetailControllerProvider);

    if (detailState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (detailState.task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Detail')),
        body: Center(
          child: Text(detailState.errorMessage ?? 'Task not found.'),
        ),
      );
    }

    final task = detailState.task!;
    final statusColor = _statusColor(task.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Task Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withAlpha(80)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: statusColor),
                  const SizedBox(width: 8),
                  Text('Status: ${task.status}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: statusColor)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer info
            _InfoCard(title: 'Customer Information', items: [
              _InfoItem(label: 'Customer', value: task.customerName ?? '-'),
              _InfoItem(label: 'Address', value: task.customerAddress ?? '-'),
            ]),
            const SizedBox(height: 12),

            // Equipment info
            _InfoCard(title: 'Equipment Information', items: [
              _InfoItem(label: 'Brand', value: task.equipmentBrand ?? '-'),
              _InfoItem(label: 'Type / Model', value: task.equipmentModel ?? '-'),
            ]),
            const SizedBox(height: 12),

            // Problem info
            _InfoCard(title: 'Problem Description', items: [
              _InfoItem(label: 'Description', value: task.problemDescription ?? '-'),
              _InfoItem(
                  label: 'Assigned At',
                  value: task.assignedAt.toString().substring(0, 16)),
            ]),
            const SizedBox(height: 24),

            // Equipment verification
            if (task.status == TechnicianTaskRepository.statusAssigned) ...[
              Card(
                color: detailState.isEquipmentVerified
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                child: ListTile(
                  leading: Icon(
                    detailState.isEquipmentVerified
                        ? Icons.verified_rounded
                        : Icons.qr_code_scanner_rounded,
                    color: detailState.isEquipmentVerified
                        ? Colors.green
                        : Colors.orange,
                  ),
                  title: Text(
                    detailState.isEquipmentVerified
                        ? 'Equipment Verified'
                        : 'Equipment Not Verified',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: detailState.isEquipmentVerified
                            ? Colors.green
                            : Colors.orange),
                  ),
                  subtitle: detailState.isEquipmentVerified
                      ? null
                      : const Text('Tap to scan and verify the equipment QR code.'),
                  trailing: detailState.isEquipmentVerified
                      ? null
                      : ElevatedButton(
                          onPressed: () async {
                            final result = await context.pushNamed<bool>(
                              AppRoutes.technicianQrScan,
                              extra: task.id,
                            );
                            if (result == true && mounted) {
                              ref
                                  .read(technicianTaskDetailControllerProvider.notifier)
                                  .markEquipmentVerified();
                            }
                          },
                          child: const Text('Scan QR'),
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Status action buttons
            if (detailState.allowedNextStatuses.isNotEmpty) ...[
              const Divider(),
              const Text('Update Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              ...detailState.allowedNextStatuses.map((nextStatus) {
                final isVerificationRequired =
                    nextStatus == TechnicianTaskRepository.statusInProgress &&
                        !detailState.isEquipmentVerified;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton(
                    onPressed: detailState.isUpdating || isVerificationRequired
                        ? null
                        : () => _handleStatusUpdate(nextStatus),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: nextStatus == 'Cancelled'
                          ? Colors.red
                          : null,
                    ),
                    child: detailState.isUpdating
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isVerificationRequired
                                ? '$nextStatus (Verify equipment first)'
                                : 'Mark as $nextStatus',
                          ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.items});
  final String title;
  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const Divider(),
            ...items,
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
