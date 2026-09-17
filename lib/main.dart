import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/data_providers.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise SharedPreferences before runApp so sharedPreferencesProvider
  // override is available when the ProviderScope builds.
  final prefs = await SharedPreferences.getInstance();

  // Lock orientation to portrait for mobile.
  // Phase 1: Applied globally. Relax if tablet/landscape support is added.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure status bar appearance.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ProviderContainer created before runApp so createRouter can read providers
  // synchronously inside the redirect callback.
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: EPremansApp(container: container),
    ),
  );
}

/// Root application widget for e-PREMANS.
///
/// Uses [MaterialApp.router] with a [GoRouter] created via [createRouter],
/// which wires Riverpod auth state into GoRouter's redirect mechanism.
class EPremansApp extends StatefulWidget {
  const EPremansApp({super.key, this.container});

  final ProviderContainer? container;

  @override
  State<EPremansApp> createState() => _EPremansAppState();
}

class _EPremansAppState extends State<EPremansApp> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_router == null) {
      final container = widget.container ??
          ProviderScope.containerOf(context, listen: false);
      _router = createRouter(container);
    }
  }

  @override
  void dispose() {
    _router?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_router == null) {
      return const SizedBox.shrink();
    }
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
