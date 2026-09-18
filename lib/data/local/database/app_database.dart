import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

/// Initializes and provides access to the SQLite database.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DatabaseConstants.dbName);

    return await openDatabase(
      path,
      version: DatabaseConstants.dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseConstants.createTableUsers);
    await db.execute(DatabaseConstants.createTableCustomers);
    await db.execute(DatabaseConstants.createTableEquipment);
    await db.execute(DatabaseConstants.createTableServiceRequests);
    await db.execute(DatabaseConstants.createTableTechnicianTasks);
    await db.execute(DatabaseConstants.createTableServiceReports);
    await db.execute(DatabaseConstants.createTableServiceReportParts);
    await db.execute(DatabaseConstants.createTableDailyActivities);
    await db.execute(DatabaseConstants.createTableQuotationRequests);
  }
}
