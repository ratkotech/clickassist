import 'dart:async';

import 'package:clickassist/core/config/app_support_config.dart';
import 'package:clickassist/core/services/click_assist_platform_service.dart';
import 'package:clickassist/features/clicker/data/services/clicker_preset_storage.dart';
import 'package:clickassist/features/clicker/domain/entities/click_input_mode.dart';
import 'package:clickassist/features/clicker/domain/entities/click_mode.dart';
import 'package:clickassist/features/clicker/domain/entities/click_point.dart';
import 'package:clickassist/features/clicker/domain/entities/click_point_timing_mode.dart';
import 'package:clickassist/features/clicker/domain/entities/click_step.dart';
import 'package:clickassist/features/clicker/domain/entities/clicker_preset.dart';
import 'package:clickassist/features/clicker/domain/entities/tap_pattern.dart';
import 'package:clickassist/features/clicker/presentation/pages/settings_legal_page.dart';
import 'package:clickassist/features/clicker/presentation/widgets/settings_action_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('settings legal app info uses bounded branding without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clickerPresetStorageProvider.overrideWithValue(_FakePresetStorage()),
          clickAssistPlatformServiceProvider.overrideWithValue(
            _FakePlatformService(),
          ),
        ],
        child: const MaterialApp(home: SettingsLegalPage()),
      ),
    );

    expect(find.text('Settings & Legal'), findsWidgets);
    expect(find.text('ABOUT CLICKASSIST'), findsOneWidget);
    expect(find.text('Version 1.0.1'), findsOneWidget);
    expect(
      find.text(
        'ClickAssist is an Android auto clicker app built with Flutter, using accessibility-based automation and floating overlay controls.',
      ),
      findsOneWidget,
    );
    expect(find.text('Open-source project'), findsOneWidget);
    expect(find.text('RatkoTech'), findsOneWidget);
    expect(find.byKey(const Key('brand-logo-full')), findsNothing);
    expect(find.byKey(const Key('brand-logo-mark')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings action tile stacks actions on narrow surfaces', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: SettingsActionTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                description:
                    'Open the full privacy policy URL configured for this app.',
                label: 'Open',
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final buttonSize = tester.getSize(
      find.widgetWithText(FilledButton, 'Open'),
    );

    expect(buttonSize.width, greaterThan(260));
    expect(tester.takeException(), isNull);
  });

  test('app support config exposes the 1.0.1 release metadata', () {
    expect(AppSupportConfig.appVersion, '1.0.1');
    expect(AppSupportConfig.appBuildNumber, '2');
    expect(AppSupportConfig.appFullVersion, '1.0.1+2');
    expect(
      AppSupportConfig.aboutDescription,
      'ClickAssist is an Android auto clicker app built with Flutter, using accessibility-based automation and floating overlay controls.',
    );
    expect(AppSupportConfig.projectStatus, 'Open-source project');
    expect(AppSupportConfig.developerName, 'RatkoTech');
  });
}

class _FakePresetStorage extends ClickerPresetStorage {
  @override
  Future<List<ClickerPreset>> loadPresets() async => const [];

  @override
  Future<void> savePreset(ClickerPreset preset) async {}

  @override
  Future<void> deletePreset(String id) async {}

  @override
  Future<void> clearPresets() async {}
}

class _FakePlatformService extends ClickAssistPlatformService {
  static const _status = NativeClickerStatus(
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
    isRunning: false,
    totalClicks: 0,
    captureSequence: 0,
  );

  @override
  Stream<NativeClickerStatus> statusStream() => const Stream.empty();

  @override
  Future<NativeClickerStatus> getStatus() async => _status;

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
