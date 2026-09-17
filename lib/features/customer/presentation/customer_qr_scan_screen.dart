import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../routes/app_router.dart';
import 'controllers/equipment_scan_controller.dart';

class CustomerQrScanScreen extends ConsumerStatefulWidget {
  const CustomerQrScanScreen({super.key});

  @override
  ConsumerState<CustomerQrScanScreen> createState() => _CustomerQrScanScreenState();
}

class _CustomerQrScanScreenState extends ConsumerState<CustomerQrScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      _processQrCode(barcodes.first.rawValue!);
    }
  }

  Future<void> _processQrCode(String code) async {
    setState(() => _isProcessing = true);
    final controller = ref.read(equipmentScanControllerProvider.notifier);
    await controller.scanEquipment(code);
    
    final state = ref.read(equipmentScanControllerProvider);
    if (state.hasValue && state.value != null) {
      if (mounted) {
        context.pushReplacementNamed(
          AppRoutes.customerEquipmentInfo,
          extra: state.value!.id,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown QR Code: $code')),
        );
      }
      // Delay before next scan allowed
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Equipment')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text('Emulator/Dev Tools:', style: TextStyle(color: Colors.white, backgroundColor: Colors.black54)),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('QR-POLARIS-001'),
                      onPressed: () => _processQrCode('QR-POLARIS-001'),
                    ),
                    ActionChip(
                      label: const Text('QR-POLARIS-002'),
                      onPressed: () => _processQrCode('QR-POLARIS-002'),
                    ),
                    ActionChip(
                      label: const Text('INVALID-QR'),
                      onPressed: () => _processQrCode('INVALID-QR'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
