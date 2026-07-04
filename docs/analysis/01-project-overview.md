# 01. Project Overview

ClickAssist is a Flutter Android app for user-controlled tap and gesture automation. The app lets a user configure click points, timing, gesture behavior, presets, and then run the automation through an Android accessibility service.

Current release metadata in the app is `1.0.1+2`, with `1.0.1` shown to users in Settings/About surfaces.

The project currently focuses on Android. Flutter provides the app UI and state-driven setup/configuration experience. Native Kotlin code handles Android-specific behavior that Flutter cannot perform directly, including accessibility gestures and the floating overlay shown above other apps.

## Purpose

The main purpose of ClickAssist is to make repetitive tapping workflows easier while keeping the user in control. It provides:

- configurable tap points and click timing
- single-target, sequential, and simultaneous click behavior
- saved presets for repeatable configurations
- an overlay that remains available while the clicker is running
- guided permission setup for Android system permissions

The app is intended for users who need local, manual automation on their own device. It is not documented as a remote automation, analytics, account, or cloud-sync product.

## Why accessibility permission is required

Android does not allow ordinary apps to inject touch gestures into other apps. ClickAssist uses an `AccessibilityService` so it can dispatch gestures with Android's accessibility APIs after the user explicitly enables the service in Android settings.

The permission is central to the product:

- without the accessibility service, the app can display configuration UI but cannot perform auto-click gestures
- the setup guide exists to help the user enable the required service
- the running clicker depends on native Android service lifecycle and overlay behavior

## Current project status

ClickAssist is an active Flutter/Android codebase with current work focused on:

- app-wide branding and logo consistency
- centralized theme and typography
- a cleaner dashboard and setup flow
- more reliable overlay controls
- native overlay protection so generated taps do not accidentally press the overlay itself
- improved pick-on-screen target selection
- Settings/About metadata prepared for version `1.0.1`
- documentation cleanup for open-source readability

The repository includes production code, widget tests, theme/typography guard tests, and native Kotlin logic tests. Current screenshots still need to be regenerated from the latest app UI.

## Branding and logo assets

The current brand direction is based on a dark navy interface, bright cyan accent color, and a play-button logo mark. Existing brand assets are:

- `design/clickassist-app-icon.svg`
- `design/clickassist-app-icon.png`
- `implementation/clickassist/assets/branding/clickassist-app-icon.png`
- `implementation/clickassist/assets/branding/clickassist-adaptive-foreground.png`
- `implementation/clickassist/android/app/src/main/res/drawable/clickassist_overlay_logo.png`
- `implementation/clickassist/android/app/src/main/res/drawable-nodpi/ic_launcher_full.png`

The logo appears in project documentation, Flutter branding assets, Android app icon resources, splash/launcher-related resources, and the overlay logo resource. Runtime overlay controls use dedicated play/pause/close controls instead of using the full app logo as the start/stop control.
