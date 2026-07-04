# Architecture

ClickAssist uses a hybrid Flutter and native Android architecture. Flutter owns the user experience, configuration, presets, safety copy, and state. Native Android owns gesture dispatch, overlay windows, foreground services, notifications, and device-health status.

## Layers

```text
Flutter UI
  ↓ Riverpod state/controller
Platform service
  ↓ MethodChannel / EventChannel
Android bridge
  ↓ AccessibilityService / Overlay services
Android system gesture dispatch
```

## Flutter Layer

Primary location: `implementation/clickassist/lib/`

- `app/` contains app shell, routing, and theme.
- `core/` contains platform services, config, and shared support logic.
- `features/clicker/` contains clicker domain entities, storage services, state, controller, pages, and widgets.

The main state container is `ClickerController`, exposed through Riverpod. It validates user configuration, synchronizes active run settings to native Android, and receives live status events from Android.

## Native Android Layer

Primary location: `implementation/clickassist/android/app/src/main/kotlin/com/example/clickassist/`

- `AutoClickAccessibilityService.kt` dispatches configured taps and swipes.
- `FloatingOverlayService.kt` manages global overlay controls.
- `PointPickerOverlayService.kt` captures manual targets.
- `GestureIndicatorOverlay.kt` renders tap and swipe feedback.
- `ClickAssistBridge.kt` coordinates native state and reports status to Flutter.
- `MainActivity.kt` exposes MethodChannel and EventChannel bindings.

## Data Flow

1. User configures a run in Flutter.
2. Flutter validates the active input mode and safety conditions.
3. Flutter sends config to Android through MethodChannel.
4. Android stores the latest config and dispatches gestures through AccessibilityService.
5. Android reports running state, counters, permissions, battery, and thermal status through EventChannel.
6. Flutter updates the UI and health checks from native status.

## Storage

ClickAssist stores presets and onboarding state locally. The current codebase does not include cloud sync, accounts, analytics, or crash reporting.
