import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/tap_pattern.dart';

class TapPatternSelector extends StatelessWidget {
  const TapPatternSelector({
    super.key,
    required this.selectedPattern,
    required this.onSelected,
  });

  final TapPattern selectedPattern;
  final ValueChanged<TapPattern> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.9,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: TapPattern.values.map((pattern) {
            final isSelected = pattern == selectedPattern;
            return GestureDetector(
              onTap: () => onSelected(pattern),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBright
                        : AppColors.stroke,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      pattern.icon,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      pattern.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        pattern.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? AppColors.textPrimary.withValues(alpha: 0.8)
                              : AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rhythm preview', style: AppTextStyles.bodySmall),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: List.generate(
                  selectedPattern.tapsPerCycle,
                  (_) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
