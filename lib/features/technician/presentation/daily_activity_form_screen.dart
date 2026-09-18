import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/exceptions/app_exception.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/providers/data_providers.dart';
import '../../../models/daily_activity_model.dart';
import '../../../routes/app_router.dart';
import 'controllers/daily_activity_controller.dart';

class DailyActivityFormScreen extends ConsumerStatefulWidget {
  const DailyActivityFormScreen({super.key, this.activityId});

  final int? activityId;

  @override
  ConsumerState<DailyActivityFormScreen> createState() => _DailyActivityFormScreenState();
}

class _DailyActivityFormScreenState extends ConsumerState<DailyActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  String? _activityType;
  String? _method;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    if (widget.activityId != null) {
      try {
        final activity = await ref
            .read(dailyActivityRepositoryProvider)
            .getActivityById(widget.activityId!, user.id);
        if (mounted) {
          _titleCtrl.text = activity.title;
          _descriptionCtrl.text = activity.description;
          _dateCtrl.text = DateTimeUtils.toIso(activity.activityDate);
          _activityType = activity.activityType;
          _method = activity.method;
          setState(() => _isLoading = false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e is AppException ? e.message : 'Unable to load activity.')),
          );
          setState(() => _isLoading = false);
        }
      }
    } else {
      _dateCtrl.text = DateTimeUtils.toIso(DateTime.now());
      _activityType = DailyActivityModel.activityTypes.first;
      _method = DailyActivityModel.methods.first;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateCtrl.text.isNotEmpty ? DateTime.tryParse(_dateCtrl.text) ?? now : now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      _dateCtrl.text = DateTimeUtils.toIso(picked);
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first.')));
      return;
    }

    final parsedDate = DateTime.tryParse(_dateCtrl.text);
    if (parsedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activity date is required.')));
      return;
    }

    final now = DateTime.now();
    final model = DailyActivityModel(
      id: widget.activityId ?? 0,
      technicianId: user.id,
      activityType: _activityType ?? '',
      method: _method ?? '',
      activityDate: parsedDate,
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    try {
      if (widget.activityId == null) {
        await ref.read(dailyActivityControllerProvider.notifier).createActivity(user.id, model);
      } else {
        final existing = await ref.read(dailyActivityRepositoryProvider).getActivityById(widget.activityId!, user.id);
        await ref.read(dailyActivityControllerProvider.notifier).updateActivity(
          user.id,
          existing.copyWith(
            activityType: _activityType,
            method: _method,
            activityDate: parsedDate,
            title: _titleCtrl.text.trim(),
            description: _descriptionCtrl.text.trim(),
            updatedAt: now,
          ),
        );
      }

      if (mounted) {
        context.goNamed(AppRoutes.technicianDailyActivity);
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to save daily activity.')));
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activityId == null ? 'Add Daily Activity' : 'Edit Daily Activity'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _activityType,
                decoration: const InputDecoration(labelText: 'Activity Type'),
                items: DailyActivityModel.activityTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                validator: (value) => value == null || value.isEmpty ? 'Activity Type is required.' : null,
                onChanged: (value) => setState(() => _activityType = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _method,
                decoration: const InputDecoration(labelText: 'Method'),
                items: DailyActivityModel.methods
                    .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                    .toList(),
                validator: (value) => value == null || value.isEmpty ? 'Method is required.' : null,
                onChanged: (value) => setState(() => _method = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Activity Date', suffixIcon: Icon(Icons.calendar_today)),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Activity Date is required.' : null,
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.activityId == null ? 'Save Activity' : 'Update Activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
