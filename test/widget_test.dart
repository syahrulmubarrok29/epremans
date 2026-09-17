import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:epremans/data/providers/data_providers.dart';
import 'package:epremans/main.dart';

void main() {
  testWidgets('EPremansApp smoke test — renders without crashing',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const EPremansApp(),
      ),
    );

    // The splash screen should be visible on first frame.
    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pump();
    expect(find.byType(Router<Object>), findsOneWidget);

    // Advance time past splash duration so all timers complete.
    await tester.pump(const Duration(seconds: 3));
  });
}
