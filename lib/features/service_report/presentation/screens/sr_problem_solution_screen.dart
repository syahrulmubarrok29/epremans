import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:epremans/features/service_report/presentation/controllers/service_report_form_controller.dart';
import 'package:epremans/routes/app_router.dart';

class SRProblemSolutionScreen extends ConsumerStatefulWidget {
  const SRProblemSolutionScreen({super.key, required this.taskId});
  final int taskId;

  @override
  ConsumerState<SRProblemSolutionScreen> createState() => _SRProblemSolutionScreenState();
}

class _SRProblemSolutionScreenState extends ConsumerState<SRProblemSolutionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _problemCtrl = TextEditingController();
  final _solutionsCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  String _workStatus = 'Work Completed';

  @override
  void initState() {
    super.initState();
    final state = ref.read(serviceReportFormProvider);
    if (state != null) {
      _problemCtrl.text = state.problem ?? '';
      _solutionsCtrl.text = state.solutions ?? '';
      _remarksCtrl.text = state.remarks ?? '';
      _workStatus = state.workStatus ?? 'Work Completed';
    }
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      ref.read(serviceReportFormProvider.notifier).updateProblemSolution(
        problem: _problemCtrl.text,
        solutions: _solutionsCtrl.text,
        remarks: _remarksCtrl.text,
        workStatus: _workStatus,
      );

      context.pushNamed(
        AppRoutes.srParts,
        pathParameters: {'taskId': widget.taskId.toString()},
      );
    }
  }

  @override
  void dispose() {
    _problemCtrl.dispose();
    _solutionsCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3. Problem & Solution')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _problemCtrl,
                decoration: const InputDecoration(labelText: 'Problem', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _solutionsCtrl,
                decoration: const InputDecoration(labelText: 'Solutions', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksCtrl,
                decoration: const InputDecoration(labelText: 'Remarks (Optional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _workStatus,
                decoration: const InputDecoration(labelText: 'Work Status'),
                items: const [
                  DropdownMenuItem(value: 'Work Completed', child: Text('Work Completed')),
                  DropdownMenuItem(value: 'Work Incompleted', child: Text('Work Incompleted')),
                  DropdownMenuItem(value: 'Parts Still Required', child: Text('Parts Still Required')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _workStatus = val);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _onNext,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
