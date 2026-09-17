import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:epremans/features/service_report/presentation/controllers/service_report_form_controller.dart';
import 'package:epremans/routes/app_router.dart';

class SRReviewScreen extends ConsumerStatefulWidget {
  const SRReviewScreen({super.key, required this.taskId});
  final int taskId;

  @override
  ConsumerState<SRReviewScreen> createState() => _SRReviewScreenState();
}

class _SRReviewScreenState extends ConsumerState<SRReviewScreen> {
  bool _isSubmitting = false;

  Future<void> _onSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(serviceReportFormProvider.notifier).submitReport();
      if (mounted) {
        // Go to completed screen
        context.goNamed(
          AppRoutes.srCompleted,
          pathParameters: {'taskId': widget.taskId.toString()},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(serviceReportFormProvider);

    if (report == null) {
      return const Scaffold(body: Center(child: Text("No active report.")));
    }

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('8. Review')),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader('EQUIPMENT'),
                  _buildRow('Customer', report.customerName),
                  _buildRow('Address', report.customerAddress),
                  _buildRow('Brand', report.brand),
                  _buildRow('Type/Model', report.typeModel),
                  _buildRow('Serial Number', report.serialNumber),
                  _buildRow('Location', report.location),
                  _buildRow('Service Type', report.serviceType),
                  const Divider(),

                  _buildSectionHeader('SERVICE'),
                  _buildRow('Service Begin', report.serviceBegin != null ? dateFormat.format(report.serviceBegin!) : '-'),
                  _buildRow('Service End', report.serviceEnd != null ? dateFormat.format(report.serviceEnd!) : '-'),
                  const Divider(),

                  _buildSectionHeader('PROBLEM / SOLUTION'),
                  _buildRow('Problem', report.problem ?? '-'),
                  _buildRow('Solutions', report.solutions ?? '-'),
                  _buildRow('Remarks', report.remarks ?? '-'),
                  _buildRow('Work Status', report.workStatus ?? '-'),
                  const Divider(),

                  _buildSectionHeader('PARTS'),
                  if (report.parts.isEmpty)
                    const Text('No parts used.')
                  else
                    ...report.parts.map((p) => _buildRow('${p.partNumber} (${p.quantity}x)', '\$${p.total.toStringAsFixed(2)}')),
                  _buildRow('Parts Total', '\$${report.partsTotal.toStringAsFixed(2)}'),
                  const Divider(),

                  _buildSectionHeader('COST'),
                  _buildRow('Labor Subtotal', '\$${report.laborSubtotal.toStringAsFixed(2)}'),
                  _buildRow('Travel Subtotal', '\$${report.travelSubtotal.toStringAsFixed(2)}'),
                  _buildRow('Parts Total', '\$${report.partsTotal.toStringAsFixed(2)}'),
                  _buildRow('Travel Cost', '\$${report.travelCost?.toStringAsFixed(2) ?? '0.00'}'),
                  _buildRow('Others Cost', '\$${report.othersCost?.toStringAsFixed(2) ?? '0.00'}'),
                  _buildRow('TOTAL COST', '\$${report.totalCost.toStringAsFixed(2)}'),
                  const Divider(),

                  _buildSectionHeader('SIGNATURE'),
                  const Text('Technician Signature:', style: TextStyle(color: Colors.grey)),
                  if (report.technicianSignatureData != null)
                    Image.memory(base64Decode(report.technicianSignatureData!), height: 60, alignment: Alignment.centerLeft),
                  const SizedBox(height: 8),
                  const Text('Customer Signature:', style: TextStyle(color: Colors.grey)),
                  if (report.customerSignatureData != null)
                    Image.memory(base64Decode(report.customerSignatureData!), height: 60, alignment: Alignment.centerLeft),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('SUBMIT SERVICE REPORT'),
                  ),
                ],
              ),
            ),
    );
  }
}
