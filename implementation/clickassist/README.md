# ClickAssist Flutter Implementation

This directory contains the runnable Flutter Android implementation for ClickAssist.

Current version: 1.0.1

## Run Locally

```bash
flutter pub get
flutter run
```

## Build Android Debug APK

```bash
flutter build apk --debug
```

The generated debug APK is written to:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Main Source Areas

- `lib/app/`: app shell, routing, theme, typography, colors, and spacing tokens.
- `lib/core/`: platform service bridge, local preferences, and support configuration.
- `lib/features/clicker/`: active clicker domain, state, pages, widgets, presets, setup guide, and dashboard.
- `lib/widgets/`: shared brand/logo and UI widgets.
- `android/app/src/main/kotlin/app/clickassist/android/`: native Android accessibility, overlay, notification, and platform-channel integration.
- `assets/branding/`: runtime Flutter logo and app icon assets.
- `test/`: widget, controller, branding, theme, and quality-guard tests.

For complete project documentation, see `../../docs/analysis/README.md`.
