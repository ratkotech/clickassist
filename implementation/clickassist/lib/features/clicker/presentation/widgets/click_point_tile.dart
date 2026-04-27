import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/click_point.dart';

class ClickPointTile extends StatelessWidget {
  const ClickPointTile({
    super.key,
    required this.index,
    required this.clickPoint,
    required this.onEdit,
    required this.onRemove,
  });

  final int index;
  final ClickPoint clickPoint;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.stroke),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useCompactActions = constraints.maxWidth < 360;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clickPoint.label, style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'X: ${clickPoint.x.toStringAsFixed(0)}   Y: ${clickPoint.y.toStringAsFixed(0)}',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Relative: ${(clickPoint.xPercent * 100).toStringAsFixed(0)}% / ${(clickPoint.yPercent * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.bodySmall,
                    ),
                    if (useCompactActions) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          IconButton(
                            onPressed: onEdit,
                            tooltip: 'Re-pick click point',
                            icon: const Icon(
                              Icons.edit_location_alt_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            onPressed: onRemove,
                            tooltip: 'Remove click point',
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!useCompactActions)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      tooltip: 'Re-pick click point',
                      icon: const Icon(
                        Icons.edit_location_alt_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: onRemove,
                      tooltip: 'Remove click point',
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
