import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/click_mode.dart';

class ClickModeSelector extends StatelessWidget {
  const ClickModeSelector({
    super.key,
    required this.clickMode,
    required this.targetCycles,
    required this.onModeChanged,
    required this.onTargetCyclesChanged,
  });

  final ClickMode clickMode;
  final int targetCycles;
  final ValueChanged<ClickMode> onModeChanged;
  final ValueChanged<int> onTargetCyclesChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ModeButton(
                label: 'Infinite',
                icon: Icons.all_inclusive_rounded,
                isSelected: clickMode == ClickMode.infinite,
                onTap: () => onModeChanged(ClickMode.infinite),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ModeButton(
                label: 'Count',
                icon: Icons.adjust_rounded,
                isSelected: clickMode == ClickMode.count,
                onTap: () => onModeChanged(ClickMode.count),
              ),
            ),
          ],
        ),
        if (clickMode == ClickMode.count) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _StepperButton(
                icon: Icons.remove_rounded,
                onTap: () => onTargetCyclesChanged(targetCycles - 1),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Text(
                    '$targetCycles cycles',
                    style: AppTextStyles.titleMedium,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _StepperButton(
                icon: Icons.add_rounded,
                onTap: () => onTargetCyclesChanged(targetCycles + 1),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}
