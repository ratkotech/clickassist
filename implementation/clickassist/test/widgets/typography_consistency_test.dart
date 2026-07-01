import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('typography primitives are centralized in app theme files', () {
    final allowedFiles = {
      'lib/app/theme/app_text_styles.dart',
      'lib/app/theme/app_theme.dart',
    };
    final checkedPatterns = {
      RegExp(r'\bTextStyle\s*\('): 'TextStyle(',
      RegExp(r'\bfontSize\s*:'): 'fontSize:',
      RegExp(r'\bfontWeight\s*:'): 'fontWeight:',
      RegExp(r'\bletterSpacing\s*:'): 'letterSpacing:',
    };

    final violations = <String>[];
    final libDirectory = Directory('lib');
    for (final file
        in libDirectory
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))) {
      final normalizedPath = file.path.replaceAll('\\', '/');
      if (allowedFiles.contains(normalizedPath)) {
        continue;
      }

      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        final line = lines[index];
        for (final entry in checkedPatterns.entries) {
          if (entry.key.hasMatch(line)) {
            violations.add('$normalizedPath:${index + 1} uses ${entry.value}');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Use AppTextStyles tokens instead of hardcoding typography primitives.',
    );
  });
}
