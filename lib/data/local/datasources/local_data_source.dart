import 'package:sqflite/sqflite.dart';

import '../../../models/daily_activity_model.dart';
import '../../../models/equipment_model.dart';
import '../../../models/quotation_request_model.dart';
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

    final reportId = await db.transaction((txn) async {
      final userExists = Sqflite.firstIntValue(
        await txn.rawQuery(
          'SELECT 1 FROM ${DatabaseConstants.tableUsers} WHERE id = ?',
          [report.technicianId],
        ),
      );
      if (userExists == null) {
        await txn.insert(
          DatabaseConstants.tableUsers,
          {
            'id': report.technicianId,
            'name': report.customerName,
            'email': 'repair-${report.technicianId}@local.local',
            'role': 'Technician',
            'phone': null,
            'created_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      final serviceRequestExists = Sqflite.firstIntValue(
        await txn.rawQuery(
          'SELECT 1 FROM ${DatabaseConstants.tableServiceRequests} WHERE id = ?',
          [report.taskId],
        ),
      );
      if (serviceRequestExists == null) {
        await txn.insert(
          DatabaseConstants.tableServiceRequests,
          {
            'id': report.taskId,
            'ticket_number': 'SR-${report.taskId}',
            'customer_id': 1,
            'equipment_id': 1,
            'problem_description': report.problem ?? 'Service report entry',
            'status': 'Completed',
            'created_at': DateTime.now().toIso8601String(),
            'customer_name': report.customerName,
            'equipment_brand': report.brand,
            'equipment_model': report.typeModel,
            'technician_id': report.technicianId,
            'technician_name': report.customerName,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      final taskExists = Sqflite.firstIntValue(
        await txn.rawQuery(
          'SELECT 1 FROM ${DatabaseConstants.tableTechnicianTasks} WHERE id = ?',
          [report.taskId],
        ),
      );
      if (taskExists == null) {
        await txn.insert(
          DatabaseConstants.tableTechnicianTasks,
          {
            'id': report.taskId,
            'service_request_id': report.taskId,
            'technician_id': report.technicianId,
            'assigned_at': DateTime.now().toIso8601String(),
            'status': 'Completed',
            'customer_name': report.customerName,
            'customer_address': report.customerAddress,
            'equipment_brand': report.brand,
            'equipment_model': report.typeModel,
            'problem_description': report.problem ?? 'Service report entry',
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      final insertedId = await txn.insert(
        DatabaseConstants.tableServiceReports,
        report.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final part in report.parts) {
        final partMap = part.toMap();
        partMap['service_report_id'] = insertedId;
        await txn.insert(
          DatabaseConstants.tableServiceReportParts,
          partMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return insertedId;
    });

    return reportId;
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

  // ---------------------------------------------------------------------------
  // Daily Activities
  // ---------------------------------------------------------------------------

  Future<int> insertDailyActivity(DailyActivityModel activity) async {
    final db = await _db;
    return await db.insert(
      DatabaseConstants.tableDailyActivities,
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DailyActivityModel>> getDailyActivitiesByTechnician(int technicianId) async {
    final db = await _db;
    final results = await db.query(
      DatabaseConstants.tableDailyActivities,
      where: 'technician_id = ?',
      whereArgs: [technicianId],
      orderBy: 'activity_date DESC, created_at DESC',
    );
    return results.map((e) => DailyActivityModel.fromMap(e)).toList();
  }

  Future<DailyActivityModel?> getDailyActivityById(int id) async {
    final db = await _db;
    final results = await db.query(
      DatabaseConstants.tableDailyActivities,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return DailyActivityModel.fromMap(results.first);
  }

  Future<int> updateDailyActivity(DailyActivityModel activity, int technicianId) async {
    final db = await _db;
    return await db.update(
      DatabaseConstants.tableDailyActivities,
      activity.toMap(),
      where: 'id = ? AND technician_id = ?',
      whereArgs: [activity.id, technicianId],
    );
  }

  Future<int> deleteDailyActivity(int id, {required int technicianId}) async {
    final db = await _db;
    return await db.delete(
      DatabaseConstants.tableDailyActivities,
      where: 'id = ? AND technician_id = ?',
      whereArgs: [id, technicianId],
    );
  }

  // ---------------------------------------------------------------------------
  // Quotation Requests
  // ---------------------------------------------------------------------------

  Future<int> insertQuotationRequest(QuotationRequestModel request) async {
    final db = await _db;
    return await db.insert(
      DatabaseConstants.tableQuotationRequests,
      request.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<QuotationRequestModel>> getQuotationRequestsByTechnician(int technicianId) async {
    final db = await _db;
    final results = await db.query(
      DatabaseConstants.tableQuotationRequests,
      where: 'technician_id = ?',
      whereArgs: [technicianId],
      orderBy: 'created_at DESC',
    );
    return results.map((e) => QuotationRequestModel.fromMap(e)).toList();
  }

  Future<QuotationRequestModel?> getQuotationRequestById(int id) async {
    final db = await _db;
    final results = await db.query(
      DatabaseConstants.tableQuotationRequests,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return QuotationRequestModel.fromMap(results.first);
  }

  Future<int> updateQuotationRequest(QuotationRequestModel request, int technicianId) async {
    final db = await _db;
    return await db.update(
      DatabaseConstants.tableQuotationRequests,
      request.toMap(),
      where: 'id = ? AND technician_id = ?',
      whereArgs: [request.id, technicianId],
    );
  }

  Future<int> deleteQuotationRequest(int id, {required int technicianId}) async {
    final db = await _db;
    return await db.delete(
      DatabaseConstants.tableQuotationRequests,
      where: 'id = ? AND technician_id = ?',
      whereArgs: [id, technicianId],
    );
  }
}
