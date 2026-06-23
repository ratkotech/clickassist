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
}
