import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/services/click_assist_platform_service.dart';
import '../../../../core/services/app_preferences_service.dart';
import '../../data/services/clicker_preset_storage.dart';
import '../../domain/entities/click_input_mode.dart';
import '../../domain/entities/click_point_timing_mode.dart';
import '../../domain/entities/click_mode.dart';
import '../../domain/entities/click_point.dart';
import '../../domain/entities/click_step.dart';
import '../../domain/entities/clicker_preset.dart';
import '../../domain/entities/tap_pattern.dart';
import 'clicker_state.dart';

final clickerControllerProvider =
    NotifierProvider<ClickerController, ClickerState>(ClickerController.new);

class ClickerController extends Notifier<ClickerState> {
  StreamSubscription<NativeClickerStatus>? _statusSubscription;
  late final ClickAssistPlatformService _platformService;
  late final ClickerPresetStorage _presetStorage;
  late final AppPreferencesService _appPreferencesService;
  bool _initialized = false;
  int _lastProcessedCaptureSequence = 0;
  String? _editingPointId;

  @override
  ClickerState build() {
    _platformService = ref.read(clickAssistPlatformServiceProvider);
    _presetStorage = ref.read(clickerPresetStorageProvider);
    _appPreferencesService = const AppPreferencesService();
    _statusSubscription ??= _platformService.statusStream().listen(
      _applyStatus,
    );
    ref.onDispose(() => _statusSubscription?.cancel());

    if (!_initialized) {
      _initialized = true;
      Future.microtask(_initialize);
    }

    return ClickerState.initial();
  }

  Future<void> _initialize() async {
    await loadPresets();
    await refreshStatus();
  }

  Future<void> refreshStatus() async {
    await _syncConfig();
    final status = await _platformService.getStatus();
    _applyStatus(status);
  }

  Future<void> loadPresets() async {
    final presets = await _presetStorage.loadPresets();
    state = state.copyWith(presets: presets);
  }

  Future<void> saveCurrentAsPreset(String name, {String? presetId}) async {
    final now = DateTime.now();
    final isManualPreset = state.activeInputMode == ClickInputMode.manual;
    final preset = ClickerPreset(
      id: presetId ?? now.microsecondsSinceEpoch.toString(),
      name: name.trim().isEmpty ? 'Preset ${state.presets.length + 1}' : name.trim(),
      activeInputMode: state.activeInputMode,
      intervalMs: state.intervalMs,
      showGestureIndicator: state.showGestureIndicator,
      startDelayEnabled: state.startDelayEnabled,
      startDelayMs: state.startDelayMs,
      selectedPattern: state.selectedPattern,
      clickMode: state.clickMode,
      targetCycles: state.targetCycles,
      isMultiClickEnabled: state.isMultiClickEnabled,
      pointTimingMode: state.pointTimingMode,
      manualClickPoints: isManualPreset ? state.manualClickPoints : const [],
      manualClickSteps: isManualPreset ? state.manualClickSteps : const [],
      mimicClickPoints: isManualPreset ? const [] : state.mimicClickPoints,
      mimicClickSteps: isManualPreset ? const [] : state.mimicClickSteps,
      createdAtIso: now.toIso8601String(),
    );

    await _presetStorage.savePreset(preset);
    await loadPresets();
    state = state.copyWith(
      statusMessage: presetId == null
          ? '${preset.name} saved.'
          : '${preset.name} updated.',
    );
  }

  Future<void> deletePreset(String id) async {
    await _presetStorage.deletePreset(id);
    await loadPresets();
    state = state.copyWith(statusMessage: 'Preset removed.');
  }

  Future<void> applyPreset(ClickerPreset preset) async {
    final normalizedManual = _normalizeImportedPattern(
      clickPoints: preset.manualClickPoints,
      clickSteps: preset.manualClickSteps,
      existingPointIds: <String>{},
      existingStepIds: <String>{},
    );
    final manualPoints = normalizedManual.clickPoints;
    final manualSteps = _sanitizeSteps(
      normalizedManual.clickSteps.isEmpty
          ? _defaultStepsFromPoints(
              manualPoints,
              defaultDelayMs: preset.intervalMs,
            )
          : normalizedManual.clickSteps,
      manualPoints,
      defaultDelayMs: preset.intervalMs,
    );

    final normalizedMimic = _normalizeImportedPattern(
      clickPoints: preset.mimicClickPoints,
      clickSteps: preset.mimicClickSteps,
      existingPointIds: <String>{},
      existingStepIds: <String>{},
    );
    final mimicPoints = normalizedMimic.clickPoints;
    final mimicSteps = _sanitizeSteps(
      normalizedMimic.clickSteps,
      mimicPoints,
      defaultDelayMs: preset.intervalMs,
    );

    final requestedInputMode = preset.activeInputMode;
    final hasManualPattern = manualPoints.isNotEmpty && manualSteps.isNotEmpty;
    final hasMimicPattern = mimicPoints.isNotEmpty && mimicSteps.isNotEmpty;
    final nextInputMode = switch (requestedInputMode) {
      ClickInputMode.manual when hasManualPattern => ClickInputMode.manual,
      ClickInputMode.mimic when hasMimicPattern => ClickInputMode.mimic,
      ClickInputMode.manual when hasMimicPattern => ClickInputMode.mimic,
      ClickInputMode.mimic when hasManualPattern => ClickInputMode.manual,
      _ => ClickInputMode.manual,
    };
    final didFallbackToAlternateSource = nextInputMode != requestedInputMode;
    final loadedSourceLabel = nextInputMode.title;
    final loadedManualPoints = nextInputMode == ClickInputMode.manual
        ? manualPoints
        : const <ClickPoint>[];
    final loadedManualSteps = nextInputMode == ClickInputMode.manual
        ? manualSteps
        : const <ClickStep>[];
    final loadedMimicPoints = nextInputMode == ClickInputMode.mimic
        ? mimicPoints
        : const <ClickPoint>[];
    final loadedMimicSteps = nextInputMode == ClickInputMode.mimic
        ? mimicSteps
        : const <ClickStep>[];

    state = state.copyWith(
      intervalMs: preset.intervalMs,
      isRunning: false,
      activeInputMode: nextInputMode,
      startDelayEnabled: preset.startDelayEnabled,
      startDelayMs: preset.startDelayMs,
      showGestureIndicator: preset.showGestureIndicator,
      selectedPattern: preset.selectedPattern,
      clickMode: preset.clickMode,
      targetCycles: preset.targetCycles,
      pointTimingMode: preset.pointTimingMode,
      isMultiClickEnabled:
          preset.isMultiClickEnabled &&
          _stepsForMode(nextInputMode, loadedManualSteps, loadedMimicSteps).length > 1,
      manualClickPoints: loadedManualPoints,
      manualClickSteps: loadedManualSteps,
      mimicClickPoints: loadedMimicPoints,
      mimicClickSteps: loadedMimicSteps,
      speedPreset: _presetFromInterval(preset.intervalMs),
      statusMessage: didFallbackToAlternateSource
          ? '${preset.name} loaded in $loadedSourceLabel because the saved ${requestedInputMode.title.toLowerCase()} data was empty.'
          : '${preset.name} loaded in $loadedSourceLabel.',
      safetyWarning: _nonBlockingSafetyWarning(
        modeOverride: nextInputMode,
        manualPointsOverride: loadedManualPoints,
        manualStepsOverride: loadedManualSteps,
        mimicPointsOverride: loadedMimicPoints,
        mimicStepsOverride: loadedMimicSteps,
      ),
    );
    await _syncConfig();
  }

  Future<void> toggleRunning() async {
    if (state.isRunning) {
      final status = await _platformService.stopClicking();
      _applyStatus(status);
      return;
    }

    final blockingIssue = _blockingSafetyIssue();
    if (blockingIssue != null) {
      state = state.copyWith(
        statusMessage: blockingIssue,
        safetyWarning: blockingIssue,
      );
      return;
    }

    await _syncConfig();
    final status = await _platformService.startClicking(
      intervalMs: state.intervalMs,
      startDelayMs: state.startDelayEnabled ? state.startDelayMs : 0,
      pattern: state.selectedPattern,
      multiClick: state.isMultiClickEnabled,
      pointTimingMode: state.pointTimingMode,
      clickMode: state.clickMode,
      targetCycles: state.targetCycles,
      showGestureIndicator: state.showGestureIndicator,
      clickPoints: state.activeClickPoints,
      clickSteps: state.activeClickSteps,
    );

    _applyStatus(status);
  }

  Future<void> openAccessibilitySettings() async {
    await _platformService.openAccessibilitySettings();
    state = state.copyWith(
      statusMessage: 'Enable ClickAssist in Accessibility, then return here.',
    );
  }

  Future<void> openBatteryOptimizationSettings() async {
    await _platformService.openBatteryOptimizationSettings();
    state = state.copyWith(
      statusMessage:
          'Exclude ClickAssist from battery optimization for better background reliability.',
    );
  }

  Future<void> openOverlaySettings() async {
    await _platformService.openOverlaySettings();
    state = state.copyWith(
      statusMessage:
          'Allow display over other apps, then return here to enable the overlay or target picker.',
    );
  }

  Future<void> openNotificationSettings() async {
    final permissionStatus = await Permission.notification.request();
    if (permissionStatus.isGranted) {
      state = state.copyWith(
        statusMessage: 'Notifications enabled for ClickAssist.',
      );
      await refreshStatus();
      return;
    }

    await _platformService.openNotificationSettings();
    state = state.copyWith(
      statusMessage:
          'Enable notifications so quick native controls stay available.',
    );
  }

  Future<void> toggleOverlay() async {
    if (!state.overlayPermissionEnabled) {
      state = state.copyWith(
        statusMessage:
            'Allow display over other apps, then enable the floating overlay.',
      );
      return;
    }

    await _syncConfig();
    final status = state.overlayEnabled
        ? await _platformService.stopOverlay()
        : await _platformService.startOverlay();
    _applyStatus(status);
  }

  void setInputMode(ClickInputMode mode) {
    final nextSteps = _stepsForMode(mode);
    state = state.copyWith(
      activeInputMode: mode,
      isMultiClickEnabled: nextSteps.length > 1
          ? state.isMultiClickEnabled
          : false,
      statusMessage: mode == ClickInputMode.manual
          ? 'Manual click points selected.'
          : nextSteps.isEmpty
          ? 'Record a mimic pattern first, then run it from here.'
          : 'Mimic pattern selected.',
      safetyWarning: _nonBlockingSafetyWarning(modeOverride: mode),
    );
    _queueConfigSync();
  }

  Future<void> startPointCapture({String? editPointId}) async {
    if (!state.overlayPermissionEnabled) {
      state = state.copyWith(
        statusMessage:
            'Allow display over other apps before selecting click targets.',
      );
      return;
    }

    _editingPointId = editPointId;
    await _syncConfig();
    final status = await _platformService.startPointPicker();
    _applyStatus(status);
  }

  Future<void> cancelPointCapture() async {
    _editingPointId = null;
    final status = await _platformService.stopPointPicker();
    _applyStatus(status);
  }

  Future<String> exportPresetsJson() async {
    final payload = state.presets
        .map((preset) => preset.toMap())
        .toList(growable: false);
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> importPresetsJson(
    String rawJson, {
    required bool replaceExisting,
  }) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
    } on FormatException {
      throw const FormatException('Invalid preset format');
    }

    if (decoded is! List) {
      throw const FormatException('Invalid preset format');
    }

    final importedPresets = <ClickerPreset>[];
    final existingIds = state.presets.map((preset) => preset.id).toSet();

    try {
      for (final entry in decoded) {
        if (entry is! Map) {
          throw const FormatException('Invalid preset format');
        }

        final preset = ClickerPreset.fromMap(Map<dynamic, dynamic>.from(entry));
        final nextId = replaceExisting
            ? preset.id
            : _ensureUniqueId(
                preferredId: preset.id,
                takenIds: existingIds,
                fallbackPrefix: 'preset',
              );
        existingIds.add(nextId);
        importedPresets.add(
          ClickerPreset(
            id: nextId,
            name: preset.name,
            activeInputMode: preset.activeInputMode,
            intervalMs: preset.intervalMs,
            showGestureIndicator: preset.showGestureIndicator,
            startDelayEnabled: preset.startDelayEnabled,
            startDelayMs: preset.startDelayMs,
            selectedPattern: preset.selectedPattern,
            clickMode: preset.clickMode,
            targetCycles: preset.targetCycles,
            isMultiClickEnabled: preset.isMultiClickEnabled,
            pointTimingMode: preset.pointTimingMode,
            manualClickPoints: preset.manualClickPoints,
            manualClickSteps: preset.manualClickSteps,
            mimicClickPoints: preset.mimicClickPoints,
            mimicClickSteps: preset.mimicClickSteps,
            createdAtIso: preset.createdAtIso,
          ),
        );
      }
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Invalid preset format');
    }

    if (importedPresets.isEmpty) {
      throw const FormatException('Invalid preset format');
    }

    if (replaceExisting) {
      await _presetStorage.clearPresets();
    }

    for (final preset in importedPresets) {
      await _presetStorage.savePreset(preset);
    }

    await loadPresets();
    state = state.copyWith(
      statusMessage: 'Presets imported successfully.',
    );
  }

  Future<void> clearPresets() async {
    await _presetStorage.clearPresets();
    await loadPresets();
    state = state.copyWith(statusMessage: 'Saved presets cleared.');
  }

  Future<void> resetAppData() async {
    if (state.isRunning) {
      await _platformService.stopClicking();
    }
    if (state.overlayVisible) {
      await _platformService.stopOverlay();
    }

    await _presetStorage.clearPresets();
    await _appPreferencesService.clearAll();
    _editingPointId = null;
    _lastProcessedCaptureSequence = 0;

    final status = await _platformService.getStatus();
    state = ClickerState.initial().copyWith(
      accessibilityEnabled: status.accessibilityEnabled,
      overlayPermissionEnabled: status.overlayPermissionEnabled,
      overlayEnabled: status.overlayEnabled,
      overlayVisible: status.overlayVisible,
      pointPickerActive: status.pointPickerActive,
      accessibilityServiceConnected: status.accessibilityServiceConnected,
      batteryOptimizationIgnored: status.batteryOptimizationIgnored,
      batteryLevelPercent: status.batteryLevelPercent,
      batteryCharging: status.batteryCharging,
      thermalStatus: status.thermalStatus,
      notificationsEnabled: status.notificationsEnabled,
      isRunning: status.isRunning,
      totalClicks: status.totalClicks,
      statusMessage: 'Local app data reset. Permissions stay under Android settings.',
    );
    await _syncConfig();
  }

  void updateInterval(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return;
    }

    final normalizedInterval = parsed.clamp(10, 5000);
    state = state.copyWith(
      intervalMs: normalizedInterval,
      speedPreset: _presetFromInterval(normalizedInterval),
      manualClickSteps: state.manualClickSteps
          .map(
            (step) => step.delayMs == state.intervalMs
                ? step.copyWith(delayMs: normalizedInterval)
                : step,
          )
          .toList(),
      mimicClickSteps: state.mimicClickSteps
          .map(
            (step) => step.delayMs == state.intervalMs
                ? step.copyWith(delayMs: normalizedInterval)
                : step,
          )
          .toList(),
      safetyWarning: _nonBlockingSafetyWarning(intervalOverride: normalizedInterval),
    );
    _queueConfigSync();
  }

  void selectSpeedPreset(SpeedPreset preset) {
    final interval = preset.intervalMs;
    if (interval == null) {
      state = state.copyWith(speedPreset: SpeedPreset.custom);
      return;
    }

    state = state.copyWith(
      intervalMs: interval,
      speedPreset: preset,
      manualClickSteps: state.manualClickSteps
          .map(
            (step) => step.delayMs == state.intervalMs
                ? step.copyWith(delayMs: interval)
                : step,
          )
          .toList(),
      mimicClickSteps: state.mimicClickSteps
          .map(
            (step) => step.delayMs == state.intervalMs
                ? step.copyWith(delayMs: interval)
                : step,
          )
          .toList(),
      safetyWarning: _nonBlockingSafetyWarning(),
    );
    _queueConfigSync();
  }

  void stepInterval(int delta) {
    final nextValue = (state.intervalMs + delta).clamp(10, 5000);
    state = state.copyWith(
      intervalMs: nextValue,
      speedPreset: _presetFromInterval(nextValue),
      manualClickSteps: state.manualClickSteps
          .map(
            (step) => step.delayMs == state.intervalMs
                ? step.copyWith(delayMs: nextValue)
                : step,
          )
          .toList(),
      mimicClickSteps: state.mimicClickSteps
          .map(
            (step) => step.delayMs == state.intervalMs
                ? step.copyWith(delayMs: nextValue)
                : step,
          )
          .toList(),
      safetyWarning: _nonBlockingSafetyWarning(intervalOverride: nextValue),
    );
    _queueConfigSync();
  }

  void toggleMultiClick(bool enabled) {
    state = state.copyWith(
      isMultiClickEnabled: enabled,
      pointTimingMode: enabled ? state.pointTimingMode : ClickPointTimingMode.sequential,
      safetyWarning: _nonBlockingSafetyWarning(),
    );
    _queueConfigSync();
  }

  void setPointTimingMode(ClickPointTimingMode mode) {
    state = state.copyWith(
      pointTimingMode: mode,
      safetyWarning: _nonBlockingSafetyWarning(),
    );
    _queueConfigSync();
  }

  void setStartDelayMs(int seconds) {
    final normalizedMs = (seconds.clamp(0, 60) as int) * 1000;
    state = state.copyWith(
      startDelayEnabled: normalizedMs > 0,
      startDelayMs: normalizedMs,
    );
    _queueConfigSync();
  }

  void toggleGestureIndicator(bool enabled) {
    state = state.copyWith(showGestureIndicator: enabled);
    _queueConfigSync();
  }

  void setPattern(TapPattern pattern) {
    state = state.copyWith(selectedPattern: pattern);
    _queueConfigSync();
  }

  void setClickMode(ClickMode mode) {
    state = state.copyWith(clickMode: mode);
    _queueConfigSync();
  }

  void setTargetCycles(int value) {
    state = state.copyWith(targetCycles: value.clamp(1, 9999));
    _queueConfigSync();
  }

  Future<void> addClickPoint() {
    return startPointCapture();
  }

  Future<void> editClickPoint(String id) {
    return startPointCapture(editPointId: id);
  }

  void removeClickPoint(String id) {
    final updatedPoints = state.manualClickPoints
        .where((point) => point.id != id)
        .toList();
    final updatedSteps = _sanitizeSteps(
      state.manualClickSteps.where((step) => step.pointId != id).toList(),
      updatedPoints,
      defaultDelayMs: state.intervalMs,
    );

    state = state.copyWith(
      manualClickPoints: updatedPoints,
      manualClickSteps: updatedSteps,
      isMultiClickEnabled: state.activeInputMode == ClickInputMode.manual
          ? (updatedSteps.length > 1 ? state.isMultiClickEnabled : false)
          : state.isMultiClickEnabled,
      pointTimingMode: updatedSteps.length > 1
          ? state.pointTimingMode
          : ClickPointTimingMode.sequential,
      isRunning:
          updatedPoints.isEmpty &&
              state.activeInputMode == ClickInputMode.manual
          ? false
          : state.isRunning,
      statusMessage: updatedPoints.isEmpty
          ? 'Add a click point before starting.'
          : 'Click point removed.',
      safetyWarning: _nonBlockingSafetyWarning(
        manualPointsOverride: updatedPoints,
        manualStepsOverride: updatedSteps,
      ),
    );
    _queueConfigSync();
  }

  void addPatternStep() {
    final activePoints = state.activeClickPoints;
    final activeSteps = state.activeClickSteps;
    if (activePoints.isEmpty) {
      state = state.copyWith(
        statusMessage: state.activeInputMode == ClickInputMode.manual
            ? 'Capture at least one click point before adding steps.'
            : 'Record a mimic pattern before adding extra steps.',
      );
      return;
    }

    final point = activePoints.first;
    final nextIndex = activeSteps.length + 1;
    final updatedSteps = [
      ...activeSteps,
      ClickStep(
        id: 'step-$nextIndex-${DateTime.now().microsecondsSinceEpoch}',
        pointId: point.id,
        label: point.label,
        actionType: ClickStepActionType.tap,
        endPointId: null,
        delayMs: state.intervalMs,
        pressDurationMs: 24,
      ),
    ];

    _replaceActivePattern(
      points: activePoints,
      steps: updatedSteps,
      statusMessage: 'Pattern step added.',
    );
  }

  void removePatternStep(String id) {
    final activePoints = state.activeClickPoints;
    final activeSteps = state.activeClickSteps;
    final updatedSteps = _sanitizeSteps(
      activeSteps.where((step) => step.id != id).toList(),
      activePoints,
      defaultDelayMs: state.intervalMs,
      allowEmpty: true,
    );

    _replaceActivePattern(
      points: activePoints,
      steps: updatedSteps,
      statusMessage: 'Pattern step removed.',
      isMultiClickEnabled: updatedSteps.length > 1
          ? state.isMultiClickEnabled
          : false,
      pointTimingMode: updatedSteps.length > 1
          ? state.pointTimingMode
          : ClickPointTimingMode.sequential,
    );
  }

  void clearActivePattern() {
    final isManual = state.activeInputMode == ClickInputMode.manual;

    state = state.copyWith(
      activeInputMode: ClickInputMode.manual,
      manualClickPoints: isManual ? const [] : state.manualClickPoints,
      manualClickSteps: isManual ? const [] : state.manualClickSteps,
      mimicClickPoints: isManual ? state.mimicClickPoints : const [],
      mimicClickSteps: isManual ? state.mimicClickSteps : const [],
      isMultiClickEnabled: false,
      pointTimingMode: ClickPointTimingMode.sequential,
      statusMessage: isManual
          ? 'Manual targets cleared.'
          : 'Mimic pattern cleared.',
      safetyWarning: _nonBlockingSafetyWarning(
        modeOverride: ClickInputMode.manual,
        manualPointsOverride: isManual ? const [] : state.manualClickPoints,
        manualStepsOverride: isManual ? const [] : state.manualClickSteps,
        mimicPointsOverride: isManual ? state.mimicClickPoints : const [],
        mimicStepsOverride: isManual ? state.mimicClickSteps : const [],
      ),
    );
    _queueConfigSync();
  }

  void updatePatternStepPoint(String stepId, String pointId) {
    final activePoints = state.activeClickPoints;
    final point = activePoints.firstWhere((entry) => entry.id == pointId);
    final updatedSteps = state.activeClickSteps.map((step) {
      if (step.id != stepId) {
        return step;
      }
      final fallbackEndPointId = step.actionType == ClickStepActionType.swipe
          ? (step.endPointId == null || step.endPointId == point.id
                ? _firstAlternativePointId(point.id, activePoints)
                : step.endPointId)
          : null;
      return step.copyWith(
        pointId: point.id,
        label: point.label,
        endPointId: fallbackEndPointId,
      );
    }).toList();

    _replaceActivePattern(points: activePoints, steps: updatedSteps);
  }

  void updatePatternStepActionType(
    String stepId,
    ClickStepActionType actionType,
  ) {
    final activePoints = state.activeClickPoints;
    final updatedSteps = state.activeClickSteps.map((step) {
      if (step.id != stepId) {
        return step;
      }
      return step.copyWith(
        actionType: actionType,
        endPointId: actionType == ClickStepActionType.swipe
            ? (step.endPointId == null || step.endPointId == step.pointId
                  ? _firstAlternativePointId(step.pointId, activePoints)
                  : step.endPointId)
            : null,
      );
    }).toList();

    _replaceActivePattern(points: activePoints, steps: updatedSteps);
  }

  void updatePatternStepEndPoint(String stepId, String pointId) {
    final activePoints = state.activeClickPoints;
    final updatedSteps = state.activeClickSteps.map((step) {
      if (step.id != stepId) {
        return step;
      }
      return step.copyWith(endPointId: pointId);
    }).toList();

    _replaceActivePattern(points: activePoints, steps: updatedSteps);
  }

  void updatePatternStepDelay(String stepId, String value) {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 10) {
      return;
    }

    final activePoints = state.activeClickPoints;
    final updatedSteps = state.activeClickSteps.map((step) {
      if (step.id != stepId) {
        return step;
      }
      return step.copyWith(delayMs: parsed.clamp(10, 5000));
    }).toList();

    _replaceActivePattern(points: activePoints, steps: updatedSteps);
  }

  void updatePatternStepDuration(String stepId, String value) {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 10) {
      return;
    }

    final activePoints = state.activeClickPoints;
    final updatedSteps = state.activeClickSteps.map((step) {
      if (step.id != stepId) {
        return step;
      }
      return step.copyWith(pressDurationMs: parsed.clamp(10, 1200));
    }).toList();

    _replaceActivePattern(points: activePoints, steps: updatedSteps);
  }

  void movePatternStep(String stepId, int direction) {
    final activePoints = state.activeClickPoints;
    final updatedSteps = [...state.activeClickSteps];
    final index = updatedSteps.indexWhere((step) => step.id == stepId);
    if (index == -1) {
      return;
    }

    final nextIndex = index + direction;
    if (nextIndex < 0 || nextIndex >= updatedSteps.length) {
      return;
    }

    final item = updatedSteps.removeAt(index);
    updatedSteps.insert(nextIndex, item);
    _replaceActivePattern(points: activePoints, steps: updatedSteps);
  }

  void importRecordedPattern({
    required List<ClickPoint> clickPoints,
    required List<ClickStep> clickSteps,
  }) {
    if (clickPoints.isEmpty || clickSteps.isEmpty) {
      return;
    }

    final normalizedPattern = _normalizeImportedPattern(
      clickPoints: clickPoints,
      clickSteps: clickSteps,
      existingPointIds: <String>{},
      existingStepIds: <String>{},
    );
    final updatedPoints = normalizedPattern.clickPoints;
    final updatedSteps = _sanitizeSteps(
      normalizedPattern.clickSteps,
      updatedPoints,
      defaultDelayMs: state.intervalMs,
    );

    state = state.copyWith(
      activeInputMode: ClickInputMode.mimic,
      mimicClickPoints: updatedPoints,
      mimicClickSteps: updatedSteps,
      isMultiClickEnabled: updatedSteps.length > 1 || state.isMultiClickEnabled,
      pointTimingMode: updatedSteps.length > 1
          ? state.pointTimingMode
          : ClickPointTimingMode.sequential,
      statusMessage: 'Mimic pattern imported and selected.',
      safetyWarning: _nonBlockingSafetyWarning(
        modeOverride: ClickInputMode.mimic,
        mimicPointsOverride: updatedPoints,
        mimicStepsOverride: updatedSteps,
      ),
    );
    _queueConfigSync();
  }

  void _applyStatus(NativeClickerStatus status) {
    if (status.captureSequence > _lastProcessedCaptureSequence &&
        status.capturedPointX != null &&
        status.capturedPointY != null) {
      _lastProcessedCaptureSequence = status.captureSequence;
      _handleCapturedPoint(
        status.capturedPointX!,
        status.capturedPointY!,
        status.capturedScreenWidth ?? 0,
        status.capturedScreenHeight ?? 0,
      );
    }

    state = state.copyWith(
      accessibilityEnabled: status.accessibilityEnabled,
      overlayPermissionEnabled: status.overlayPermissionEnabled,
      overlayVisible: status.overlayVisible,
      pointPickerActive: status.pointPickerActive,
      accessibilityServiceConnected: status.accessibilityServiceConnected,
      batteryOptimizationIgnored: status.batteryOptimizationIgnored,
      batteryLevelPercent: status.batteryLevelPercent,
      batteryCharging: status.batteryCharging,
      thermalStatus: status.thermalStatus,
      notificationsEnabled: status.notificationsEnabled,
      isRunning: status.isRunning,
      totalClicks: status.totalClicks,
      statusMessage: status.message ?? state.statusMessage,
      safetyWarning: _nonBlockingSafetyWarning(),
    );
  }

  void _queueConfigSync() {
    Future.microtask(_syncConfig);
  }

  Future<void> _syncConfig() {
    return _platformService.updateConfig(
      intervalMs: state.intervalMs,
      startDelayMs: state.startDelayEnabled ? state.startDelayMs : 0,
      pattern: state.selectedPattern,
      multiClick: state.isMultiClickEnabled,
      pointTimingMode: state.pointTimingMode,
      clickMode: state.clickMode,
      targetCycles: state.targetCycles,
      showGestureIndicator: state.showGestureIndicator,
      clickPoints: state.activeClickPoints,
      clickSteps: state.activeClickSteps,
    );
  }

  void _replaceActivePattern({
    required List<ClickPoint> points,
    required List<ClickStep> steps,
    String? statusMessage,
    bool? isMultiClickEnabled,
    ClickPointTimingMode? pointTimingMode,
  }) {
    final nextMultiClickEnabled = isMultiClickEnabled ?? state.isMultiClickEnabled;
    state = state.copyWith(
      manualClickPoints: state.activeInputMode == ClickInputMode.manual
          ? points
          : state.manualClickPoints,
      manualClickSteps: state.activeInputMode == ClickInputMode.manual
          ? steps
          : state.manualClickSteps,
      mimicClickPoints: state.activeInputMode == ClickInputMode.mimic
          ? points
          : state.mimicClickPoints,
      mimicClickSteps: state.activeInputMode == ClickInputMode.mimic
          ? steps
          : state.mimicClickSteps,
      isMultiClickEnabled: nextMultiClickEnabled,
      pointTimingMode:
          pointTimingMode ??
          (steps.length > 1 && nextMultiClickEnabled
              ? state.pointTimingMode
              : ClickPointTimingMode.sequential),
      statusMessage: statusMessage ?? state.statusMessage,
      safetyWarning: _nonBlockingSafetyWarning(
        modeOverride: state.activeInputMode,
        manualPointsOverride: state.activeInputMode == ClickInputMode.manual
            ? points
            : null,
        manualStepsOverride: state.activeInputMode == ClickInputMode.manual
            ? steps
            : null,
        mimicPointsOverride: state.activeInputMode == ClickInputMode.mimic
            ? points
            : null,
        mimicStepsOverride: state.activeInputMode == ClickInputMode.mimic
            ? steps
            : null,
      ),
    );
    _queueConfigSync();
  }

  void _handleCapturedPoint(
    double x,
    double y,
    double screenWidth,
    double screenHeight,
  ) {
    final safeWidth = screenWidth <= 0 ? x * 2 : screenWidth;
    final safeHeight = screenHeight <= 0 ? y * 2 : screenHeight;
    final xPercent = (x / safeWidth).clamp(0.0, 1.0);
    final yPercent = (y / safeHeight).clamp(0.0, 1.0);

    if (_editingPointId != null) {
      final updatedPoints = state.manualClickPoints.map((point) {
        if (point.id != _editingPointId) {
          return point;
        }

        return point.copyWith(
          x: x,
          y: y,
          xPercent: xPercent,
          yPercent: yPercent,
        );
      }).toList();
      final updatedSteps = _syncStepLabelsWithPoints(
        state.manualClickSteps,
        updatedPoints,
      );

      state = state.copyWith(
        manualClickPoints: updatedPoints,
        manualClickSteps: updatedSteps,
        pointPickerActive: false,
        statusMessage:
            'Target updated to ${x.toInt()}, ${y.toInt()} (${(xPercent * 100).toStringAsFixed(0)}% / ${(yPercent * 100).toStringAsFixed(0)}%).',
        safetyWarning: _nonBlockingSafetyWarning(
          manualPointsOverride: updatedPoints,
          manualStepsOverride: updatedSteps,
        ),
      );
      _editingPointId = null;
      _queueConfigSync();
      return;
    }

    final nextIndex = state.manualClickPoints.length + 1;
    final nextPoint = ClickPoint(
      id: _buildPointId(nextIndex, state.manualClickPoints),
      label: state.manualClickPoints.isEmpty
          ? 'Primary Target'
          : 'Point $nextIndex',
      x: x,
      y: y,
      xPercent: xPercent,
      yPercent: yPercent,
    );

    final updatedPoints = [...state.manualClickPoints, nextPoint];
    final updatedSteps = [
      ...state.manualClickSteps,
      ClickStep(
        id: 'step-${state.manualClickSteps.length + 1}-${DateTime.now().microsecondsSinceEpoch}',
        pointId: nextPoint.id,
        label: nextPoint.label,
        actionType: ClickStepActionType.tap,
        endPointId: null,
        delayMs: state.intervalMs,
        pressDurationMs: 24,
      ),
    ];

    state = state.copyWith(
      manualClickPoints: updatedPoints,
      manualClickSteps: updatedSteps,
      pointPickerActive: false,
      statusMessage:
          'Target saved at ${x.toInt()}, ${y.toInt()} (${(xPercent * 100).toStringAsFixed(0)}% / ${(yPercent * 100).toStringAsFixed(0)}%).',
      safetyWarning: _nonBlockingSafetyWarning(
        manualPointsOverride: updatedPoints,
        manualStepsOverride: updatedSteps,
      ),
    );
    _queueConfigSync();
  }

  String? _blockingSafetyIssue() {
    if (!state.accessibilityEnabled) {
      return 'Enable ClickAssist in Accessibility settings before starting.';
    }
    if (state.pointPickerActive) {
      return 'Finish or cancel the point picker before starting.';
    }
    if (state.thermalStatus >= 4) {
      return 'Device temperature is high. Let it cool before starting automation.';
    }
    if (state.batteryLevelPercent >= 0 &&
        state.batteryLevelPercent < 10 &&
        !state.batteryCharging) {
      return 'Battery is very low. Charge the device before starting automation.';
    }
    if (state.activeClickPoints.isEmpty) {
      return state.activeInputMode == ClickInputMode.manual
          ? 'Add at least one click point before starting.'
          : 'Record a mimic pattern before starting.';
    }
    if (state.activeClickSteps.isEmpty) {
      return state.activeInputMode == ClickInputMode.manual
          ? 'Add at least one pattern step before starting.'
          : 'Your mimic pattern needs at least one runnable step.';
    }
    if (state.activeClickSteps.any(
      (step) =>
          step.actionType == ClickStepActionType.swipe &&
          (step.endPointId == null || step.endPointId == step.pointId),
    )) {
      return 'Every swipe step needs a different start and end target.';
    }
    if (state.isMultiClickEnabled && state.activeClickSteps.length < 2) {
      return 'Multi-click mode needs at least two pattern steps.';
    }
    return null;
  }

  String? _nonBlockingSafetyWarning({
    int? intervalOverride,
    ClickInputMode? modeOverride,
    List<ClickPoint>? manualPointsOverride,
    List<ClickStep>? manualStepsOverride,
    List<ClickPoint>? mimicPointsOverride,
    List<ClickStep>? mimicStepsOverride,
  }) {
    final interval = intervalOverride ?? state.intervalMs;
    final mode = modeOverride ?? state.activeInputMode;
    final points = mode == ClickInputMode.manual
        ? (manualPointsOverride ?? state.manualClickPoints)
        : (mimicPointsOverride ?? state.mimicClickPoints);
    final steps = mode == ClickInputMode.manual
        ? (manualStepsOverride ?? state.manualClickSteps)
        : (mimicStepsOverride ?? state.mimicClickSteps);
    final swipeCount = steps
        .where((step) => step.actionType == ClickStepActionType.swipe)
        .length;

    if (state.thermalStatus >= 3) {
      return 'Device temperature is elevated. Pause automation if the phone feels warm.';
    }
    if (state.batteryLevelPercent >= 0 &&
        state.batteryLevelPercent < 20 &&
        !state.batteryCharging) {
      return 'Battery is below 20%. Long automation runs may drain it quickly.';
    }
    if (interval < 20) {
      return 'Intervals below 20 ms can be unstable on some devices.';
    }
    if (swipeCount > 0 && interval < 50) {
      return 'Swipe routes need a little breathing room. Use 50 ms or higher for better device stability.';
    }
    if (!state.batteryOptimizationIgnored) {
      return 'Disable battery optimization for more reliable background runs.';
    }
    if (!state.notificationsEnabled) {
      return 'Enable notifications so native controls remain visible.';
    }
    if (state.isMultiClickEnabled && steps.length < 2) {
      return 'Multi-click mode works best with at least two saved steps.';
    }
    if (state.isMultiClickEnabled &&
        state.pointTimingMode == ClickPointTimingMode.simultaneous &&
        steps.length > 6) {
      return 'Too many simultaneous points may fail or feel inconsistent on some devices.';
    }
    if (state.isMultiClickEnabled &&
        state.pointTimingMode == ClickPointTimingMode.simultaneous &&
        swipeCount > 2) {
      return 'Several simultaneous swipes can be heavy. Sequential mode is safer for swipe-heavy routes.';
    }
    if (steps.any(
      (step) =>
          step.actionType == ClickStepActionType.swipe &&
          (step.endPointId == null || step.endPointId == step.pointId),
    )) {
      return 'Swipe steps work best when start and end targets are both set.';
    }
    if (mode == ClickInputMode.mimic && steps.isEmpty) {
      return 'Record a mimic pattern before switching this run source on.';
    }
    if (points.length > 1 && steps.length == 1) {
      return 'Add more steps to turn saved targets into a real route.';
    }
    return null;
  }

  List<ClickStep> _sanitizeSteps(
    List<ClickStep> steps,
    List<ClickPoint> points, {
    required int defaultDelayMs,
    bool allowEmpty = false,
  }) {
    if (points.isEmpty) {
      return const [];
    }

    final pointById = {for (final point in points) point.id: point};
    final filtered = steps
        .where((step) => pointById.containsKey(step.pointId))
        .map((step) {
          final point = pointById[step.pointId]!;
          return step.copyWith(
            label: point.label,
            endPointId: step.actionType == ClickStepActionType.swipe
                ? _sanitizeEndPoint(step, pointById)
                : null,
            delayMs: step.delayMs.clamp(10, 5000),
            pressDurationMs: step.pressDurationMs.clamp(10, 1200),
          );
        })
        .toList();

    if (filtered.isNotEmpty) {
      return filtered;
    }

    if (allowEmpty) {
      return const [];
    }

    return _defaultStepsFromPoints(points, defaultDelayMs: defaultDelayMs);
  }

  List<ClickStep> _defaultStepsFromPoints(
    List<ClickPoint> points, {
    required int defaultDelayMs,
  }) {
    final takenStepIds = <String>{};
    return List.generate(points.length, (index) {
      final id = _ensureUniqueId(
        preferredId: 'step-${index + 1}',
        takenIds: takenStepIds,
        fallbackPrefix: 'step',
      );
      takenStepIds.add(id);
      return ClickStep(
        id: id,
        pointId: points[index].id,
        label: points[index].label,
        actionType: ClickStepActionType.tap,
        endPointId: null,
        delayMs: defaultDelayMs,
        pressDurationMs: 24,
      );
    });
  }

  List<ClickStep> _syncStepLabelsWithPoints(
    List<ClickStep> steps,
    List<ClickPoint> points,
  ) {
    final pointById = {for (final point in points) point.id: point};
    return steps.map((step) {
      final point = pointById[step.pointId];
      return point == null
          ? step
          : step.copyWith(
              label: point.label,
              endPointId: step.actionType == ClickStepActionType.swipe
                  ? _sanitizeEndPoint(step, pointById)
                  : null,
            );
    }).toList();
  }

  String? _sanitizeEndPoint(ClickStep step, Map<String, ClickPoint> pointById) {
    final current = step.endPointId;
    if (current != null &&
        current != step.pointId &&
        pointById.containsKey(current)) {
      return current;
    }
    return _firstAlternativePointId(
      step.pointId,
      pointById.values.toList(growable: false),
    );
  }

  String? _firstAlternativePointId(
    String excludedPointId,
    List<ClickPoint> points,
  ) {
    for (final point in points) {
      if (point.id != excludedPointId) {
        return point.id;
      }
    }
    return null;
  }

  _NormalizedPattern _normalizeImportedPattern({
    required List<ClickPoint> clickPoints,
    required List<ClickStep> clickSteps,
    required Set<String> existingPointIds,
    required Set<String> existingStepIds,
  }) {
    final pointIdMap = <String, String>{};
    final normalizedPoints = <ClickPoint>[];

    for (final point in clickPoints) {
      final nextId = _ensureUniqueId(
        preferredId: point.id,
        takenIds: existingPointIds,
        fallbackPrefix: 'point',
      );
      existingPointIds.add(nextId);
      pointIdMap[point.id] = nextId;
      normalizedPoints.add(point.copyWith(id: nextId));
    }

    final normalizedSteps = <ClickStep>[];
    for (final step in clickSteps) {
      final nextPointId = pointIdMap[step.pointId];
      if (nextPointId == null) {
        continue;
      }
      final nextId = _ensureUniqueId(
        preferredId: step.id,
        takenIds: existingStepIds,
        fallbackPrefix: 'step',
      );
      existingStepIds.add(nextId);
      normalizedSteps.add(
        step.copyWith(
          id: nextId,
          pointId: nextPointId,
          endPointId: step.endPointId == null
              ? null
              : pointIdMap[step.endPointId!],
        ),
      );
    }

    return _NormalizedPattern(
      clickPoints: normalizedPoints,
      clickSteps: normalizedSteps,
    );
  }

  String _buildPointId(int nextIndex, List<ClickPoint> points) {
    return _ensureUniqueId(
      preferredId: 'point-$nextIndex',
      takenIds: points.map((point) => point.id).toSet(),
      fallbackPrefix: 'point',
    );
  }

  String _ensureUniqueId({
    required String preferredId,
    required Set<String> takenIds,
    required String fallbackPrefix,
  }) {
    if (!takenIds.contains(preferredId)) {
      return preferredId;
    }

    var attempt = 1;
    while (true) {
      final candidate =
          '$fallbackPrefix-${DateTime.now().microsecondsSinceEpoch}-$attempt';
      if (!takenIds.contains(candidate)) {
        return candidate;
      }
      attempt += 1;
    }
  }

  List<ClickStep> _stepsForMode(
    ClickInputMode mode, [
    List<ClickStep>? manualSteps,
    List<ClickStep>? mimicSteps,
  ]) {
    return mode == ClickInputMode.manual
        ? (manualSteps ?? state.manualClickSteps)
        : (mimicSteps ?? state.mimicClickSteps);
  }

  SpeedPreset _presetFromInterval(int intervalMs) {
    for (final preset in SpeedPreset.values) {
      if (preset.intervalMs == intervalMs) {
        return preset;
      }
    }
    return SpeedPreset.custom;
  }
}

class _NormalizedPattern {
  const _NormalizedPattern({
    required this.clickPoints,
    required this.clickSteps,
  });

  final List<ClickPoint> clickPoints;
  final List<ClickStep> clickSteps;
}
