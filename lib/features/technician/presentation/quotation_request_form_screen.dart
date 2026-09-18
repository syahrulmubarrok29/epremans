import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/exceptions/app_exception.dart';
import '../../../data/providers/data_providers.dart';
import '../../../models/quotation_request_model.dart';
import '../../../routes/app_router.dart';
import 'controllers/quotation_request_controller.dart';

class QuotationRequestFormScreen extends ConsumerStatefulWidget {
  const QuotationRequestFormScreen({super.key, this.requestId});

  final int? requestId;

  @override
  ConsumerState<QuotationRequestFormScreen> createState() => _QuotationRequestFormScreenState();
}

class _QuotationRequestFormScreenState extends ConsumerState<QuotationRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedCostController = TextEditingController();
  final _relatedTaskController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (widget.requestId != null) {
      try {
        final request = await ref
            .read(quotationRequestRepositoryProvider)
            .getQuotationRequestById(widget.requestId!, user.id);
        if (mounted) {
          _relatedTaskController.text = request.relatedTaskId.toString();
          _titleController.text = request.title;
          _descriptionController.text = request.description;
          _estimatedCostController.text = request.estimatedCost.toString();
          setState(() => _isLoading = false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e is AppException ? e.message : 'Unable to load quotation request.')),
          );
          setState(() => _isLoading = false);
        }
      }
    } else {
      _relatedTaskController.text = '1';
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first.')));
      return;
    }

    final taskId = int.tryParse(_relatedTaskController.text.trim());
    final cost = double.tryParse(_estimatedCostController.text.trim());

    if (taskId == null || taskId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Related task is required.')));
      return;
    }

    if (cost == null || cost < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estimated cost must be a valid non-negative number.')));
      return;
    }

    final now = DateTime.now();
    final model = QuotationRequestModel(
      id: widget.requestId ?? 0,
      technicianId: user.id,
      relatedTaskId: taskId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      estimatedCost: cost,
      status: 'Draft',
      createdAt: now,
      updatedAt: now,
    );

    try {
      if (widget.requestId == null) {
        await ref.read(quotationRequestControllerProvider.notifier).createRequest(user.id, model);
      } else {
        final existing = await ref.read(quotationRequestRepositoryProvider).getQuotationRequestById(widget.requestId!, user.id);
        await ref.read(quotationRequestControllerProvider.notifier).updateRequest(
          user.id,
          existing.copyWith(
            relatedTaskId: taskId,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            estimatedCost: cost,
            updatedAt: now,
          ),
        );
      }

      if (mounted) {
        context.goNamed(AppRoutes.technicianQuotation);
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to save quotation request.')));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedCostController.dispose();
    _relatedTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.requestId == null ? 'Create Quotation Request' : 'Edit Quotation Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _relatedTaskController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Related Task ID'),
                validator: (value) {
                  final parsed = int.tryParse(value?.trim() ?? '');
                  if (parsed == null || parsed <= 0) return 'Related task is required.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Description is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _estimatedCostController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Estimated Cost'),
                validator: (value) {
                  final parsed = double.tryParse(value?.trim() ?? '');
                  if (parsed == null || parsed < 0) return 'Estimated cost must be a valid non-negative number.';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.requestId == null ? 'Save Request' : 'Update Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
