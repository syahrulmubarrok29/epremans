import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/app_router.dart';
import 'controllers/customer_dashboard_controller.dart';

class CustomerRequestDetailScreen extends ConsumerWidget {
  const CustomerRequestDetailScreen({super.key, required this.requestId});
  final int requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In Phase 4, we use customerRequestsProvider for local mock data
    final requests = ref.watch(customerRequestsProvider(1)).valueOrNull ?? [];
    final reqIndex = requests.indexWhere((r) => r.id == requestId);
    
    if (reqIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Request Detail')),
        body: const Center(child: Text('Request not found.')),
      );
    }
    
    final req = requests[reqIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Request Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(req.ticketNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Chip(label: Text(req.status)),
                      ],
                    ),
                    const Divider(),
                    Text('Equipment: ${req.equipmentBrand} ${req.equipmentModel}'),
                    const SizedBox(height: 12),
                    const Text('Problem Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(req.problemDescription),
                  ],
                ),
              ),
            ),
            if (req.technicianId != null) ...[
              const SizedBox(height: 24),
              const Text('Assigned Technician', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(req.technicianName ?? 'Technician'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      context.pushNamed(
                        AppRoutes.customerTechnicianTracking,
                        pathParameters: {'id': req.id.toString()},
                      );
                    },
                    child: const Text('Track'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
