import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:signature/signature.dart';
import 'package:epremans/features/service_report/presentation/controllers/service_report_form_controller.dart';
import 'package:epremans/routes/app_router.dart';

class SRSignatureScreen extends ConsumerStatefulWidget {
  const SRSignatureScreen({super.key, required this.taskId});
  final int taskId;

  @override
  ConsumerState<SRSignatureScreen> createState() => _SRSignatureScreenState();
}

class _SRSignatureScreenState extends ConsumerState<SRSignatureScreen> {
  final _techSigController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );
  final _custSigController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _techSigController.dispose();
    _custSigController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (_techSigController.isEmpty || _custSigController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both Technician and Customer signatures are required.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final techBytes = await _techSigController.toPngBytes();
      final custBytes = await _custSigController.toPngBytes();

      if (techBytes == null || custBytes == null) throw Exception('Failed to generate signature images.');

      final techBase64 = base64Encode(techBytes);
      final custBase64 = base64Encode(custBytes);

      ref.read(serviceReportFormProvider.notifier).updateSignatures(
        technicianSignatureData: techBase64,
        customerSignatureData: custBase64,
      );

      if (mounted) {
        context.pushNamed(
          AppRoutes.srReview,
          pathParameters: {'taskId': widget.taskId.toString()},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildSignaturePad(String title, SignatureController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => controller.clear(),
              child: const Text('Clear'),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Signature(
              controller: controller,
              height: 150,
              backgroundColor: Colors.grey.shade100,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('7. Digital Signature')),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSignaturePad('Technician Signature', _techSigController),
                  const SizedBox(height: 24),
                  _buildSignaturePad('Customer Signature', _custSigController),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _onNext,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
    );
  }
}
