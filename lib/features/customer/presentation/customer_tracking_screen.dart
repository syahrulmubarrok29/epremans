import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock/datasources/mock_data_source.dart';

class CustomerTrackingScreen extends ConsumerWidget {
  const CustomerTrackingScreen({super.key, required this.requestId});
  final int requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In Phase 4, look up TechnicianTaskModel from MockDataSource
    final task = MockDataSource.technicianTasks.where((t) => t.serviceRequestId == requestId).firstOrNull;
    
    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Technician Tracking')),
        body: const Center(child: Text('No tracking info found.')),
      );
    }

    final techUser = MockDataSource.users.where((u) => u.id == task.technicianId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Technician Tracking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.directions_car_rounded, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text('Status: ${task.status}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(techUser?.name ?? 'Technician'),
                subtitle: const Text('Assigned Technician'),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Assigned At'),
              subtitle: Text(task.assignedAt.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
