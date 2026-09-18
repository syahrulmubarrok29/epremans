import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/exceptions/app_exception.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/providers/data_providers.dart';
import '../../../models/daily_activity_model.dart';
import '../../../routes/app_router.dart';
import 'controllers/daily_activity_controller.dart';

class DailyActivityDetailScreen extends ConsumerStatefulWidget {
  const DailyActivityDetailScreen({super.key, required this.activityId});

  final int activityId;

  @override
  ConsumerState<DailyActivityDetailScreen> createState() => _DailyActivityDetailScreenState();
}

class _DailyActivityDetailScreenState extends ConsumerState<DailyActivityDetailScreen> {
  DailyActivityModel? _activity;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) {
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }

    try {
      final activity = await ref.read(dailyActivityRepositoryProvider).getActivityById(widget.activityId, user.id);
      if (mounted) {
        setState(() {
          _activity = activity;
          _loading = false;
        });
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _deleteActivity() async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null || _activity == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Daily Activity'),
        content: const Text('This activity will be deleted from local storage. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(dailyActivityControllerProvider.notifier).deleteActivity(user.id, _activity!.id);
      if (mounted) context.goNamed(AppRoutes.technicianDailyActivity);
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_activity == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daily Activity')),
        body: const Center(child: Text('Activity not found.')),
      );
    }

    final activity = _activity!;
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Activity Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InfoRow(label: 'Activity Type', value: activity.activityType),
            _InfoRow(label: 'Method', value: activity.method),
            _InfoRow(label: 'Activity Date', value: DateTimeUtils.formatDate(activity.activityDate)),
            _InfoRow(label: 'Title', value: activity.title),
            _InfoRow(label: 'Description', value: activity.description),
            _InfoRow(label: 'Created At', value: DateTimeUtils.formatDateTime(activity.createdAt)),
            _InfoRow(label: 'Updated At', value: DateTimeUtils.formatDateTime(activity.updatedAt)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.goNamed(
                      AppRoutes.technicianDailyActivityEdit,
                      pathParameters: {'id': activity.id.toString()},
                    ),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: _deleteActivity,
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
