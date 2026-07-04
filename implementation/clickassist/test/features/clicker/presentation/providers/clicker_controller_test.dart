import 'dart:async';

import 'package:clickassist/core/services/click_assist_platform_service.dart';
import 'package:clickassist/features/clicker/data/services/clicker_preset_storage.dart';
import 'package:clickassist/features/clicker/domain/entities/click_mode.dart';
import 'package:clickassist/features/clicker/domain/entities/click_input_mode.dart';
import 'package:clickassist/features/clicker/domain/entities/click_point.dart';
import 'package:clickassist/features/clicker/domain/entities/click_point_timing_mode.dart';
import 'package:clickassist/features/clicker/domain/entities/click_step.dart';
import 'package:clickassist/features/clicker/domain/entities/clicker_preset.dart';
import 'package:clickassist/features/clicker/domain/entities/tap_pattern.dart';
import 'package:clickassist/features/clicker/presentation/providers/clicker_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'refreshStatus applies overlay enabled state from native status',
    () async {
      final platformService = _FakeClickAssistPlatformService(
        status: _nativeStatus(overlayEnabled: true, overlayVisible: true),
      );
      final container = ProviderContainer(
        overrides: [
          clickAssistPlatformServiceProvider.overrideWithValue(platformService),
          clickerPresetStorageProvider.overrideWithValue(
            const _FakeClickerPresetStorage(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(clickerControllerProvider.notifier).refreshStatus();

      final state = container.read(clickerControllerProvider);
      expect(state.overlayEnabled, isTrue);
      expect(state.overlayVisible, isTrue);
    },
  );

  test(
    'starting clicker enables floating overlay controls when overlay permission is available',
    () async {
      final platformService = _FakeClickAssistPlatformService(
        status: _nativeStatus(
          accessibilityEnabled: true,
          overlayPermissionEnabled: true,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          clickAssistPlatformServiceProvider.overrideWithValue(platformService),
          clickerPresetStorageProvider.overrideWithValue(
            const _FakeClickerPresetStorage(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(clickerControllerProvider.notifier);
      await controller.refreshStatus();
      controller.importRecordedPattern(
        clickPoints: const [
          ClickPoint(
            id: 'point-1',
            label: 'Primary target',
            x: 320,
            y: 640,
            xPercent: 0.5,
            yPercent: 0.5,
          ),
        ],
        clickSteps: const [
          ClickStep(
            id: 'step-1',
            pointId: 'point-1',
            label: 'Primary target',
            actionType: ClickStepActionType.tap,
            endPointId: null,
            delayMs: 500,
            pressDurationMs: 24,
          ),
        ],
      );

      await controller.toggleRunning();

      expect(platformService.startOverlayCalls, 1);
      expect(platformService.startClickingCalls, 1);
    },
  );

  test(
    'starting clicker is blocked when overlay permission is missing',
    () async {
      final platformService = _FakeClickAssistPlatformService(
        status: _nativeStatus(
          accessibilityEnabled: true,
          overlayPermissionEnabled: false,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          clickAssistPlatformServiceProvider.overrideWithValue(platformService),
          clickerPresetStorageProvider.overrideWithValue(
            const _FakeClickerPresetStorage(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(clickerControllerProvider.notifier);
      await controller.refreshStatus();
      controller.importRecordedPattern(
        clickPoints: const [
          ClickPoint(
            id: 'point-1',
            label: 'Primary target',
            x: 320,
            y: 640,
            xPercent: 0.5,
            yPercent: 0.5,
          ),
        ],
        clickSteps: const [
          ClickStep(
            id: 'step-1',
            pointId: 'point-1',
            label: 'Primary target',
            actionType: ClickStepActionType.tap,
            endPointId: null,
            delayMs: 500,
            pressDurationMs: 24,
          ),
        ],
      );

      await controller.toggleRunning();

      final state = container.read(clickerControllerProvider);
      expect(platformService.startOverlayCalls, 0);
      expect(platformService.startClickingCalls, 0);
      expect(state.statusMessage, contains('Allow display over other apps'));
    },
  );
}

NativeClickerStatus _nativeStatus({
  bool accessibilityEnabled = false,
  bool overlayPermissionEnabled = false,
  bool overlayEnabled = false,
  bool overlayVisible = false,
  bool isRunning = false,
}) {
  return NativeClickerStatus(
    accessibilityEnabled: accessibilityEnabled,
    overlayPermissionEnabled: overlayPermissionEnabled,
    overlayEnabled: overlayEnabled,
    overlayVisible: overlayVisible,
    pointPickerActive: false,
    accessibilityServiceConnected: accessibilityEnabled,
    batteryOptimizationIgnored: true,
    batteryLevelPercent: 80,
    batteryCharging: false,
    thermalStatus: 0,
    notificationsEnabled: true,
    isRunning: isRunning,
    totalClicks: 0,
    captureSequence: 0,
    message: 'Native status loaded',
  );
}

class _FakeClickAssistPlatformService extends ClickAssistPlatformService {
  _FakeClickAssistPlatformService({required this.status});

  NativeClickerStatus status;
  int startOverlayCalls = 0;
  int startClickingCalls = 0;

  @override
  Stream<NativeClickerStatus> statusStream() {
    return const Stream<NativeClickerStatus>.empty();
  }

  @override
  Future<NativeClickerStatus> getStatus() async {
    return status;
  }

  @override
  Future<void> updateConfig({
    required int intervalMs,
    required int startDelayMs,
    required TapPattern pattern,
    required bool multiClick,
    required ClickPointTimingMode pointTimingMode,
    required ClickInputMode inputMode,
    required ClickMode clickMode,
    required int targetCycles,
    required bool showGestureIndicator,
    required List<ClickPoint> clickPoints,
    required List<ClickStep> clickSteps,
  }) async {}

  @override
  Future<NativeClickerStatus> startOverlay() async {
    startOverlayCalls += 1;
    status = _nativeStatus(
      accessibilityEnabled: status.accessibilityEnabled,
      overlayPermissionEnabled: status.overlayPermissionEnabled,
      overlayEnabled: true,
      overlayVisible: true,
      isRunning: status.isRunning,
    );
    return status;
  }

  @override
  Future<NativeClickerStatus> startClicking({
    required int intervalMs,
    required int startDelayMs,
    required TapPattern pattern,
    required bool multiClick,
    required ClickPointTimingMode pointTimingMode,
    required ClickInputMode inputMode,
    required ClickMode clickMode,
    required int targetCycles,
    required bool showGestureIndicator,
    required List<ClickPoint> clickPoints,
    required List<ClickStep> clickSteps,
  }) async {
    startClickingCalls += 1;
    status = _nativeStatus(
      accessibilityEnabled: status.accessibilityEnabled,
      overlayPermissionEnabled: status.overlayPermissionEnabled,
      overlayEnabled: status.overlayEnabled,
      overlayVisible: status.overlayVisible,
      isRunning: true,
    );
    return status;
  }
}

class _FakeClickerPresetStorage extends ClickerPresetStorage {
  const _FakeClickerPresetStorage();

  @override
  Future<List<ClickerPreset>> loadPresets() async {
    return const [];
  }
}
