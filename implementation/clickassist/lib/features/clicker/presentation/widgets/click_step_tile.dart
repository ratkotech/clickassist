import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/click_point.dart';
import '../../domain/entities/click_step.dart';

class ClickStepTile extends StatelessWidget {
  const ClickStepTile({
    super.key,
    required this.index,
    required this.step,
    required this.availablePoints,
    required this.onActionTypeChanged,
    required this.onPointChanged,
    required this.onEndPointChanged,
    required this.onDelayChanged,
    required this.onDurationChanged,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
    required this.canMoveUp,
    required this.canMoveDown,
  });

  final int index;
  final ClickStep step;
  final List<ClickPoint> availablePoints;
  final ValueChanged<ClickStepActionType?> onActionTypeChanged;
  final ValueChanged<String?> onPointChanged;
  final ValueChanged<String?> onEndPointChanged;
  final ValueChanged<String> onDelayChanged;
  final ValueChanged<String> onDurationChanged;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onRemove;
  final bool canMoveUp;
  final bool canMoveDown;

  @override
  Widget build(BuildContext context) {
    final startPoint = availablePoints
        .where((point) => point.id == step.pointId)
        .firstOrNull;
    final endPoint = availablePoints
        .where((point) => point.id == step.endPointId)
        .firstOrNull;
    final swipeDirection = step.actionType == ClickStepActionType.swipe
        ? _swipeDirection(startPoint, endPoint)
        : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.stroke),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 430;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
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
                  Text(
                    'Pattern Step ${index + 1}',
                    style: AppTextStyles.titleMedium,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: canMoveUp ? onMoveUp : null,
                        icon: const Icon(Icons.keyboard_arrow_up_rounded),
                      ),
                      IconButton(
                        onPressed: canMoveDown ? onMoveDown : null,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<ClickStepActionType>(
                initialValue: step.actionType,
                dropdownColor: AppColors.surface,
                decoration: const InputDecoration(
                  labelText: 'Action',
                  prefixIcon: Icon(Icons.ads_click_outlined),
                ),
                items: ClickStepActionType.values
                    .map(
                      (type) => DropdownMenuItem<ClickStepActionType>(
                        value: type,
                        child: Text(
                          type == ClickStepActionType.tap ? 'Tap' : 'Swipe',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onActionTypeChanged,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue:
                    availablePoints.any((point) => point.id == step.pointId)
                    ? step.pointId
                    : (availablePoints.isEmpty ? null : availablePoints.first.id),
                dropdownColor: AppColors.surface,
                decoration: const InputDecoration(
                  labelText: 'Target',
                  prefixIcon: Icon(Icons.my_location_outlined),
                ),
                items: availablePoints
                    .map(
                      (point) => DropdownMenuItem<String>(
                        value: point.id,
                        child: Text(point.label),
                      ),
                    )
                    .toList(),
                onChanged: onPointChanged,
              ),
              if (step.actionType == ClickStepActionType.swipe) ...[
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue:
                      availablePoints.any((point) => point.id == step.endPointId)
                      ? step.endPointId
                      : availablePoints
                            .where((point) => point.id != step.pointId)
                            .firstOrNull
                            ?.id,
                  dropdownColor: AppColors.surface,
                  decoration: const InputDecoration(
                    labelText: 'Swipe To',
                    prefixIcon: Icon(Icons.swipe_outlined),
                  ),
                  items: availablePoints
                      .where((point) => point.id != step.pointId)
                      .map(
                        (point) => DropdownMenuItem<String>(
                          value: point.id,
                          child: Text(point.label),
                        ),
                      )
                      .toList(),
                  onChanged: onEndPointChanged,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _StepBadge(
                    icon: step.actionType == ClickStepActionType.tap
                        ? Icons.touch_app_outlined
                        : Icons.swipe_outlined,
                    label: step.actionType == ClickStepActionType.tap
                        ? 'Tap'
                        : 'Swipe${swipeDirection != null ? ' $swipeDirection' : ''}',
                  ),
                  _StepBadge(
                    icon: Icons.place_outlined,
                    label: step.actionType == ClickStepActionType.swipe
                        ? '${startPoint?.label ?? step.label} -> ${endPoint?.label ?? 'Select end'}'
                        : (startPoint?.label ?? step.label),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (isNarrow) ...[
                TextFormField(
                  key: ValueKey('${step.id}-delay-${step.delayMs}'),
                  initialValue: '${step.delayMs}',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Delay After (ms)',
                    prefixIcon: Icon(Icons.timer_outlined),
                  ),
                  onChanged: onDelayChanged,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  key: ValueKey('${step.id}-press-${step.pressDurationMs}'),
                  initialValue: '${step.pressDurationMs}',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Press Duration (ms)',
                    prefixIcon: Icon(Icons.touch_app_outlined),
                  ),
                  onChanged: onDurationChanged,
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('${step.id}-delay-${step.delayMs}'),
                        initialValue: '${step.delayMs}',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Delay After (ms)',
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                        onChanged: onDelayChanged,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('${step.id}-press-${step.pressDurationMs}'),
                        initialValue: '${step.pressDurationMs}',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Press Duration (ms)',
                          prefixIcon: Icon(Icons.touch_app_outlined),
                        ),
                        onChanged: onDurationChanged,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Delay ${step.delayMs}ms  |  Duration ${step.pressDurationMs}ms',
                style: AppTextStyles.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  String? _swipeDirection(ClickPoint? startPoint, ClickPoint? endPoint) {
    if (startPoint == null || endPoint == null) {
      return null;
    }

    final deltaX = endPoint.xPercent - startPoint.xPercent;
    final deltaY = endPoint.yPercent - startPoint.yPercent;

    if (deltaX.abs() >= deltaY.abs()) {
      return deltaX >= 0 ? 'Right' : 'Left';
    }

    return deltaY >= 0 ? 'Down' : 'Up';
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
