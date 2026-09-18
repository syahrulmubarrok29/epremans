import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:epremans/core/utils/cost_calculator.dart';
import 'package:epremans/features/service_report/presentation/controllers/service_report_form_controller.dart';
import 'package:epremans/routes/app_router.dart';

class SRCostScreen extends ConsumerStatefulWidget {
  const SRCostScreen({super.key, required this.taskId});
  final int taskId;

  @override
  ConsumerState<SRCostScreen> createState() => _SRCostScreenState();
}

class _SRCostScreenState extends ConsumerState<SRCostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _laborHrsCtrl = TextEditingController();
  final _laborRateCtrl = TextEditingController();
  final _travelHrsCtrl = TextEditingController();
  final _travelRateCtrl = TextEditingController();
  final _travelCostCtrl = TextEditingController();
  final _othersCostCtrl = TextEditingController();

  double _laborSub = 0.0;
  double _travelSub = 0.0;
  double _partsTotal = 0.0;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    final state = ref.read(serviceReportFormProvider);
    if (state != null) {
      _laborHrsCtrl.text = state.laborTimeHours?.toString() ?? '';
      _laborRateCtrl.text = state.laborRate?.toString() ?? '';
      _travelHrsCtrl.text = state.travelTimeHours?.toString() ?? '';
      _travelRateCtrl.text = state.travelRate?.toString() ?? '';
      _travelCostCtrl.text = state.travelCost?.toString() ?? '';
      _othersCostCtrl.text = state.othersCost?.toString() ?? '';
      _partsTotal = state.partsTotal;
    }

    _laborHrsCtrl.addListener(_updateCalc);
    _laborRateCtrl.addListener(_updateCalc);
    _travelHrsCtrl.addListener(_updateCalc);
    _travelRateCtrl.addListener(_updateCalc);
    _travelCostCtrl.addListener(_updateCalc);
    _othersCostCtrl.addListener(_updateCalc);
    
    _updateCalc();
  }

  void _updateCalc() {
    final lh = double.tryParse(_laborHrsCtrl.text) ?? 0.0;
    final lr = double.tryParse(_laborRateCtrl.text) ?? 0.0;
    final th = double.tryParse(_travelHrsCtrl.text) ?? 0.0;
    final tr = double.tryParse(_travelRateCtrl.text) ?? 0.0;
    final tc = double.tryParse(_travelCostCtrl.text) ?? 0.0;
    final oc = double.tryParse(_othersCostCtrl.text) ?? 0.0;
    final currentParts = ref.read(serviceReportFormProvider)?.parts ?? const [];
    final partsTotal = CostCalculator.calculatePartsTotal(currentParts);

    setState(() {
      _laborSub = CostCalculator.calculateLaborSubtotal(
        laborTimeHours: lh,
        laborRate: lr,
      );
      _travelSub = CostCalculator.calculateTravelSubtotal(
        travelTimeHours: th,
        travelRate: tr,
      );
      _partsTotal = partsTotal;
      _total = CostCalculator.calculateTotalCost(
        laborSubtotal: _laborSub,
        travelSubtotal: _travelSub,
        partsTotal: _partsTotal,
        travelCost: tc,
        othersCost: oc,
      );
    });
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      ref.read(serviceReportFormProvider.notifier).updateCosts(
        laborTimeHours: double.tryParse(_laborHrsCtrl.text),
        laborRate: double.tryParse(_laborRateCtrl.text),
        travelTimeHours: double.tryParse(_travelHrsCtrl.text),
        travelRate: double.tryParse(_travelRateCtrl.text),
        travelCost: double.tryParse(_travelCostCtrl.text),
        othersCost: double.tryParse(_othersCostCtrl.text),
      );

      context.pushNamed(
        AppRoutes.srEndService,
        pathParameters: {'taskId': widget.taskId.toString()},
      );
    }
  }

  @override
  void dispose() {
    _laborHrsCtrl.dispose();
    _laborRateCtrl.dispose();
    _travelHrsCtrl.dispose();
    _travelRateCtrl.dispose();
    _travelCostCtrl.dispose();
    _othersCostCtrl.dispose();
    super.dispose();
  }

  Widget _buildNumericField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('5. Cost')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: _buildNumericField('Labor Hours', _laborHrsCtrl)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildNumericField('Labor Rate (\$)', _laborRateCtrl)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Labor Subtotal: \$${_laborSub.toStringAsFixed(2)}', textAlign: TextAlign.right),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(child: _buildNumericField('Travel Hours', _travelHrsCtrl)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildNumericField('Travel Rate (\$)', _travelRateCtrl)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Travel Subtotal: \$${_travelSub.toStringAsFixed(2)}', textAlign: TextAlign.right),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Parts Total: \$${_partsTotal.toStringAsFixed(2)}', textAlign: TextAlign.right),
              ),
              const Divider(),
              _buildNumericField('Additional Travel Cost (\$)', _travelCostCtrl),
              const SizedBox(height: 16),
              _buildNumericField('Others Cost (\$)', _othersCostCtrl),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL COST:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
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
