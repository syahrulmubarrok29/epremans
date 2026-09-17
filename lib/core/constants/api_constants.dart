/// API configuration constants for e-PREMANS.
///
/// The base URL is sourced from the compile-time environment variable
/// `API_BASE_URL`. During development, the default value is used.
///
/// Usage (production build):
///   flutter build apk --dart-define=API_BASE_URL=https://api.epremans.com/api/v1
///
/// The UI must NEVER import this class directly.
/// All network calls must go through the repository layer.
class ApiConstants {
  ApiConstants._();

  // ---------------------------------------------------------------------------
  // Base URL — configurable via --dart-define
  // ---------------------------------------------------------------------------

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.epremans.com/api/v1',
  );

  // ---------------------------------------------------------------------------
  // Auth endpoints
  // ---------------------------------------------------------------------------

  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';

  // ---------------------------------------------------------------------------
  // Customer endpoints
  // ---------------------------------------------------------------------------

  static const String customerRequests = '/customer/requests';
  static const String customerRequestDetail = '/customer/requests/{id}';
  static const String customerCreateRequest = '/customer/requests';
  static const String customerEquipment = '/customer/equipment';

  // ---------------------------------------------------------------------------
  // Technician endpoints
  // ---------------------------------------------------------------------------

  static const String technicianTasks = '/technician/tasks';
  static const String technicianTaskDetail = '/technician/tasks/{id}';
  static const String technicianDailyActivity = '/technician/activities';
  static const String technicianQuotation = '/technician/quotations';

  // ---------------------------------------------------------------------------
  // Service Report endpoints
  // ---------------------------------------------------------------------------

  static const String serviceReports = '/service-reports';
  static const String serviceReportDetail = '/service-reports/{id}';
  static const String serviceReportSubmit = '/service-reports/{id}/submit';
  static const String serviceReportPdf = '/service-reports/{id}/pdf';

  // ---------------------------------------------------------------------------
  // Equipment endpoints
  // ---------------------------------------------------------------------------

  static const String equipment = '/equipment';
  static const String equipmentBySerialNumber = '/equipment/sn/{sn}';
  static const String equipmentByQrCode = '/equipment/qr/{code}';

  // ---------------------------------------------------------------------------
  // Notification endpoints
  // ---------------------------------------------------------------------------

  static const String notifications = '/notifications';
  static const String notificationMarkRead = '/notifications/{id}/read';
}
