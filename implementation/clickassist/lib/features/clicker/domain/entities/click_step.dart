enum ClickStepActionType { tap, swipe }

class ClickStep {
  const ClickStep({
    required this.id,
    required this.pointId,
    required this.label,
    required this.actionType,
    required this.endPointId,
    required this.delayMs,
    required this.pressDurationMs,
  });

  final String id;
  final String pointId;
  final String label;
  final ClickStepActionType actionType;
  final String? endPointId;
  final int delayMs;
  final int pressDurationMs;

  ClickStep copyWith({
    String? id,
    String? pointId,
    String? label,
    ClickStepActionType? actionType,
    String? endPointId,
    int? delayMs,
    int? pressDurationMs,
  }) {
    return ClickStep(
      id: id ?? this.id,
      pointId: pointId ?? this.pointId,
      label: label ?? this.label,
      actionType: actionType ?? this.actionType,
      endPointId: endPointId ?? this.endPointId,
      delayMs: delayMs ?? this.delayMs,
      pressDurationMs: pressDurationMs ?? this.pressDurationMs,
    );
  }
}
