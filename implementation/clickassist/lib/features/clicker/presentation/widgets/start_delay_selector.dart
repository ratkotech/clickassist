import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../widgets/neon_segmented_control.dart';

class StartDelaySelector extends StatelessWidget {
  const StartDelaySelector({
    super.key,
    required this.startDelayMs,
    required this.onPresetSelected,
    required this.onCustomChanged,
  });

  final int startDelayMs;
  final ValueChanged<int> onPresetSelected;
  final ValueChanged<String> onCustomChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = switch (startDelayMs) {
      0 => 0,
      3000 => 3,
      5000 => 5,
      10000 => 10,
      _ => -1,
    };

    return Column(
      children: [
        NeonSegmentedControl<int>(
          options: const [
            NeonSegmentOption(value: 0, label: 'Instant', caption: '0s'),
            NeonSegmentOption(value: 3, label: '3s', caption: 'Short'),
            NeonSegmentOption(value: 5, label: '5s', caption: 'Ready'),
            NeonSegmentOption(value: 10, label: '10s', caption: 'Setup'),
            NeonSegmentOption(value: -1, label: 'Custom', caption: 'Seconds'),
          ],
          selectedValue: selectedValue,
          onSelected: (value) {
            if (value >= 0) {
              onPresetSelected(value);
            }
          },
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
              const Icon(Icons.timer_outlined, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  key: ValueKey('start-delay-$startDelayMs'),
                  initialValue: (startDelayMs / 1000).round().toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Custom delay (seconds)',
                    isDense: true,
                  ),
                  onChanged: onCustomChanged,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${(startDelayMs / 1000).toStringAsFixed(startDelayMs % 1000 == 0 ? 0 : 1)}s',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
