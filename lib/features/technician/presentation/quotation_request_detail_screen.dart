import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/exceptions/app_exception.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/providers/data_providers.dart';
import '../../../models/quotation_request_model.dart';
import '../../../routes/app_router.dart';
import 'controllers/quotation_request_controller.dart';

class QuotationRequestDetailScreen extends ConsumerStatefulWidget {
  const QuotationRequestDetailScreen({super.key, required this.requestId});

  final int requestId;

  @override
  ConsumerState<QuotationRequestDetailScreen> createState() => _QuotationRequestDetailScreenState();
}

class _QuotationRequestDetailScreenState extends ConsumerState<QuotationRequestDetailScreen> {
  QuotationRequestModel? _request;
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

    try {
      final request = await ref.read(quotationRequestRepositoryProvider).getQuotationRequestById(widget.requestId, user.id);
      if (mounted) {
        setState(() {
          _request = request;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is AppException ? e.message : 'Failed to load quotation request.')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _delete() async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null || _request == null) return;

    try {
      await ref.read(quotationRequestControllerProvider.notifier).deleteRequest(user.id, _request!.id);
      if (mounted) context.goNamed(AppRoutes.technicianQuotation);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is AppException ? e.message : 'Failed to delete quotation request.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quotation Detail')),
        body: const Center(child: Text('Quotation request not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotation Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.goNamed(
              AppRoutes.technicianQuotationEdit,
              pathParameters: {'id': _request!.id.toString()},
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              _request!.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Status', value: _request!.status),
            _InfoRow(label: 'Related Task ID', value: _request!.relatedTaskId.toString()),
            _InfoRow(label: 'Estimated Cost', value: CurrencyUtils.formatIdr(_request!.estimatedCost)),
            _InfoRow(label: 'Created', value: DateTimeUtils.formatDate(_request!.createdAt)),
            _InfoRow(label: 'Updated', value: DateTimeUtils.formatDate(_request!.updatedAt)),
            const SizedBox(height: 20),
            const Text('Description'),
            const SizedBox(height: 8),
            Text(_request!.description),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
