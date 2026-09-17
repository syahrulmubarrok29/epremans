import 'package:flutter_test/flutter_test.dart';
import 'package:epremans/models/service_request_model.dart';
import 'package:epremans/data/mock/datasources/mock_data_source.dart';
import 'package:epremans/data/repositories/service_request_repository.dart';
import 'package:epremans/data/remote/datasources/remote_data_source.dart';
import 'package:epremans/data/remote/datasources/api_client.dart';
import 'package:epremans/data/repositories/equipment_repository.dart';
import 'package:epremans/data/local/datasources/local_data_source.dart';
import 'package:epremans/data/local/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Customer Feature - Phase 4 Logic', () {
    late ServiceRequestRepository serviceRequestRepo;
    late EquipmentRepository equipmentRepo;
    late RemoteDataSource remoteDataSource;
    late LocalDataSource localDataSource;

    setUp(() {
      remoteDataSource = RemoteDataSource(ApiClient.getDio());
      localDataSource = LocalDataSource();
      serviceRequestRepo = ServiceRequestRepository(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
      );
      equipmentRepo = EquipmentRepository(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
      );
    });

    test('Equipment QR Lookup - valid QR', () async {
      final equipment = await equipmentRepo.getEquipmentByQrCode('QR-POLARIS-001');
      expect(equipment, isNotNull);
      expect(equipment!.brand, 'Polaris');
      expect(equipment.typeModel, 'X-Ray 5000');
    });

    test('Equipment QR Lookup - invalid QR', () async {
      final equipment = await equipmentRepo.getEquipmentByQrCode('INVALID-QR');
      expect(equipment, isNull);
    });

    test('Create Damage Report generates ticket', () async {
      // Insert prerequisites for Foreign Key constraints (OR IGNORE for re-runs)
      await localDataSource.getEquipmentByQrCode('NONE'); // ensures DB is initialised
      final database = await AppDatabase.instance.database;
      await database.insert('customers', {
        'id': 1, 'name': 'C', 'address': 'A', 'phone': 'P', 'contact_person': 'CP'
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      await database.insert('equipment', {
        'id': 1, 'brand': 'B', 'type_model': 'TM', 'serial_number': 'SN', 'location': 'L', 'customer_id': 1
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      final initialCount = MockDataSource.serviceRequests.length;
      final req = ServiceRequestModel(
        id: 0,
        ticketNumber: '',
        customerId: 1,
        equipmentId: 1,
        problemDescription: 'Screen is cracked',
        status: 'Pending',
        createdAt: DateTime.now(),
      );

      final newReq = await serviceRequestRepo.createServiceRequest(req);

      expect(newReq.ticketNumber, isNotNull);
      expect(newReq.ticketNumber.startsWith('REQ-'), true);
      expect(MockDataSource.serviceRequests.length, initialCount + 1);
    });
  });
}
