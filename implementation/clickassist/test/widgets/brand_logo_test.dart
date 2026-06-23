import 'package:clickassist/features/clicker/presentation/pages/onboarding_page.dart';
import 'package:clickassist/features/clicker/presentation/widgets/clicker_dashboard_header.dart';
import 'package:clickassist/features/clicker/presentation/widgets/preset_list_section.dart';
import 'package:clickassist/widgets/brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('full logo preserves its aspect ratio and semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SizedBox(width: 240, child: BrandLogo.full())),
      ),
    );

    expect(
      find.bySemanticsLabel('ClickAssist: Precision tap automation'),
      findsOneWidget,
    );
    final image = tester.widget<Image>(
      find.byKey(const Key('brand-logo-full')),
    );
    expect(image.fit, BoxFit.contain);
  });

  testWidgets('compact logo includes the product name and tagline', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BrandLogo.compact())),
    );

    expect(find.text('ClickAssist'), findsOneWidget);
    expect(find.text('Precision tap automation'), findsOneWidget);
    expect(find.byKey(const Key('brand-logo-mark')), findsOneWidget);
  });

  testWidgets('mark variant is bounded by the requested size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BrandLogo.mark(size: 48))),
    );

    expect(
      tester.getSize(find.byKey(const Key('brand-logo-mark'))),
      const Size(48, 48),
    );
  });

  testWidgets('onboarding presents the full logo and permission guidance', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: OnboardingPage(onContinue: () async {})),
    );

    expect(find.byKey(const Key('brand-logo-full')), findsOneWidget);
    expect(find.text('Welcome to ClickAssist'), findsOneWidget);
    expect(find.textContaining('Accessibility'), findsWidgets);
    expect(find.text('Continue to App'), findsOneWidget);
  });

  testWidgets('dashboard header uses compact ClickAssist branding', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClickerDashboardHeader(
            actionsPerSecond: 0,
            clicks: 0,
            totalClicks: 0,
            onRefresh: () {},
            onOpenHelp: () {},
            onOpenSettings: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('brand-logo-mark')), findsOneWidget);
    expect(find.text('ClickAssist'), findsOneWidget);
  });

  testWidgets('empty preset state uses the ClickAssist mark', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PresetListSection(
            presets: const [],
            onSaveCurrent: () {},
            onImport: () {},
            onApply: (_) {},
            onEdit: (_) {},
            onDelete: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('No presets yet'), findsOneWidget);
    expect(find.byKey(const Key('brand-logo-mark')), findsOneWidget);
  });

  testWidgets('compact logo does not overflow a narrow surface', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SizedBox(width: 170, child: BrandLogo.compact())),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
