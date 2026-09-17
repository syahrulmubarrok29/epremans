import 'package:sqflite/sqflite.dart';

import '../../../models/equipment_model.dart';
import '../../../models/service_report_model.dart';
import '../../../models/service_report_part_model.dart';
import '../../../models/service_request_model.dart';
import '../../../models/technician_task_model.dart';
import '../database/app_database.dart';
import '../database/database_constants.dart';

/// Handles SQLite CRUD operations.
class LocalDataSource {
  LocalDataSource({Database? database}) : _injectedDb = database;

  final Database? _injectedDb;
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<Database> get _db async => _injectedDb ?? await _appDatabase.database;

  // ---------------------------------------------------------------------------
  // Equipment
  // ---------------------------------------------------------------------------

  Future<void> insertEquipment(EquipmentModel equipment) async {
    final db = await _db;
    await db.insert(
      DatabaseConstants.tableEquipment,
      equipment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<EquipmentModel?> getEquipmentById(int id) async {
    final db = await _db;
    final results = await db.query(
      DatabaseConstants.tableEquipment,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return EquipmentModel.fromMap(results.first);
    }
    return null;
  }

  Future<EquipmentModel?> getEquipmentByQrCode(String qrCode) async {
    final db = await _db;
    final results = await db.query(
      DatabaseConstants.tableEquipment,
      where: 'qr_code = ?',
      whereArgs: [qrCode],
    );
    if (results.isNotEmpty) {
      return EquipmentModel.fromMap(results.first);
    }
    return null;
  }

  // ---------------------------------------------------------------------------

  // Service Requests
  // ---------------------------------------------------------------------------

  Future<void> insertServiceRequest(ServiceRequestModel request) async {
    final db = await _db;
    await db.insert(
      DatabaseConstants.tableServiceRequests,
      request.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ServiceRequestModel>> getServiceRequestsByCustomerId(int customerId) async {
    final db = await _db;
    final results = await db.query(
      DatabaseConstants.tableServiceRequests,
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );
    return results.map((e) => ServiceRequestModel.fromMap(e)).toList();
  }

  // ---------------------------------------------------------------------------

  // Technician Tasks
  // ---------------------------------------------------------------------------

  Future<List<TechnicianTaskModel>> getTechnicianTasksByTechnicianId(int technicianId) async {
    final db = await _db;
    final results = await db.query(
      DatabaseConstants.tableTechnicianTasks,
      where: 'technician_id = ?',
      whereArgs: [technicianId],
      orderBy: 'assigned_at DESC',
    );
    return results.map((e) => TechnicianTaskModel.fromMap(e)).toList();
  }

  Future<int> updateTechnicianTaskStatus(int taskId, String status, {DateTime? completedAt}) async {
    final db = await _db;
    final values = <String, dynamic>{'status': status};
    if (completedAt != null) {
      values['completed_at'] = completedAt.toIso8601String();
    }
    return await db.update(
      DatabaseConstants.tableTechnicianTasks,
      values,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // ---------------------------------------------------------------------------

  // Service Reports
  // ---------------------------------------------------------------------------

  Future<int> insertServiceReport(ServiceReportModel report) async {
    final db = await _db;
    
    // Insert report within a transaction to safely insert parts
    return await db.transaction((txn) async {
      final reportId = await txn.insert(
        DatabaseConstants.tableServiceReports,
        report.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert all parts associated with this report
      for (final part in report.parts) {
        final partMap = part.toMap();
        partMap['service_report_id'] = reportId;
        await txn.insert(
          DatabaseConstants.tableServiceReportParts,
          partMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return reportId;
    });
  }

  Future<ServiceReportModel?> getServiceReportById(int id) async {
    final db = await _db;

    final reportResults = await db.query(
      DatabaseConstants.tableServiceReports,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (reportResults.isEmpty) return null;

    final partsResults = await db.query(
      DatabaseConstants.tableServiceReportParts,
      where: 'service_report_id = ?',
      whereArgs: [id],
    );

    final parts = partsResults
        .map((e) => ServiceReportPartModel.fromMap(e))
        .toList();

    return ServiceReportModel.fromMap(reportResults.first, parts: parts);
  }

  Future<List<ServiceReportModel>> getAllServiceReports() async {
    final db = await _db;
    final results = await db.query(DatabaseConstants.tableServiceReports);
    
    // Simplification for list view (not pulling all parts immediately)
    return results.map((e) => ServiceReportModel.fromMap(e)).toList();
  }

  Future<int> updateServiceReport(ServiceReportModel report) async {
    final db = await _db;
    return await db.update(
      DatabaseConstants.tableServiceReports,
      report.toMap(),
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }

  Future<int> deleteServiceReport(int id) async {
    final db = await _db;
    return await db.delete(
      DatabaseConstants.tableServiceReports,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
