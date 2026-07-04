import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class SettingsActionTile extends StatelessWidget {
  const SettingsActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final accent = isDestructive ? AppColors.danger : AppColors.primary;
    final iconWidget = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(icon, color: accent),
    );
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(description, style: AppTextStyles.bodyMedium),
      ],
    );
    final actionButton = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: isDestructive
            ? AppColors.textPrimary
            : AppColors.background,
      ),
      onPressed: onPressed,
      child: Text(label),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackAction = constraints.maxWidth < 360;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.stroke),
            boxShadow: [
              BoxShadow(
                color: AppColors.background.withValues(alpha: 0.26),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: stackAction
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        iconWidget,
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: textContent),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(width: double.infinity, child: actionButton),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconWidget,
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: textContent),
                    const SizedBox(width: AppSpacing.md),
                    actionButton,
                  ],
                ),
        );
      },
    );
  }
}
