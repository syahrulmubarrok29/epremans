/// Application-wide constants for e-PREMANS.
///
/// Business-specific magic values belong here, not scattered across the UI.
class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // App identity
  // ---------------------------------------------------------------------------

  static const String appName = 'e-PREMANS';
  static const String appFullName = 'Polaris Request Maintenance and Service';
  static const String appVersion = '1.0.0';
  static const String companyName = 'PT Polaris Alkes Starindo';

  // ---------------------------------------------------------------------------
  // SharedPreferences keys
  // ---------------------------------------------------------------------------

  static const String prefKeyAuthToken = 'auth_token';
  static const String prefKeyUserId = 'user_id';
  static const String prefKeyUserRole = 'user_role';
  static const String prefKeyIsLoggedIn = 'is_logged_in';
  static const String prefKeyOnboardingDone = 'onboarding_done';

  // ---------------------------------------------------------------------------
  // User roles
  // ---------------------------------------------------------------------------

  static const String roleCustomer = 'customer';
  static const String roleTechnician = 'technician';
  static const String roleAdmin = 'admin';

  // ---------------------------------------------------------------------------
  // Service Report — Service Types
  // ---------------------------------------------------------------------------

  static const String serviceTypePreventive = 'Preventive';
  static const String serviceTypeCorrective = 'Corrective';
  static const String serviceTypeOthers = 'Others';

  static const List<String> serviceTypes = [
    serviceTypePreventive,
    serviceTypeCorrective,
    serviceTypeOthers,
  ];

  // ---------------------------------------------------------------------------
  // Service Report — Work Status
  // ---------------------------------------------------------------------------

  static const String workStatusCompleted = 'Work Completed';
  static const String workStatusIncompleted = 'Work Incompleted';
  static const String workStatusPartsRequired = 'Parts Still Required';

  static const List<String> workStatuses = [
    workStatusCompleted,
    workStatusIncompleted,
    workStatusPartsRequired,
  ];

  // ---------------------------------------------------------------------------
  // UI durations
  // ---------------------------------------------------------------------------

  /// Duration of the splash screen before navigating forward.
  static const Duration splashDuration = Duration(seconds: 2);

  /// Default animation duration for page transitions.
  static const Duration animationDuration = Duration(milliseconds: 250);

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------

  static const int defaultPageSize = 20;

  // ---------------------------------------------------------------------------
  // Local database
  // ---------------------------------------------------------------------------

  static const String dbName = 'epremans.db';
  static const int dbVersion = 1;

  // ---------------------------------------------------------------------------
  // Timeouts
  // ---------------------------------------------------------------------------

  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
}
