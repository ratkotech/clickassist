import 'package:clickassist/features/clicker/presentation/widgets/setup_guide_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('setup guide exposes live step status and per-step actions', (
    tester,
  ) async {
    var openedAccessibility = false;
    var refreshed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SetupGuideCard(
              accessibilityEnabled: false,
              overlayPermissionEnabled: true,
              notificationsEnabled: false,
              batteryOptimizationIgnored: false,
              onOpenAccessibility: () {
                openedAccessibility = true;
              },
              onOpenOverlay: () {},
              onOpenNotifications: () {},
              onOpenBatteryOptimization: () {},
              onRefresh: () {
                refreshed = true;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Guided setup'), findsOneWidget);
    expect(find.text('1 of 4 complete'), findsOneWidget);
    expect(find.text('Accessibility'), findsOneWidget);
    expect(find.text('Needs action'), findsWidgets);
    expect(find.text('Refresh'), findsWidgets);

    await tester.tap(find.byKey(const Key('setup-step-accessibility-open')));
    await tester.tap(find.byKey(const Key('setup-step-accessibility-refresh')));

    expect(openedAccessibility, isTrue);
    expect(refreshed, isTrue);
  });

  testWidgets(
    'setup guide shows final ready state when core permissions pass',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SetupGuideCard(
                accessibilityEnabled: true,
                overlayPermissionEnabled: true,
                notificationsEnabled: true,
                batteryOptimizationIgnored: false,
                onOpenAccessibility: () {},
                onOpenOverlay: () {},
                onOpenNotifications: () {},
                onOpenBatteryOptimization: () {},
                onRefresh: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Core automation is ready'), findsOneWidget);
      expect(
        find.text('Battery optimization is still recommended.'),
        findsOneWidget,
      );
      expect(find.text('Ready check'), findsOneWidget);
    },
  );

  testWidgets('setup guide does not overflow on phone-width screens', (
    tester,
  ) async {
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SetupGuideCard(
              accessibilityEnabled: true,
              overlayPermissionEnabled: true,
              notificationsEnabled: true,
              batteryOptimizationIgnored: false,
              onOpenAccessibility: () {},
              onOpenOverlay: () {},
              onOpenNotifications: () {},
              onOpenBatteryOptimization: () {},
              onRefresh: () {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Battery optimization'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
  });
}
