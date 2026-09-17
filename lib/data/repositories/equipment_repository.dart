import '../../models/equipment_model.dart';
import '../local/datasources/local_data_source.dart';
import '../mock/datasources/mock_data_source.dart';
import '../remote/datasources/remote_data_source.dart';

class EquipmentRepository {
  EquipmentRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;

  /// Fetches equipment by ID (Checks Mock, then Local)
  Future<EquipmentModel?> getEquipmentById(int id) async {
    // 1. Try mock data (Phase 2)
    try {
      final mock = MockDataSource.equipment.firstWhere((e) => e.id == id);
      return mock;
    } catch (_) {}

    // 2. Try local SQLite
    return await localDataSource.getEquipmentById(id);
  }

  /// Synchronize equipment from mock/remote into local SQLite
  Future<void> syncEquipmentToLocal(EquipmentModel equipment) async {
    await localDataSource.insertEquipment(equipment);
  }

  /// Fetches equipment by QR Code (Checks Mock, then Local)
  Future<EquipmentModel?> getEquipmentByQrCode(String qrCode) async {
    // 1. Try mock data
    try {
      final mock = MockDataSource.equipment.firstWhere((e) => e.qrCode == qrCode);
      return mock;
    } catch (_) {}

    // 2. Try local SQLite
    return await localDataSource.getEquipmentByQrCode(qrCode);
  }
}
