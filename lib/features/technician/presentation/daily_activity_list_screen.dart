import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_time_utils.dart';
import '../../../data/providers/data_providers.dart';
import '../../../routes/app_router.dart';
import 'controllers/daily_activity_controller.dart';

class DailyActivityListScreen extends ConsumerStatefulWidget {
  const DailyActivityListScreen({super.key});

  @override
  ConsumerState<DailyActivityListScreen> createState() => _DailyActivityListScreenState();
}

class _DailyActivityListScreenState extends ConsumerState<DailyActivityListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authControllerProvider).valueOrNull;
      if (user != null) {
        ref.read(dailyActivityControllerProvider.notifier).loadActivities(user.id);
      }
    });
  }

  Future<void> _refresh() async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;
    await ref.read(dailyActivityControllerProvider.notifier).refreshActivities(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final state = ref.watch(dailyActivityControllerProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in first.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Activity',
            onPressed: () => context.goNamed(AppRoutes.technicianDailyActivityForm),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 40, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(state.errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : state.activities.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No daily activities yet. Add a new activity to get started.'),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.activities.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final activity = state.activities[index];
                          return Card(
                            child: ListTile(
                              title: Text(activity.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text('Type: ${activity.activityType}'),
                                  Text('Method: ${activity.method}'),
                                  Text('Date: ${DateTimeUtils.formatDate(activity.activityDate)}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    activity.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              onTap: () => context.goNamed(
                                AppRoutes.technicianDailyActivityDetail,
                                pathParameters: {'id': activity.id.toString()},
                              ),
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed(AppRoutes.technicianDailyActivityForm),
        child: const Icon(Icons.add),
      ),
    );
  }
}
