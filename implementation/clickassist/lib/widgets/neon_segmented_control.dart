import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';

class NeonSegmentOption<T> {
  const NeonSegmentOption({
    required this.value,
    required this.label,
    this.caption,
    this.icon,
  });

  final T value;
  final String label;
  final String? caption;
  final IconData? icon;
}

class NeonSegmentedControl<T> extends StatelessWidget {
  const NeonSegmentedControl({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<NeonSegmentOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useWrap = constraints.maxWidth < 440;
        final children = options
            .map(
              (option) => _SegmentTile<T>(
                option: option,
                isSelected: option.value == selectedValue,
                onTap: () => onSelected(option.value),
              ),
            )
            .toList(growable: false);

        if (useWrap) {
          return Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: children
                .map(
                  (child) => SizedBox(
                    width: constraints.maxWidth > 0
                        ? (constraints.maxWidth - AppSpacing.md) / 2
                        : null,
                    child: child,
                  ),
                )
                .toList(growable: false),
          );
        }

        return Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i != children.length - 1) const SizedBox(width: AppSpacing.md),
            ],
          ],
        );
      },
    );
  }
}

class _SegmentTile<T> extends StatelessWidget {
  const _SegmentTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final NeonSegmentOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isSelected ? AppColors.primaryBright : AppColors.stroke,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : const [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  Icon(
                    option.icon,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(
                  option.label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                if (option.caption != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    option.caption!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary.withValues(alpha: 0.84)
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
