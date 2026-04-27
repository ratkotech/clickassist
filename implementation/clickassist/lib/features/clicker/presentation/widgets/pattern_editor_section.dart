import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/click_point.dart';
import '../../domain/entities/click_step.dart';
import 'click_step_tile.dart';

class PatternEditorSection extends StatelessWidget {
  const PatternEditorSection({
    super.key,
    required this.clickPoints,
    required this.clickSteps,
    required this.isMimicMode,
    required this.onAddStep,
    required this.onRecordMimic,
    required this.onClearSteps,
    required this.onRemoveStep,
    required this.onActionTypeChanged,
    required this.onPointChanged,
    required this.onEndPointChanged,
    required this.onDelayChanged,
    required this.onDurationChanged,
    required this.onMoveStepUp,
    required this.onMoveStepDown,
  });

  final List<ClickPoint> clickPoints;
  final List<ClickStep> clickSteps;
  final bool isMimicMode;
  final VoidCallback onAddStep;
  final VoidCallback onRecordMimic;
  final VoidCallback onClearSteps;
  final ValueChanged<String> onRemoveStep;
  final void Function(String stepId, ClickStepActionType actionType)
  onActionTypeChanged;
  final void Function(String stepId, String pointId) onPointChanged;
  final void Function(String stepId, String pointId) onEndPointChanged;
  final void Function(String stepId, String value) onDelayChanged;
  final void Function(String stepId, String value) onDurationChanged;
  final ValueChanged<String> onMoveStepUp;
  final ValueChanged<String> onMoveStepDown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: clickPoints.isEmpty ? null : onAddStep,
              icon: const Icon(Icons.alt_route_rounded),
              label: const Text('Add Step'),
            ),
            if (clickSteps.isNotEmpty)
              OutlinedButton.icon(
                onPressed: onClearSteps,
                icon: const Icon(Icons.layers_clear_outlined),
                label: Text(isMimicMode ? 'Clear Mimic' : 'Clear All'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              onPressed: onRecordMimic,
              icon: const Icon(Icons.gesture_rounded),
              label: Text(
                isMimicMode ? 'Re-record Mimic' : 'Record Mimic Pattern',
              ),
            ),
            _PatternStatChip(
              label:
                  '${clickSteps.where((step) => step.actionType == ClickStepActionType.tap).length} taps',
            ),
            _PatternStatChip(
              label:
                  '${clickSteps.where((step) => step.actionType == ClickStepActionType.swipe).length} swipes',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (clickSteps.isEmpty)
          Text(
            isMimicMode
                ? 'No mimic actions saved yet. Record a mimic pattern to fill this editor.'
                : 'Capture at least one target, then add a step to start building a route.',
            style: AppTextStyles.bodyMedium,
          )
        else
          ...List.generate(
            clickSteps.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == clickSteps.length - 1 ? 0 : AppSpacing.md,
              ),
              child: ClickStepTile(
                index: index,
                step: clickSteps[index],
                availablePoints: clickPoints,
                canMoveUp: index > 0,
                canMoveDown: index < clickSteps.length - 1,
                onActionTypeChanged: (actionType) {
                  if (actionType == null) {
                    return;
                  }
                  onActionTypeChanged(clickSteps[index].id, actionType);
                },
                onPointChanged: (pointId) {
                  if (pointId == null) {
                    return;
                  }
                  onPointChanged(clickSteps[index].id, pointId);
                },
                onEndPointChanged: (pointId) {
                  if (pointId == null) {
                    return;
                  }
                  onEndPointChanged(clickSteps[index].id, pointId);
                },
                onDelayChanged: (value) =>
                    onDelayChanged(clickSteps[index].id, value),
                onDurationChanged: (value) =>
                    onDurationChanged(clickSteps[index].id, value),
                onMoveUp: () => onMoveStepUp(clickSteps[index].id),
                onMoveDown: () => onMoveStepDown(clickSteps[index].id),
                onRemove: () => onRemoveStep(clickSteps[index].id),
              ),
            ),
          ),
      ],
    );
  }
}

class _PatternStatChip extends StatelessWidget {
  const _PatternStatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Text(label, style: AppTextStyles.bodySmall),
    );
  }
}
