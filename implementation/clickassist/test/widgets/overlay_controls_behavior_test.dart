import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'compact overlay tap stops running clicker instead of expanding controls',
    () {
      final floatingOverlayService = File(
        'android/app/src/main/kotlin/app/clickassist/android/FloatingOverlayService.kt',
      ).readAsStringSync();

      expect(
        floatingOverlayService,
        contains('compactButton?.setOnClickListener'),
      );
      expect(
        floatingOverlayService,
        contains('''if (ClickAssistBridge.isRunning()) {
                ClickAssistBridge.stop(this)
                updateOverlayAppearance()
                setExpanded(false, animate = true)
                return@setOnClickListener
            }'''),
      );
      expect(
        floatingOverlayService,
        contains('setExpanded(true, animate = true)'),
      );
    },
  );
}
