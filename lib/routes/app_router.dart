import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../data/providers/data_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/customer/presentation/customer_dashboard_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/technician/presentation/technician_dashboard_screen.dart';

// ---------------------------------------------------------------------------
// Route name constants
// ---------------------------------------------------------------------------

/// Named route constants used throughout the app.
///
/// Always navigate using these names, never with raw string paths:
///   context.goNamed(AppRoutes.splash)
class AppRoutes {
  AppRoutes._();

  // Core
  static const String splash = 'splash';
  static const String login = 'login';

  // Customer
  static const String customerDashboard = 'customer-dashboard';
  static const String customerCreateRequest = 'customer-create-request';
  static const String customerRequestDetail = 'customer-request-detail';
  static const String customerQrScan = 'customer-qr-scan';
  static const String customerTechnicianTracking = 'customer-technician-tracking';
  static const String customerNotifications = 'customer-notifications';

  // Technician
  static const String technicianDashboard = 'technician-dashboard';
  static const String technicianTasks = 'technician-tasks';
  static const String technicianTaskDetail = 'technician-task-detail';
  static const String technicianDailyActivity = 'technician-daily-activity';
  static const String technicianQuotation = 'technician-quotation';

  // Service Report flow
  static const String srEquipmentInfo = 'sr-equipment-info';
  static const String srStartService = 'sr-start-service';
  static const String srProblemSolution = 'sr-problem-solution';
  static const String srParts = 'sr-parts';
  static const String srCost = 'sr-cost';
  static const String srEndService = 'sr-end-service';
  static const String srSignature = 'sr-signature';
  static const String srReview = 'sr-review';
  static const String srCompleted = 'sr-completed';
}

// ---------------------------------------------------------------------------
// Auth-aware GoRouter factory
// ---------------------------------------------------------------------------

/// Builds the [GoRouter] instance with a Riverpod [ProviderContainer] so
/// the `redirect` callback can read [authControllerProvider] synchronously.
///
/// Auth-aware redirect rules (Phase 3):
///   Unauthenticated → /login   (any protected route)
///   Authenticated Customer → /customer/dashboard
///   Authenticated Technician → /technician/dashboard
///   Logout → /login  (GoRouter refreshes via [authControllerProvider])
GoRouter createRouter(ProviderContainer container) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    // Notify GoRouter to re-evaluate the redirect whenever auth state changes.
    refreshListenable: _AuthStateListenable(container),

    redirect: (context, state) {
      final authAsync = container.read(authControllerProvider);
      final splashCompleted = container.read(splashCompletedProvider);

      // While loading (e.g. splash restoring session), do not redirect.
      if (authAsync.isLoading) return null;

      final user = authAsync.valueOrNull;
      final isAuthenticated = user != null;
      final location = state.uri.toString();

      // On splash screen: stay while splash has not completed
      if (location == '/splash') {
        if (!splashCompleted) return null;
        if (!isAuthenticated) return '/login';
        return user.isTechnician
            ? '/technician/dashboard'
            : '/customer/dashboard';
      }

      if (!isAuthenticated) {
        // Unauthenticated: send to /login unless already on /login.
        return location == '/login' ? null : '/login';
      }

      // Authenticated — redirect away from login to the correct dashboard.
      if (location == '/login') {
        return user.isTechnician
            ? '/technician/dashboard'
            : '/customer/dashboard';
      }

      // Authenticated — prevent technician from reaching customer routes and vice versa.
      if (user.isTechnician && location.startsWith('/customer/')) {
        return '/technician/dashboard';
      }
      if (user.isCustomer && location.startsWith('/technician/')) {
        return '/customer/dashboard';
      }

      // No redirect needed.
      return null;
    },

    routes: [
      // -----------------------------------------------------------------------
      // Splash
      // -----------------------------------------------------------------------
      GoRoute(
        path: '/splash',
        name: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // -----------------------------------------------------------------------
      // Auth (Phase 3 — implemented)
      // -----------------------------------------------------------------------
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // -----------------------------------------------------------------------
      // Customer (Phase 3: dashboard placeholder; Phase 5: full features)
      // -----------------------------------------------------------------------
      GoRoute(
        path: '/customer/dashboard',
        name: AppRoutes.customerDashboard,
        builder: (context, state) => const CustomerDashboardScreen(),
      ),
      GoRoute(
        path: '/customer/create-request',
        name: AppRoutes.customerCreateRequest,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'Create Request', phase: 5),
      ),
      GoRoute(
        path: '/customer/request/:id',
        name: AppRoutes.customerRequestDetail,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'Request Detail', phase: 5),
      ),
      GoRoute(
        path: '/customer/qr-scan',
        name: AppRoutes.customerQrScan,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'QR Scan', phase: 5),
      ),
      GoRoute(
        path: '/customer/tracking/:id',
        name: AppRoutes.customerTechnicianTracking,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'Technician Tracking', phase: 5),
      ),
      GoRoute(
        path: '/customer/notifications',
        name: AppRoutes.customerNotifications,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'Notifications', phase: 5),
      ),

      // -----------------------------------------------------------------------
      // Technician (Phase 3: dashboard placeholder; Phase 6: full features)
      // -----------------------------------------------------------------------
      GoRoute(
        path: '/technician/dashboard',
        name: AppRoutes.technicianDashboard,
        builder: (context, state) => const TechnicianDashboardScreen(),
      ),
      GoRoute(
        path: '/technician/tasks',
        name: AppRoutes.technicianTasks,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'Assigned Tasks', phase: 6),
      ),
      GoRoute(
        path: '/technician/task/:id',
        name: AppRoutes.technicianTaskDetail,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'Task Detail', phase: 6),
      ),
      GoRoute(
        path: '/technician/daily-activity',
        name: AppRoutes.technicianDailyActivity,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'Daily Activity', phase: 6),
      ),
      GoRoute(
        path: '/technician/quotation',
        name: AppRoutes.technicianQuotation,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'Request Quotation', phase: 6),
      ),

      // -----------------------------------------------------------------------
      // Service Report flow (Phase 7)
      // -----------------------------------------------------------------------
      GoRoute(
        path: '/service-report/equipment-info',
        name: AppRoutes.srEquipmentInfo,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'SR: Equipment Information', phase: 7),
      ),
      GoRoute(
        path: '/service-report/start-service',
        name: AppRoutes.srStartService,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'SR: Start Service', phase: 7),
      ),
      GoRoute(
        path: '/service-report/problem-solution',
        name: AppRoutes.srProblemSolution,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'SR: Problem & Solution', phase: 7),
      ),
      GoRoute(
        path: '/service-report/parts',
        name: AppRoutes.srParts,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'SR: Parts', phase: 7),
      ),
      GoRoute(
        path: '/service-report/cost',
        name: AppRoutes.srCost,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'SR: Cost', phase: 7),
      ),
      GoRoute(
        path: '/service-report/end-service',
        name: AppRoutes.srEndService,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'SR: End Service', phase: 7),
      ),
      GoRoute(
        path: '/service-report/signature',
        name: AppRoutes.srSignature,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'SR: Digital Signature', phase: 7),
      ),
      GoRoute(
        path: '/service-report/review',
        name: AppRoutes.srReview,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'SR: Review', phase: 7),
      ),
      GoRoute(
        path: '/service-report/completed',
        name: AppRoutes.srCompleted,
        builder: (context, state) =>
            const _ComingSoonScreen(label: 'SR: Completed', phase: 7),
      ),
    ],

    // Error page for unmatched routes
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );
}

// ---------------------------------------------------------------------------
// Listenable that notifies GoRouter when auth state changes
// ---------------------------------------------------------------------------

/// Bridges Riverpod [authControllerProvider] to GoRouter's [refreshListenable].
///
/// Listens to the provider and calls [notifyListeners] whenever auth state
/// changes, triggering GoRouter's redirect evaluation.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(ProviderContainer container) {
    _subscription = container.listen(
      authControllerProvider,
      (_, _) => notifyListeners(),
    );
    _splashSubscription = container.listen(
      splashCompletedProvider,
      (_, _) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AsyncValue<dynamic>> _subscription;
  late final ProviderSubscription<bool> _splashSubscription;

  @override
  void dispose() {
    _subscription.close();
    _splashSubscription.close();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Placeholder widgets (removed when feature is implemented)
// ---------------------------------------------------------------------------

/// Shown for routes that belong to a future phase.
class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({required this.label, required this.phase});

  final String label;
  final int phase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_rounded,
                  size: 64, color: Color(0xFF1A3A5C)),
              const SizedBox(height: 16),
              Text(
                label,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Coming in Phase $phase',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5A6578),
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when the router encounters an unregistered path.
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Color(0xFFC62828)),
              const SizedBox(height: 16),
              Text(
                '404 — Route not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              if (error != null)
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
