import 'package:clickassist/features/clicker/presentation/widgets/permission_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('permission card explains and triggers its action', (
    tester,
  ) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PermissionInfoCard(
            icon: Icons.accessibility_new_rounded,
            title: 'Accessibility service',
            description: 'Dispatches only the taps and swipes you configure.',
            actionLabel: 'Open settings',
            onAction: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Accessibility service'), findsOneWidget);
    expect(find.textContaining('only the taps and swipes'), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    expect(pressed, isTrue);
  });

  testWidgets('optional permissions are visibly identified', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PermissionInfoCard(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            description: 'Keeps native controls visible.',
            isOptional: true,
          ),
        ),
      ),
    );

    expect(find.text('Optional'), findsOneWidget);
  });
}
