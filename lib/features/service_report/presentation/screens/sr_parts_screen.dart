import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:epremans/features/service_report/presentation/controllers/service_report_form_controller.dart';
import 'package:epremans/models/service_report_part_model.dart';
import 'package:epremans/routes/app_router.dart';

class SRPartsScreen extends ConsumerStatefulWidget {
  const SRPartsScreen({super.key, required this.taskId});
  final int taskId;

  @override
  ConsumerState<SRPartsScreen> createState() => _SRPartsScreenState();
}

class _SRPartsScreenState extends ConsumerState<SRPartsScreen> {
  void _addPart() async {
    final newPart = await showDialog<ServiceReportPartModel>(
      context: context,
      builder: (context) => const _AddPartDialog(),
    );
    if (newPart != null) {
      ref.read(serviceReportFormProvider.notifier).addPart(newPart);
    }
  }

  void _onNext() {
    context.pushNamed(
      AppRoutes.srCost,
      pathParameters: {'taskId': widget.taskId.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(serviceReportFormProvider);
    final parts = reportState?.parts ?? [];
    final total = reportState?.partsTotal ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('4. Parts')),
      body: Column(
        children: [
          Expanded(
            child: parts.isEmpty
                ? const Center(child: Text('No parts added.'))
                : ListView.builder(
                    itemCount: parts.length,
                    itemBuilder: (context, index) {
                      final part = parts[index];
                      return ListTile(
                        title: Text('${part.partNumber} - ${part.partDescription}'),
                        subtitle: Text('Qty: ${part.quantity} | Unit Price: \$${part.unitPrice.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            ref.read(serviceReportFormProvider.notifier).removePart(index);
                          },
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Parts Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _addPart,
                    child: const Text('ADD PART'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onNext,
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _AddPartDialog extends StatefulWidget {
  const _AddPartDialog();

  @override
  State<_AddPartDialog> createState() => _AddPartDialogState();
}

class _AddPartDialogState extends State<_AddPartDialog> {
  final _formKey = GlobalKey<FormState>();
  final _partNoCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final part = ServiceReportPartModel(
        id: 0, // 0 for unsaved
        serviceReportId: 0,
        partNumber: _partNoCtrl.text,
        partDescription: _descCtrl.text,
        quantity: int.parse(_qtyCtrl.text),
        unitPrice: double.parse(_priceCtrl.text),
      );
      Navigator.of(context).pop(part);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Part'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _partNoCtrl,
                decoration: const InputDecoration(labelText: 'Part Number'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _qtyCtrl,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (int.tryParse(val) == null) return 'Invalid integer';
                  return null;
                },
              ),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Unit Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null) return 'Invalid number';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _onSave, child: const Text('Add')),
      ],
    );
  }
}
