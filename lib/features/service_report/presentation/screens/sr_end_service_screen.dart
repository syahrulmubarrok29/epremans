import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:epremans/features/service_report/presentation/controllers/service_report_form_controller.dart';
import 'package:epremans/routes/app_router.dart';

class SREndServiceScreen extends ConsumerStatefulWidget {
  const SREndServiceScreen({super.key, required this.taskId});
  final int taskId;

  @override
  ConsumerState<SREndServiceScreen> createState() => _SREndServiceScreenState();
}

class _SREndServiceScreenState extends ConsumerState<SREndServiceScreen> {
  void _onEndService() {
    final now = DateTime.now();
    ref.read(serviceReportFormProvider.notifier).updateServiceEnd(now);

    context.pushNamed(
      AppRoutes.srSignature,
      pathParameters: {'taskId': widget.taskId.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(serviceReportFormProvider);

    if (reportState == null) {
      return const Scaffold(body: Center(child: Text("No active report.")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('6. End Service')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Target Asset: ${reportState.brand} ${reportState.typeModel}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Serial Number: ${reportState.serialNumber}'),
            const SizedBox(height: 8),
            Text('Location: ${reportState.location}'),
            const SizedBox(height: 32),
            if (reportState.serviceBegin != null)
              Text('Service Began: ${DateFormat('yyyy-MM-dd HH:mm').format(reportState.serviceBegin!)}'),
            const SizedBox(height: 16),
            if (reportState.serviceEnd != null)
              Text('Service Ended: ${DateFormat('yyyy-MM-dd HH:mm').format(reportState.serviceEnd!)}'),
            const Spacer(),
            ElevatedButton(
              onPressed: _onEndService,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
              child: const Text('END SERVICE'),
            ),
          ],
        ),
      ),
    );
  }
}
