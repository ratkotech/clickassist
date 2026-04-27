import '../../domain/entities/click_input_mode.dart';
import '../../domain/entities/click_point_timing_mode.dart';
import '../../domain/entities/click_mode.dart';
import '../../domain/entities/clicker_preset.dart';
import '../../domain/entities/click_point.dart';
import '../../domain/entities/click_step.dart';
import '../../domain/entities/tap_pattern.dart';

enum SpeedPreset {
  slow(2000, 'Slow'),
  normal(500, 'Normal'),
  fast(100, 'Fast'),
  turbo(30, 'Turbo'),
  ultra(10, 'Ultra'),
  custom(null, 'Custom');

  const SpeedPreset(this.intervalMs, this.label);

  final int? intervalMs;
  final String label;
}

class ClickerState {
  const ClickerState({
    required this.intervalMs,
    required this.isRunning,
    required this.activeInputMode,
    required this.isMultiClickEnabled,
    required this.pointTimingMode,
    required this.showGestureIndicator,
    required this.accessibilityEnabled,
    required this.overlayPermissionEnabled,
    required this.overlayEnabled,
    required this.overlayVisible,
    required this.pointPickerActive,
    required this.accessibilityServiceConnected,
    required this.batteryOptimizationIgnored,
    required this.batteryLevelPercent,
    required this.batteryCharging,
    required this.thermalStatus,
    required this.notificationsEnabled,
    required this.startDelayEnabled,
    required this.startDelayMs,
    required this.selectedPattern,
    required this.clickMode,
    required this.targetCycles,
    required this.speedPreset,
    required this.totalClicks,
    required this.statusMessage,
    required this.safetyWarning,
    required this.presets,
    required this.manualClickPoints,
    required this.manualClickSteps,
    required this.mimicClickPoints,
    required this.mimicClickSteps,
  });

  factory ClickerState.initial() {
    return const ClickerState(
      intervalMs: 500,
      isRunning: false,
      activeInputMode: ClickInputMode.manual,
      isMultiClickEnabled: false,
      pointTimingMode: ClickPointTimingMode.sequential,
      showGestureIndicator: true,
      accessibilityEnabled: false,
      overlayPermissionEnabled: false,
      overlayEnabled: false,
      overlayVisible: false,
      pointPickerActive: false,
      accessibilityServiceConnected: false,
      batteryOptimizationIgnored: false,
      batteryLevelPercent: -1,
      batteryCharging: false,
      thermalStatus: 0,
      notificationsEnabled: true,
      startDelayEnabled: false,
      startDelayMs: 3000,
      selectedPattern: TapPattern.single,
      clickMode: ClickMode.infinite,
      targetCycles: 50,
      speedPreset: SpeedPreset.normal,
      totalClicks: 0,
      statusMessage: 'Configure below, then press START',
      safetyWarning: null,
      presets: [],
      manualClickPoints: [],
      manualClickSteps: [],
      mimicClickPoints: [],
      mimicClickSteps: [],
    );
  }

  final int intervalMs;
  final bool isRunning;
  final ClickInputMode activeInputMode;
  final bool isMultiClickEnabled;
  final ClickPointTimingMode pointTimingMode;
  final bool showGestureIndicator;
  final bool accessibilityEnabled;
  final bool overlayPermissionEnabled;
  final bool overlayEnabled;
  final bool overlayVisible;
  final bool pointPickerActive;
  final bool accessibilityServiceConnected;
  final bool batteryOptimizationIgnored;
  final int batteryLevelPercent;
  final bool batteryCharging;
  final int thermalStatus;
  final bool notificationsEnabled;
  final bool startDelayEnabled;
  final int startDelayMs;
  final TapPattern selectedPattern;
  final ClickMode clickMode;
  final int targetCycles;
  final SpeedPreset speedPreset;
  final int totalClicks;
  final String statusMessage;
  final String? safetyWarning;
  final List<ClickerPreset> presets;
  final List<ClickPoint> manualClickPoints;
  final List<ClickStep> manualClickSteps;
  final List<ClickPoint> mimicClickPoints;
  final List<ClickStep> mimicClickSteps;

  List<ClickPoint> get activeClickPoints =>
      activeInputMode == ClickInputMode.manual
      ? manualClickPoints
      : mimicClickPoints;

  List<ClickStep> get activeClickSteps =>
      activeInputMode == ClickInputMode.manual
      ? manualClickSteps
      : mimicClickSteps;

  double get actionsPerSecond {
    final steps = activeClickSteps.isEmpty
        ? const <ClickStep>[]
        : isMultiClickEnabled
        ? activeClickSteps
        : [activeClickSteps.first];
    if (steps.isEmpty) {
      return 0;
    }

    final actionsPerCycle = steps.fold<int>(
      0,
      (total, step) =>
          total +
          (step.actionType == ClickStepActionType.swipe
              ? 1
              : selectedPattern.tapsPerCycle),
    );
    final slowestStepMs = steps.fold<int>(
      intervalMs,
      (slowest, step) => step.delayMs > slowest ? step.delayMs : slowest,
    );
    final cycleMs = isMultiClickEnabled ? slowestStepMs : steps.first.delayMs;
    return actionsPerCycle * 1000 / cycleMs.clamp(10, 5000);
  }

  ClickerState copyWith({
    int? intervalMs,
    bool? isRunning,
    ClickInputMode? activeInputMode,
    bool? isMultiClickEnabled,
    ClickPointTimingMode? pointTimingMode,
    bool? showGestureIndicator,
    bool? accessibilityEnabled,
    bool? overlayPermissionEnabled,
    bool? overlayEnabled,
    bool? overlayVisible,
    bool? pointPickerActive,
    bool? accessibilityServiceConnected,
    bool? batteryOptimizationIgnored,
    int? batteryLevelPercent,
    bool? batteryCharging,
    int? thermalStatus,
    bool? notificationsEnabled,
    bool? startDelayEnabled,
    int? startDelayMs,
    TapPattern? selectedPattern,
    ClickMode? clickMode,
    int? targetCycles,
    SpeedPreset? speedPreset,
    int? totalClicks,
    String? statusMessage,
    String? safetyWarning,
    List<ClickerPreset>? presets,
    List<ClickPoint>? manualClickPoints,
    List<ClickStep>? manualClickSteps,
    List<ClickPoint>? mimicClickPoints,
    List<ClickStep>? mimicClickSteps,
  }) {
    return ClickerState(
      intervalMs: intervalMs ?? this.intervalMs,
      isRunning: isRunning ?? this.isRunning,
      activeInputMode: activeInputMode ?? this.activeInputMode,
      isMultiClickEnabled: isMultiClickEnabled ?? this.isMultiClickEnabled,
      pointTimingMode: pointTimingMode ?? this.pointTimingMode,
      showGestureIndicator: showGestureIndicator ?? this.showGestureIndicator,
      accessibilityEnabled: accessibilityEnabled ?? this.accessibilityEnabled,
      overlayPermissionEnabled:
          overlayPermissionEnabled ?? this.overlayPermissionEnabled,
      overlayEnabled: overlayEnabled ?? this.overlayEnabled,
      overlayVisible: overlayVisible ?? this.overlayVisible,
      pointPickerActive: pointPickerActive ?? this.pointPickerActive,
      accessibilityServiceConnected:
          accessibilityServiceConnected ?? this.accessibilityServiceConnected,
      batteryOptimizationIgnored:
          batteryOptimizationIgnored ?? this.batteryOptimizationIgnored,
      batteryLevelPercent: batteryLevelPercent ?? this.batteryLevelPercent,
      batteryCharging: batteryCharging ?? this.batteryCharging,
      thermalStatus: thermalStatus ?? this.thermalStatus,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      startDelayEnabled: startDelayEnabled ?? this.startDelayEnabled,
      startDelayMs: startDelayMs ?? this.startDelayMs,
      selectedPattern: selectedPattern ?? this.selectedPattern,
      clickMode: clickMode ?? this.clickMode,
      targetCycles: targetCycles ?? this.targetCycles,
      speedPreset: speedPreset ?? this.speedPreset,
      totalClicks: totalClicks ?? this.totalClicks,
      statusMessage: statusMessage ?? this.statusMessage,
      safetyWarning: safetyWarning ?? this.safetyWarning,
      presets: presets ?? this.presets,
      manualClickPoints: manualClickPoints ?? this.manualClickPoints,
      manualClickSteps: manualClickSteps ?? this.manualClickSteps,
      mimicClickPoints: mimicClickPoints ?? this.mimicClickPoints,
      mimicClickSteps: mimicClickSteps ?? this.mimicClickSteps,
    );
  }
}
