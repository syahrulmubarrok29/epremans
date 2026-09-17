import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/data_providers.dart';
import '../../../routes/app_router.dart';

class CustomerEquipmentInfoScreen extends ConsumerWidget {
  const CustomerEquipmentInfoScreen({super.key, required this.equipmentId});

  final int equipmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentFuture = ref.watch(equipmentRepositoryProvider).getEquipmentById(equipmentId);

    return Scaffold(
      appBar: AppBar(title: const Text('Equipment Info')),
      body: FutureBuilder(
        future: equipmentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final equipment = snapshot.data;
          if (equipment == null) {
            return const Center(child: Text('Equipment not found.'));
          }

          return SingleChildScrollView(
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
                        _buildInfoRow('Customer', equipment.customerName ?? '-'),
                        _buildInfoRow('Address', equipment.customerAddress ?? '-'),
                        const Divider(),
                        _buildInfoRow('Brand', equipment.brand),
                        _buildInfoRow('Type/Model', equipment.typeModel),
                        _buildInfoRow('Serial Number', equipment.serialNumber),
                        _buildInfoRow('Location', equipment.location),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.pushNamed(
                      AppRoutes.customerCreateRequest,
                      extra: equipment.id,
                    );
                  },
                  child: const Text('Create Damage Report'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
