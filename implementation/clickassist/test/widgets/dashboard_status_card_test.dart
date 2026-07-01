import 'package:clickassist/features/clicker/presentation/widgets/dashboard_status_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('blocking status card prioritizes the required setup action', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardStatusCard(
            tone: DashboardStatusTone.blocking,
            title: 'Accessibility setup required',
            message: 'Enable ClickAssist before START can run taps.',
            actionLabel: 'Enable Accessibility',
            onAction: () {
              tapped = true;
            },
            advisoryMessage:
                'Disable battery optimization for more reliable background runs.',
          ),
        ),
      ),
    );

    expect(find.text('Required setup'), findsOneWidget);
    expect(find.text('Accessibility setup required'), findsOneWidget);
    expect(find.text('Enable Accessibility'), findsOneWidget);
    expect(find.text('Optional reliability tip'), findsOneWidget);

    await tester.tap(find.text('Enable Accessibility'));

    expect(tapped, isTrue);
  });

  testWidgets('ready status card stays compact without an empty action slot', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DashboardStatusCard(
            tone: DashboardStatusTone.ready,
            title: 'Ready to configure',
            message: 'Add a target point, then press START.',
          ),
        ),
      ),
    );

    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Ready to configure'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });
}
