import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../widgets/neon_segmented_control.dart';
import '../../domain/entities/click_point_timing_mode.dart';

class PointTimingModeSelector extends StatelessWidget {
  const PointTimingModeSelector({
    super.key,
    required this.selectedMode,
    required this.enabled,
    required this.onSelected,
  });

  final ClickPointTimingMode selectedMode;
  final bool enabled;
  final ValueChanged<ClickPointTimingMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final content = NeonSegmentedControl<ClickPointTimingMode>(
      options: const [
        NeonSegmentOption(
          value: ClickPointTimingMode.sequential,
          label: 'Sequential',
          caption: 'One after another',
          icon: Icons.segment_rounded,
        ),
        NeonSegmentOption(
          value: ClickPointTimingMode.simultaneous,
          label: 'Simultaneous',
          caption: 'All at once',
          icon: Icons.blur_on_rounded,
        ),
      ],
      selectedValue: selectedMode,
      onSelected: onSelected,
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: enabled ? 1 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: content,
        ),
      ),
    );
  }
}
