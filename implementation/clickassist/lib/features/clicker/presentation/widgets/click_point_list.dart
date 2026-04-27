import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/click_point.dart';
import 'click_point_tile.dart';

class ClickPointList extends StatelessWidget {
  const ClickPointList({
    super.key,
    required this.clickPoints,
    required this.onRemove,
    required this.onAdd,
    required this.onEdit,
    required this.multiClickEnabled,
    required this.onMultiClickChanged,
    required this.pointPickerActive,
    required this.onCancelPicker,
  });

  final List<ClickPoint> clickPoints;
  final ValueChanged<String> onRemove;
  final VoidCallback onAdd;
  final ValueChanged<String> onEdit;
  final bool multiClickEnabled;
  final ValueChanged<bool> onMultiClickChanged;
  final bool pointPickerActive;
  final VoidCallback onCancelPicker;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
              child: OutlinedButton.icon(
                onPressed: pointPickerActive ? onCancelPicker : onAdd,
                icon: Icon(
                  pointPickerActive
                      ? Icons.close_rounded
                      : Icons.add_location_alt_outlined,
                ),
                label: Text(
                  pointPickerActive ? 'Cancel Picker' : 'Pick On Screen',
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Multi-click', style: AppTextStyles.bodyLarge),
                  ),
                  Switch(
                    value: multiClickEnabled,
                    onChanged: clickPoints.length > 1
                        ? onMultiClickChanged
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (pointPickerActive) ...[
          Text(
            'Picker active: move the marker in any app, then press Confirm to save the exact target.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (clickPoints.isEmpty)
          Text(
            'No click points added yet. Use Pick On Screen to capture your first target.',
            style: AppTextStyles.bodyMedium,
          )
        else
          ...List.generate(
            clickPoints.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == clickPoints.length - 1 ? 0 : AppSpacing.md,
              ),
              child: ClickPointTile(
                index: index,
                clickPoint: clickPoints[index],
                onEdit: () => onEdit(clickPoints[index].id),
                onRemove: () => onRemove(clickPoints[index].id),
              ),
            ),
          ),
      ],
    );
  }
}
