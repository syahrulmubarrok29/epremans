/// Constants for SQLite table names and column definitions.
class DatabaseConstants {
  DatabaseConstants._();

  static const String dbName = 'epremans_local.db';
  static const int dbVersion = 1;

  // ---------------------------------------------------------------------------
  // Table Names
  // ---------------------------------------------------------------------------
  static const String tableUsers = 'users';
  static const String tableCustomers = 'customers';
  static const String tableEquipment = 'equipment';
  static const String tableServiceRequests = 'service_requests';
  static const String tableTechnicianTasks = 'technician_tasks';
  static const String tableServiceReports = 'service_reports';
  static const String tableServiceReportParts = 'service_report_parts';

  // ---------------------------------------------------------------------------
  // Create Table Statements
  // ---------------------------------------------------------------------------

  static const String createTableUsers = '''
    CREATE TABLE $tableUsers (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      role TEXT NOT NULL,
      phone TEXT,
      created_at TEXT
    )
  ''';

  static const String createTableCustomers = '''
    CREATE TABLE $tableCustomers (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      phone TEXT,
      contact_person TEXT
    )
  ''';

  static const String createTableEquipment = '''
    CREATE TABLE $tableEquipment (
      id INTEGER PRIMARY KEY,
      brand TEXT NOT NULL,
      type_model TEXT NOT NULL,
      serial_number TEXT NOT NULL,
      location TEXT NOT NULL,
      customer_id INTEGER NOT NULL,
      customer_name TEXT,
      customer_address TEXT,
      qr_code TEXT,
      FOREIGN KEY (customer_id) REFERENCES $tableCustomers(id)
    )
  ''';

  static const String createTableServiceRequests = '''
    CREATE TABLE $tableServiceRequests (
      id INTEGER PRIMARY KEY,
      ticket_number TEXT NOT NULL,
      customer_id INTEGER NOT NULL,
      equipment_id INTEGER NOT NULL,
      problem_description TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      customer_name TEXT,
      equipment_brand TEXT,
      equipment_model TEXT,
      technician_id INTEGER,
      technician_name TEXT,
      FOREIGN KEY (customer_id) REFERENCES $tableCustomers(id),
      FOREIGN KEY (equipment_id) REFERENCES $tableEquipment(id),
      FOREIGN KEY (technician_id) REFERENCES $tableUsers(id)
    )
  ''';

  static const String createTableTechnicianTasks = '''
    CREATE TABLE $tableTechnicianTasks (
      id INTEGER PRIMARY KEY,
      service_request_id INTEGER NOT NULL,
      technician_id INTEGER NOT NULL,
      assigned_at TEXT NOT NULL,
      status TEXT NOT NULL,
      completed_at TEXT,
      service_report_id INTEGER,
      customer_name TEXT,
      customer_address TEXT,
      equipment_brand TEXT,
      equipment_model TEXT,
      problem_description TEXT,
      FOREIGN KEY (service_request_id) REFERENCES $tableServiceRequests(id),
      FOREIGN KEY (technician_id) REFERENCES $tableUsers(id)
    )
  ''';

  static const String createTableServiceReports = '''
    CREATE TABLE $tableServiceReports (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      task_id INTEGER NOT NULL,
      technician_id INTEGER NOT NULL,
      customer_name TEXT NOT NULL,
      customer_address TEXT NOT NULL,
      brand TEXT NOT NULL,
      type_model TEXT NOT NULL,
      serial_number TEXT NOT NULL,
      location TEXT NOT NULL,
      service_type TEXT NOT NULL,
      service_begin TEXT,
      service_end TEXT,
      problem TEXT,
      solutions TEXT,
      remarks TEXT,
      work_status TEXT,
      labor_time_hours REAL,
      labor_rate REAL,
      travel_time_hours REAL,
      travel_rate REAL,
      travel_cost REAL,
      others_cost REAL,
      technician_signature TEXT,
      customer_signature TEXT,
      FOREIGN KEY (task_id) REFERENCES $tableTechnicianTasks(id),
      FOREIGN KEY (technician_id) REFERENCES $tableUsers(id)
    )
  ''';

  static const String createTableServiceReportParts = '''
    CREATE TABLE $tableServiceReportParts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      service_report_id INTEGER NOT NULL,
      part_number TEXT NOT NULL,
      part_description TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      unit_price REAL NOT NULL,
      FOREIGN KEY (service_report_id) REFERENCES $tableServiceReports(id) ON DELETE CASCADE
    )
  ''';
}
