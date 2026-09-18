import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_time_utils.dart';
import '../../../data/providers/data_providers.dart';
import '../../../routes/app_router.dart';
import 'controllers/quotation_request_controller.dart';

class QuotationRequestListScreen extends ConsumerStatefulWidget {
  const QuotationRequestListScreen({super.key});

  @override
  ConsumerState<QuotationRequestListScreen> createState() => _QuotationRequestListScreenState();
}

class _QuotationRequestListScreenState extends ConsumerState<QuotationRequestListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authControllerProvider).valueOrNull;
      if (user != null) {
        ref.read(quotationRequestControllerProvider.notifier).loadRequests(user.id);
      }
    });
  }

  Future<void> _refresh() async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;
    await ref.read(quotationRequestControllerProvider.notifier).refreshRequests(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final state = ref.watch(quotationRequestControllerProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in first.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Quotation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Request Quotation',
            onPressed: () => context.goNamed(AppRoutes.technicianQuotationForm),
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
                : state.requests.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No quotation requests yet. Create one for an active technician task.'),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.requests.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final request = state.requests[index];
                          return Card(
                            child: ListTile(
                              title: Text(request.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text('Status: ${request.status}'),
                                  Text('Estimated Cost: ${CurrencyUtils.formatIdr(request.estimatedCost)}'),
                                  Text('Created: ${DateTimeUtils.formatDate(request.createdAt)}'),
                                ],
                              ),
                              onTap: () => context.goNamed(
                                AppRoutes.technicianQuotationDetail,
                                pathParameters: {'id': request.id.toString()},
                              ),
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed(AppRoutes.technicianQuotationForm),
        child: const Icon(Icons.add),
      ),
    );
  }
}
