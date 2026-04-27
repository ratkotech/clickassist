import 'dart:async';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/clicker/domain/entities/click_mode.dart';
import '../../features/clicker/domain/entities/click_point.dart';
import '../../features/clicker/domain/entities/click_point_timing_mode.dart';
import '../../features/clicker/domain/entities/click_step.dart';
import '../../features/clicker/domain/entities/tap_pattern.dart';

final clickAssistPlatformServiceProvider = Provider<ClickAssistPlatformService>(
  (ref) {
    return const ClickAssistPlatformService();
  },
);

class NativeClickerStatus {
  const NativeClickerStatus({
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
    required this.isRunning,
    required this.totalClicks,
    required this.captureSequence,
    this.capturedPointX,
    this.capturedPointY,
    this.capturedScreenWidth,
    this.capturedScreenHeight,
    this.message,
  });

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
  final bool isRunning;
  final int totalClicks;
  final int captureSequence;
  final double? capturedPointX;
  final double? capturedPointY;
  final double? capturedScreenWidth;
  final double? capturedScreenHeight;
  final String? message;

  factory NativeClickerStatus.fromMap(Map<Object?, Object?> map) {
    return NativeClickerStatus(
      accessibilityEnabled: map['accessibilityEnabled'] as bool? ?? false,
      overlayPermissionEnabled:
          map['overlayPermissionEnabled'] as bool? ?? false,
      overlayEnabled: map['overlayEnabled'] as bool? ?? false,
      overlayVisible: map['overlayVisible'] as bool? ?? false,
      pointPickerActive: map['pointPickerActive'] as bool? ?? false,
      accessibilityServiceConnected:
          map['accessibilityServiceConnected'] as bool? ?? false,
      batteryOptimizationIgnored:
          map['batteryOptimizationIgnored'] as bool? ?? false,
      batteryLevelPercent: map['batteryLevelPercent'] as int? ?? -1,
      batteryCharging: map['batteryCharging'] as bool? ?? false,
      thermalStatus: map['thermalStatus'] as int? ?? 0,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      isRunning: map['isRunning'] as bool? ?? false,
      totalClicks: map['totalClicks'] as int? ?? 0,
      captureSequence: map['captureSequence'] as int? ?? 0,
      capturedPointX: (map['capturedPointX'] as num?)?.toDouble(),
      capturedPointY: (map['capturedPointY'] as num?)?.toDouble(),
      capturedScreenWidth: (map['capturedScreenWidth'] as num?)?.toDouble(),
      capturedScreenHeight: (map['capturedScreenHeight'] as num?)?.toDouble(),
      message: map['message'] as String?,
    );
  }
}

class ClickAssistPlatformService {
  const ClickAssistPlatformService();

  static const MethodChannel _methodChannel = MethodChannel(
    'clickassist/autoclicker',
  );
  static const EventChannel _eventChannel = EventChannel(
    'clickassist/autoclicker_status',
  );

  Stream<NativeClickerStatus> statusStream() {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return NativeClickerStatus.fromMap(
        Map<Object?, Object?>.from(event as Map<dynamic, dynamic>),
      );
    });
  }

  Future<NativeClickerStatus> getStatus() async {
    final response = await _methodChannel.invokeMapMethod<Object?, Object?>(
      'getStatus',
    );
    return NativeClickerStatus.fromMap(response ?? const {});
  }

  Future<void> openAccessibilitySettings() {
    return _methodChannel.invokeMethod<void>('openAccessibilitySettings');
  }

  Future<void> openOverlaySettings() {
    return _methodChannel.invokeMethod<void>('openOverlaySettings');
  }

  Future<void> openBatteryOptimizationSettings() {
    return _methodChannel.invokeMethod<void>('openBatteryOptimizationSettings');
  }

  Future<void> openNotificationSettings() {
    return _methodChannel.invokeMethod<void>('openNotificationSettings');
  }

  Future<void> openExternalUrl(String url) {
    return _methodChannel.invokeMethod<void>('openExternalUrl', {'url': url});
  }

  Future<bool> composeSupportEmail({
    required String email,
    required String subject,
    required String body,
  }) {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> updateConfig({
    required int intervalMs,
    required int startDelayMs,
    required TapPattern pattern,
    required bool multiClick,
    required ClickPointTimingMode pointTimingMode,
    required ClickMode clickMode,
    required int targetCycles,
    required bool showGestureIndicator,
    required List<ClickPoint> clickPoints,
    required List<ClickStep> clickSteps,
  }) {
    return _methodChannel.invokeMethod<void>('updateConfig', {
      'intervalMs': intervalMs,
      'startDelayMs': startDelayMs,
      'pattern': pattern.value,
      'multiClick': multiClick,
      'pointTimingMode': pointTimingMode.value,
      'infiniteMode': clickMode == ClickMode.infinite,
      'targetCycles': targetCycles,
      'showGestureIndicator': showGestureIndicator,
      'clickPoints': clickPoints
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
          .toList(),
      'clickSteps': clickSteps
          .map(
            (step) => {
              'id': step.id,
              'pointId': step.pointId,
              'actionType': step.actionType.name,
              'endPointId': step.endPointId,
              'delayMs': step.delayMs,
              'pressDurationMs': step.pressDurationMs,
            },
          )
          .toList(),
    });
  }

  Future<NativeClickerStatus> startPointPicker() async {
    final response = await _methodChannel.invokeMapMethod<Object?, Object?>(
      'startPointPicker',
    );
    return NativeClickerStatus.fromMap(response ?? const {});
  }

  Future<NativeClickerStatus> stopPointPicker() async {
    final response = await _methodChannel.invokeMapMethod<Object?, Object?>(
      'stopPointPicker',
    );
    return NativeClickerStatus.fromMap(response ?? const {});
  }

  Future<NativeClickerStatus> startClicking({
    required int intervalMs,
    required int startDelayMs,
    required TapPattern pattern,
    required bool multiClick,
    required ClickPointTimingMode pointTimingMode,
    required ClickMode clickMode,
    required int targetCycles,
    required bool showGestureIndicator,
    required List<ClickPoint> clickPoints,
    required List<ClickStep> clickSteps,
  }) async {
    final response = await _methodChannel.invokeMapMethod<Object?, Object?>(
      'startClicking',
      {
        'intervalMs': intervalMs,
        'startDelayMs': startDelayMs,
        'pattern': pattern.value,
        'multiClick': multiClick,
        'pointTimingMode': pointTimingMode.value,
        'infiniteMode': clickMode == ClickMode.infinite,
        'targetCycles': targetCycles,
        'showGestureIndicator': showGestureIndicator,
        'clickPoints': clickPoints
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
            .toList(),
        'clickSteps': clickSteps
            .map(
              (step) => {
                'id': step.id,
                'pointId': step.pointId,
                'actionType': step.actionType.name,
                'endPointId': step.endPointId,
                'delayMs': step.delayMs,
                'pressDurationMs': step.pressDurationMs,
              },
            )
            .toList(),
      },
    );

    return NativeClickerStatus.fromMap(response ?? const {});
  }

  Future<NativeClickerStatus> stopClicking() async {
    final response = await _methodChannel.invokeMapMethod<Object?, Object?>(
      'stopClicking',
    );
    return NativeClickerStatus.fromMap(response ?? const {});
  }

  Future<NativeClickerStatus> startOverlay() async {
    final response = await _methodChannel.invokeMapMethod<Object?, Object?>(
      'startOverlay',
    );
    return NativeClickerStatus.fromMap(response ?? const {});
  }

  Future<NativeClickerStatus> stopOverlay() async {
    final response = await _methodChannel.invokeMapMethod<Object?, Object?>(
      'stopOverlay',
    );
    return NativeClickerStatus.fromMap(response ?? const {});
  }
}
