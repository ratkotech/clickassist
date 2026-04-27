import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../widgets/neon_segmented_control.dart';
import '../providers/clicker_state.dart';

class SpeedPresetSelector extends StatelessWidget {
  const SpeedPresetSelector({
    super.key,
    required this.selectedPreset,
    required this.intervalMs,
    required this.onPresetSelected,
    required this.onStepInterval,
  });

  final SpeedPreset selectedPreset;
  final int intervalMs;
  final ValueChanged<SpeedPreset> onPresetSelected;
  final ValueChanged<int> onStepInterval;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NeonSegmentedControl<SpeedPreset>(
          options: SpeedPreset.values
              .where((preset) => preset != SpeedPreset.custom)
              .map(
                (preset) => NeonSegmentOption(
                  value: preset,
                  label: preset.label,
                  caption: '${preset.intervalMs} ms',
                ),
              )
              .toList(growable: false),
          selectedValue: selectedPreset == SpeedPreset.custom
              ? _closestPreset(intervalMs)
              : selectedPreset,
          onSelected: onPresetSelected,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Custom', style: AppTextStyles.titleMedium),
                ],
              ),
              const Spacer(),
              _SquareButton(
                icon: Icons.remove_rounded,
                onTap: () => onStepInterval(intervalMs <= 100 ? -10 : -50),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '$intervalMs ms',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _SquareButton(
                icon: Icons.add_rounded,
                onTap: () => onStepInterval(intervalMs < 100 ? 10 : 50),
              ),
            ],
          ),
        ),
      ],
    );
  }

  SpeedPreset _closestPreset(int value) {
    if (value <= 10) return SpeedPreset.ultra;
    if (value <= 30) return SpeedPreset.turbo;
    if (value <= 100) return SpeedPreset.fast;
    if (value <= 500) return SpeedPreset.normal;
    return SpeedPreset.slow;
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}
