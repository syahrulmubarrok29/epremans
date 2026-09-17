import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:epremans/features/service_report/presentation/controllers/service_report_form_controller.dart';
import 'package:epremans/data/providers/data_providers.dart';
import 'package:epremans/models/service_report_model.dart';
import 'package:epremans/routes/app_router.dart';

class SREquipmentInfoScreen extends ConsumerStatefulWidget {
  const SREquipmentInfoScreen({super.key, required this.taskId});
  
  final int taskId;

  @override
  ConsumerState<SREquipmentInfoScreen> createState() => _SREquipmentInfoScreenState();
}

class _SREquipmentInfoScreenState extends ConsumerState<SREquipmentInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _customerNameCtrl = TextEditingController();
  final _customerAddressCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _typeModelCtrl = TextEditingController();
  final _serialNumberCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _serviceType = 'Preventive';
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    try {
      // We get the technician ID from the current user
      final currentUser = ref.read(authControllerProvider).valueOrNull;
      if (currentUser == null) throw Exception("Technician not authenticated");
      
      // Initialize the report state
      ref.read(serviceReportFormProvider.notifier).initializeReport(
        taskId: widget.taskId,
        technicianId: currentUser.id,
      );

      // Now we populate fields. Let's get mock data if possible
      // This is a simplification for Phase 6. We can just use the task details.
      // Let's assume we can resolve the equipment and customer from the task.
      // We'll leave them empty if we can't find them, so the user can fill them.
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      ref.read(serviceReportFormProvider.notifier).updateEquipmentInfo(
        customerName: _customerNameCtrl.text,
        customerAddress: _customerAddressCtrl.text,
        brand: _brandCtrl.text,
        typeModel: _typeModelCtrl.text,
        serialNumber: _serialNumberCtrl.text,
        location: _locationCtrl.text,
        serviceType: _serviceType,
      );
      
      context.pushNamed(
        AppRoutes.srStartService,
        pathParameters: {'taskId': widget.taskId.toString()},
      );
    }
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerAddressCtrl.dispose();
    _brandCtrl.dispose();
    _typeModelCtrl.dispose();
    _serialNumberCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Equipment Info')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('1. Equipment Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _customerNameCtrl,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _customerAddressCtrl,
                decoration: const InputDecoration(labelText: 'Customer Address'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandCtrl,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeModelCtrl,
                decoration: const InputDecoration(labelText: 'Type / Model'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serialNumberCtrl,
                decoration: const InputDecoration(labelText: 'Serial Number'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Location of Equipment'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _serviceType,
                decoration: const InputDecoration(labelText: 'Service Type'),
                items: const [
                  DropdownMenuItem(value: 'Preventive', child: Text('Preventive')),
                  DropdownMenuItem(value: 'Corrective', child: Text('Corrective')),
                  DropdownMenuItem(value: 'Others', child: Text('Others')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _serviceType = val);
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
