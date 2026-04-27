import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class ClickerStartButton extends StatelessWidget {
  const ClickerStartButton({
    super.key,
    required this.isRunning,
    required this.isAccessibilityEnabled,
    required this.onPressed,
  });

  final bool isRunning;
  final bool isAccessibilityEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final borderColor = isRunning ? AppColors.success : AppColors.primary;

    return Center(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 168,
          height: 168,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 3),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAccessibilityEnabled
                  ? AppColors.primary
                  : AppColors.primaryMuted,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 48,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isRunning ? 'STOP' : 'START',
                  style: AppTextStyles.buttonText.copyWith(letterSpacing: 1.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
