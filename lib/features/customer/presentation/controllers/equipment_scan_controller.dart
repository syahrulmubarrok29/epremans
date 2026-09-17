import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/data_providers.dart';
import '../../../../models/equipment_model.dart';

class EquipmentScanController extends StateNotifier<AsyncValue<EquipmentModel?>> {
  EquipmentScanController(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> scanEquipment(String qrCode) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(equipmentRepositoryProvider);
      final equipment = await repo.getEquipmentByQrCode(qrCode);
      if (equipment != null) {
        state = AsyncValue.data(equipment);
      } else {
        state = AsyncValue.error('Equipment not found for QR Code: $qrCode', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final equipmentScanControllerProvider =
    StateNotifierProvider<EquipmentScanController, AsyncValue<EquipmentModel?>>((ref) {
  return EquipmentScanController(ref);
});
