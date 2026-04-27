import 'click_input_mode.dart';
import 'click_point_timing_mode.dart';
import 'click_mode.dart';
import 'click_point.dart';
import 'click_step.dart';
import 'tap_pattern.dart';

class ClickerPreset {
  const ClickerPreset({
    required this.id,
    required this.name,
    required this.activeInputMode,
    required this.intervalMs,
    required this.showGestureIndicator,
    required this.startDelayEnabled,
    required this.startDelayMs,
    required this.selectedPattern,
    required this.clickMode,
    required this.targetCycles,
    required this.isMultiClickEnabled,
    required this.pointTimingMode,
    required this.manualClickPoints,
    required this.manualClickSteps,
    required this.mimicClickPoints,
    required this.mimicClickSteps,
    required this.createdAtIso,
  });

  final String id;
  final String name;
  final ClickInputMode activeInputMode;
  final int intervalMs;
  final bool showGestureIndicator;
  final bool startDelayEnabled;
  final int startDelayMs;
  final TapPattern selectedPattern;
  final ClickMode clickMode;
  final int targetCycles;
  final bool isMultiClickEnabled;
  final ClickPointTimingMode pointTimingMode;
  final List<ClickPoint> manualClickPoints;
  final List<ClickStep> manualClickSteps;
  final List<ClickPoint> mimicClickPoints;
  final List<ClickStep> mimicClickSteps;
  final String createdAtIso;

  factory ClickerPreset.fromMap(Map<dynamic, dynamic> map) {
    List<ClickPoint> parsePoints(List? rawPoints) {
      return (rawPoints ?? const [])
          .map(
            (point) => ClickPoint(
              id: point['id'] as String,
              label: point['label'] as String,
              x: (point['x'] as num).toDouble(),
              y: (point['y'] as num).toDouble(),
              xPercent: (point['xPercent'] as num?)?.toDouble() ?? 0,
              yPercent: (point['yPercent'] as num?)?.toDouble() ?? 0,
            ),
          )
          .toList();
    }

    List<ClickStep> parseSteps(List? rawSteps) {
      return (rawSteps ?? const [])
          .map(
            (step) => ClickStep(
              id: step['id'] as String,
              pointId: step['pointId'] as String,
              label: step['label'] as String,
              actionType: ClickStepActionType.values.firstWhere(
                (type) => type.name == step['actionType'],
                orElse: () => ClickStepActionType.tap,
              ),
              endPointId: step['endPointId'] as String?,
              delayMs: step['delayMs'] as int? ?? 500,
              pressDurationMs: step['pressDurationMs'] as int? ?? 24,
            ),
          )
          .toList();
    }

    return ClickerPreset(
      id: map['id'] as String,
      name: map['name'] as String,
      activeInputMode: ClickInputMode.values.firstWhere(
        (mode) => mode.value == map['activeInputMode'],
        orElse: () => ClickInputMode.manual,
      ),
      intervalMs: map['intervalMs'] as int,
      showGestureIndicator: map['showGestureIndicator'] as bool? ?? true,
      startDelayEnabled: map['startDelayEnabled'] as bool? ?? false,
      startDelayMs: map['startDelayMs'] as int? ?? 0,
      selectedPattern: TapPattern.values.firstWhere(
        (pattern) => pattern.value == map['selectedPattern'],
        orElse: () => TapPattern.single,
      ),
      clickMode: ClickMode.values.firstWhere(
        (mode) => mode.name == map['clickMode'],
        orElse: () => ClickMode.infinite,
      ),
      targetCycles: map['targetCycles'] as int? ?? 50,
      isMultiClickEnabled: map['isMultiClickEnabled'] as bool? ?? false,
      pointTimingMode: ClickPointTimingMode.values.firstWhere(
        (mode) => mode.value == map['pointTimingMode'],
        orElse: () => ClickPointTimingMode.sequential,
      ),
      manualClickPoints: parsePoints(
        map['manualClickPoints'] as List? ?? map['clickPoints'] as List?,
      ),
      manualClickSteps: parseSteps(
        map['manualClickSteps'] as List? ?? map['clickSteps'] as List?,
      ),
      mimicClickPoints: parsePoints(map['mimicClickPoints'] as List?),
      mimicClickSteps: parseSteps(map['mimicClickSteps'] as List?),
      createdAtIso: map['createdAtIso'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> serializePoints(List<ClickPoint> points) {
      return points
          .map(
            (point) => {
              'id': point.id,
              'label': point.label,
              'x': point.x,
              'y': point.y,
              'xPercent': point.xPercent,
              'yPercent': point.yPercent,
            },
          )
          .toList();
    }

    List<Map<String, dynamic>> serializeSteps(List<ClickStep> steps) {
      return steps
          .map(
            (step) => {
              'id': step.id,
              'pointId': step.pointId,
              'label': step.label,
              'actionType': step.actionType.name,
              'endPointId': step.endPointId,
              'delayMs': step.delayMs,
              'pressDurationMs': step.pressDurationMs,
            },
          )
          .toList();
    }

    return {
      'id': id,
      'name': name,
      'activeInputMode': activeInputMode.value,
      'intervalMs': intervalMs,
      'showGestureIndicator': showGestureIndicator,
      'startDelayEnabled': startDelayEnabled,
      'startDelayMs': startDelayMs,
      'selectedPattern': selectedPattern.value,
      'clickMode': clickMode.name,
      'targetCycles': targetCycles,
      'isMultiClickEnabled': isMultiClickEnabled,
      'pointTimingMode': pointTimingMode.value,
      'manualClickPoints': serializePoints(manualClickPoints),
      'manualClickSteps': serializeSteps(manualClickSteps),
      'mimicClickPoints': serializePoints(mimicClickPoints),
      'mimicClickSteps': serializeSteps(mimicClickSteps),
      'createdAtIso': createdAtIso,
    };
  }
}
