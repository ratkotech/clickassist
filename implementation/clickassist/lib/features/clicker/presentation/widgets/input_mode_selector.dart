import 'package:flutter/material.dart';

import '../../../../widgets/neon_segmented_control.dart';
import '../../domain/entities/click_input_mode.dart';

class InputModeSelector extends StatelessWidget {
  const InputModeSelector({
    super.key,
    required this.selectedMode,
    required this.manualStepCount,
    required this.mimicStepCount,
    required this.onSelected,
  });

  final ClickInputMode selectedMode;
  final int manualStepCount;
  final int mimicStepCount;
  final ValueChanged<ClickInputMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return NeonSegmentedControl<ClickInputMode>(
      options: [
        NeonSegmentOption(
          value: ClickInputMode.manual,
          label: 'Click Points',
          caption: '$manualStepCount steps',
          icon: Icons.my_location_rounded,
        ),
        NeonSegmentOption(
          value: ClickInputMode.mimic,
          label: 'Mimic',
          caption: '$mimicStepCount steps',
          icon: Icons.gesture_rounded,
        ),
      ],
      selectedValue: selectedMode,
      onSelected: onSelected,
    );
  }
}
