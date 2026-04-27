# Accessibility Service

ClickAssist uses Android AccessibilityService to dispatch user-configured taps and swipes.

## Purpose

The service powers the core automation feature. It simulates only the gestures configured by the user inside ClickAssist.

## User Control

- The service is not enabled automatically.
- The app shows a disclosure before opening Android Accessibility settings.
- Automation is user-initiated from the app, overlay, or native controls.
- Stopping automation remains visible and available while running.

## What the Service Does

- Receives the latest clicker configuration from the native bridge.
- Resolves saved points against the current screen size.
- Dispatches tap and swipe gestures with Android gesture APIs.
- Updates counters only after Android reports a gesture completed.
- Stops when target cycle count is reached or the user stops automation.

## What the Service Does Not Do

Based on the current codebase:

- It does not read screen text.
- It does not upload user data.
- It does not include analytics or cloud sync.
- It does not start automation without a user action.

## Review Notes

AccessibilityService use is sensitive for app-store review. Store listing text, screenshots, onboarding, and policy declarations should describe the automation purpose clearly and avoid claiming disability assistance unless that is the actual product purpose.
