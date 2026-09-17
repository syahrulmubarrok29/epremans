import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:epremans/features/service_report/presentation/controllers/service_report_form_controller.dart';
import 'package:epremans/routes/app_router.dart';

class SRStartServiceScreen extends ConsumerStatefulWidget {
  const SRStartServiceScreen({super.key, required this.taskId});
  final int taskId;

  @override
  ConsumerState<SRStartServiceScreen> createState() => _SRStartServiceScreenState();
}

class _SRStartServiceScreenState extends ConsumerState<SRStartServiceScreen> {
  void _onStartService() {
    final now = DateTime.now();
    ref.read(serviceReportFormProvider.notifier).updateServiceBegin(now);

    context.pushNamed(
      AppRoutes.srProblemSolution,
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
      appBar: AppBar(title: const Text('2. Start Service')),
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
            const Spacer(),
            ElevatedButton(
              onPressed: _onStartService,
              child: const Text('START SERVICE'),
            ),
          ],
        ),
      ),
    );
  }
}
