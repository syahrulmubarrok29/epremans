import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../data/mock/datasources/mock_data_source.dart';
import '../../../data/providers/data_providers.dart';

/// Technician equipment verification QR scanner.
///
/// Receives [taskId] via route extra.
/// Looks up the expected equipment QR for this task via [equipmentRepositoryProvider].
/// Returns `true` to caller on match, `null`/`false` on mismatch or cancel.
class TechnicianQrScanScreen extends ConsumerStatefulWidget {
  const TechnicianQrScanScreen({super.key, required this.taskId});
  final int taskId;

  @override
  ConsumerState<TechnicianQrScanScreen> createState() =>
      _TechnicianQrScanScreenState();
}

class _TechnicianQrScanScreenState
    extends ConsumerState<TechnicianQrScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  String? _expectedQr;

  @override
  void initState() {
    super.initState();
    _loadExpectedQr();
  }

  /// Fetches the expected QR code from the task's linked equipment.
  Future<void> _loadExpectedQr() async {
    try {
      final taskRepo = ref.read(technicianTaskRepositoryProvider);
      final task = await taskRepo.getTaskById(widget.taskId);

      // Resolve equipment via MockDataSource.serviceRequests
      final matchingReq = MockDataSource.serviceRequests.cast<dynamic>().firstWhere(
            (r) => r.id == task.serviceRequestId,
            orElse: () => null,
          );
      if (matchingReq == null) return;

      final eqRepo = ref.read(equipmentRepositoryProvider);
      final equipment = await eqRepo.getEquipmentById(matchingReq.equipmentId as int);
      if (mounted) {
        setState(() => _expectedQr = equipment?.qrCode);
      }
    } catch (_) {}
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      await _processQrCode(barcodes.first.rawValue!);
    }
  }

  Future<void> _processQrCode(String scannedCode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final expectedQr = _expectedQr;

    if (expectedQr != null && scannedCode == expectedQr) {
      // QR MATCH — verification successful
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      // QR MISMATCH
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              expectedQr == null
                  ? 'Could not determine expected equipment QR.'
                  : 'QR Mismatch. Expected equipment QR does not match.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _isProcessing = false);
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
      appBar: AppBar(title: const Text('Verify Equipment')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          // Overlay hint
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _expectedQr != null
                      ? 'Scan QR code for: $_expectedQr'
                      : 'Loading expected equipment QR...',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
          // Dev / Emulator fallback tools
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Emulator/Dev Tools:',
                  style: TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.black54),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    if (_expectedQr != null)
                      ActionChip(
                        label: Text(_expectedQr!),
                        onPressed: () => _processQrCode(_expectedQr!),
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
