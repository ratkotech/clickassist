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
      child: Semantics(
        button: true,
        container: true,
        label: isRunning ? 'Stop automation' : 'Start automation',
        child: ExcludeSemantics(
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              key: const Key('clicker-start-button'),
              width: 148,
              height: 148,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
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
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      size: 42,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      isRunning ? 'STOP' : 'START',
                      style: AppTextStyles.buttonUppercase,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
