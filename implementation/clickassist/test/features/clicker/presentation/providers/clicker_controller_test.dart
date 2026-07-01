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
}

NativeClickerStatus _nativeStatus({
  bool accessibilityEnabled = false,
  bool overlayPermissionEnabled = false,
  bool overlayEnabled = false,
  bool overlayVisible = false,
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
    isRunning: false,
    totalClicks: 0,
    captureSequence: 0,
    message: 'Native status loaded',
  );
}

class _FakeClickAssistPlatformService extends ClickAssistPlatformService {
  _FakeClickAssistPlatformService({required this.status});

  NativeClickerStatus status;

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
}

class _FakeClickerPresetStorage extends ClickerPresetStorage {
  const _FakeClickerPresetStorage();

  @override
  Future<List<ClickerPreset>> loadPresets() async {
    return const [];
  }
}
