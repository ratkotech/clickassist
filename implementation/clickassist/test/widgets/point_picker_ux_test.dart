import 'dart:io';

import 'package:clickassist/features/clicker/domain/entities/click_point.dart';
import 'package:clickassist/features/clicker/presentation/widgets/click_point_list.dart';
import 'package:clickassist/features/clicker/presentation/widgets/click_point_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('native point picker overlay has clear instructions and actions', () {
    final layout = File(
      'android/app/src/main/res/layout/point_picker_overlay.xml',
    ).readAsStringSync();
    final service = File(
      'android/app/src/main/kotlin/app/clickassist/android/PointPickerOverlayService.kt',
    ).readAsStringSync();

    expect(layout, contains('Pick target position'));
    expect(
      layout,
      contains('Drag the marker to the exact place you want to tap.'),
    );
    expect(
      layout,
      contains('Press Confirm when the marker is correctly placed.'),
    );
    expect(layout, contains('android:id="@+id/pointPickerCancelButton"'));
    expect(layout, contains('android:text="Cancel"'));
    expect(layout, contains('android:text="Confirm"'));
    expect(layout, contains('android:id="@+id/pointPickerMarkerCoordinates"'));
    expect(layout, contains('android:text="Drag me"'));
    expect(
      layout,
      contains(
        'android:contentDescription="Drag target marker to exact tap point"',
      ),
    );
    expect(service, contains('pointPickerMarkerCoordinates'));
    expect(
      service,
      contains(r'"X: ${selectedX.toInt()}  |  Y: ${selectedY.toInt()}"'),
    );
    expect(
      service,
      contains(r'"X ${selectedX.toInt()} · Y ${selectedY.toInt()}"'),
    );
  });

  testWidgets('active picker copy is short and avoids duplicate instructions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClickPointList(
            clickPoints: const <ClickPoint>[],
            onRemove: (_) {},
            onAdd: () {},
            onEdit: (_) {},
            multiClickEnabled: false,
            onMultiClickChanged: (_) {},
            pointPickerActive: true,
            onCancelPicker: () {},
          ),
        ),
      ),
    );

    expect(find.text('Picker active on screen.'), findsOneWidget);
    expect(
      find.text('Use the overlay controls to confirm or cancel.'),
      findsOneWidget,
    );
    expect(find.textContaining('move the marker in any app'), findsNothing);
  });

  testWidgets('confirmed target card has clear coordinate labels and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClickPointTile(
            index: 0,
            clickPoint: const ClickPoint(
              id: 'point-1',
              label: 'Primary Target',
              x: 549,
              y: 1117,
              xPercent: 0.51,
              yPercent: 0.47,
            ),
            onEdit: () {},
            onRemove: () {},
          ),
        ),
      ),
    );

    expect(find.text('Primary Target'), findsOneWidget);
    expect(find.text('Saved target position'), findsOneWidget);
    expect(find.text('X: 549   Y: 1117'), findsOneWidget);
    expect(find.text('Relative: 51% / 47%'), findsOneWidget);
    expect(find.byTooltip('Edit target position'), findsOneWidget);
    expect(find.byTooltip('Delete target position'), findsOneWidget);
  });
}
