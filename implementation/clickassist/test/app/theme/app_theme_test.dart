import 'package:clickassist/app/theme/app_colors.dart';
import 'package:clickassist/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dark theme centralizes interactive component styling', () {
    final theme = AppTheme.darkTheme;

    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.filledButtonTheme.style, isNotNull);
    expect(theme.outlinedButtonTheme.style, isNotNull);
    expect(theme.textButtonTheme.style, isNotNull);
    expect(theme.inputDecorationTheme.filled, isTrue);
    expect(theme.snackBarTheme.backgroundColor, AppColors.surface);
    expect(theme.dialogTheme.backgroundColor, AppColors.surface);
    expect(theme.progressIndicatorTheme.color, AppColors.primary);
  });
}
