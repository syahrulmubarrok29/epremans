import 'package:epremans/data/local/database/database_constants.dart';
import 'package:epremans/data/local/datasources/local_data_source.dart';
import 'package:epremans/models/equipment_model.dart';
import 'package:epremans/models/service_report_model.dart';
import 'package:epremans/models/service_report_part_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late LocalDataSource localDataSource;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseConstants.dbVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await db.execute(DatabaseConstants.createTableUsers);
          await db.execute(DatabaseConstants.createTableCustomers);
          await db.execute(DatabaseConstants.createTableEquipment);
          await db.execute(DatabaseConstants.createTableServiceRequests);
          await db.execute(DatabaseConstants.createTableTechnicianTasks);
          await db.execute(DatabaseConstants.createTableServiceReports);
          await db.execute(DatabaseConstants.createTableServiceReportParts);
        },
      ),
    );

    localDataSource = LocalDataSource(database: db);

    // Insert requisite foreign keys for testing (e.g. Customers and Users)
    await db.insert(DatabaseConstants.tableCustomers, {
      'id': 1,
      'name': 'Customer 1',
      'address': 'Address 1',
    });
    await db.insert(DatabaseConstants.tableUsers, {
      'id': 1,
      'name': 'Tech 1',
      'email': 't@c.com',
      'role': 'technician',
    });
    // Task requires ServiceRequest and Technician
    await db.insert(DatabaseConstants.tableEquipment, {
      'id': 100,
      'brand': 'B',
      'type_model': 'TM',
      'serial_number': 'SN',
      'location': 'L',
      'customer_id': 1,
    });
    await db.insert(DatabaseConstants.tableServiceRequests, {
      'id': 1,
      'ticket_number': 'T-001',
      'customer_id': 1,
      'equipment_id': 100,
      'problem_description': 'P',
      'status': 'Open',
      'created_at': '2026-09-17T00:00:00',
    });
    await db.insert(DatabaseConstants.tableTechnicianTasks, {
      'id': 1,
      'service_request_id': 1,
      'technician_id': 1,
      'assigned_at': '2026-09-17T00:00:00',
      'status': 'Assigned',
    });
  });

  tearDown(() async {
    await db.close();
  });

  group('Equipment CRUD', () {
    test('Can insert and get Equipment', () async {
      final equip = const EquipmentModel(
        id: 1,
        brand: 'Polaris',
        typeModel: 'Type A',
        serialNumber: 'SN-001',
        location: 'Room 1',
        customerId: 1,
      );

      await localDataSource.insertEquipment(equip);

      final result = await localDataSource.getEquipmentById(1);
      expect(result, isNotNull);
      expect(result!.brand, 'Polaris');
      expect(result.serialNumber, 'SN-001');
    });
  });

  group('ServiceReport CRUD', () {
    test('Can insert, read, update, delete ServiceReport with Parts', () async {
      // 1. Create/Insert
      final report = ServiceReportModel(
        id: 0, // Auto-incremented in DB
        taskId: 1,
        technicianId: 1,
        customerName: 'Customer',
        customerAddress: 'Address',
        brand: 'Polaris',
        typeModel: 'Model X',
        serialNumber: 'SNX-123',
        location: 'ICU',
        serviceType: 'Corrective',
        problem: 'Broken screen',
        parts: const [
          ServiceReportPartModel(
            id: 0,
            serviceReportId: 0,
            partNumber: 'PN-1',
            partDescription: 'Screen',
            quantity: 1,
            unitPrice: 500000,
          ),
          ServiceReportPartModel(
            id: 0,
            serviceReportId: 0,
            partNumber: 'PN-2',
            partDescription: 'Cable',
            quantity: 2,
            unitPrice: 50000,
          ),
        ],
      );

      final insertedId = await localDataSource.insertServiceReport(report);
      expect(insertedId, isNonZero);

      // 2. Read/Get by ID
      final fetched = await localDataSource.getServiceReportById(insertedId);
      expect(fetched, isNotNull);
      expect(fetched!.problem, 'Broken screen');
      expect(fetched.parts.length, 2);
      expect(fetched.parts.first.partDescription, 'Screen');
      expect(fetched.parts.last.partDescription, 'Cable');

      // 3. Get All
      final allReports = await localDataSource.getAllServiceReports();
      expect(allReports.length, 1);
      expect(allReports.first.id, insertedId);

      // 4. Update
      final updatedReport = fetched.copyWith(problem: 'Fixed screen');
      final updatedRows = await localDataSource.updateServiceReport(updatedReport);
      expect(updatedRows, 1);

      final refetched = await localDataSource.getServiceReportById(insertedId);
      expect(refetched!.problem, 'Fixed screen');

      // 5. Delete
      final deletedRows = await localDataSource.deleteServiceReport(insertedId);
      expect(deletedRows, 1);

      final postDelete = await localDataSource.getServiceReportById(insertedId);
      expect(postDelete, isNull);
    });
  });
}
