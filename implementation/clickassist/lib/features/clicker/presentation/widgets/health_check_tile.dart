import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class HealthCheckTile extends StatelessWidget {
  const HealthCheckTile({
    super.key,
    required this.title,
    required this.description,
    required this.isHealthy,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;
  final bool isHealthy;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isHealthy ? AppColors.success : AppColors.warning)
                  .withValues(alpha: 0.14),
            ),
            child: Icon(
              isHealthy
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: isHealthy ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          if (isHealthy || onAction != null) ...[
            const SizedBox(width: AppSpacing.md),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(88, 42),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  backgroundColor: isHealthy
                      ? AppColors.stroke.withValues(alpha: 0.9)
                      : AppColors.primary,
                  foregroundColor: isHealthy
                      ? AppColors.textSecondary
                      : AppColors.background,
                ),
                onPressed: isHealthy ? null : onAction,
                child: Text(isHealthy ? 'Ready' : actionLabel ?? 'Open'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
