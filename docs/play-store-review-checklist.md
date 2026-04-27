# Play Store Review Checklist

This checklist summarizes known review-sensitive areas in the current open-source codebase.

## Data Stored Locally

- Saved presets
- Click points and mimic pattern steps
- Onboarding completion state
- Runtime preferences and visual feedback preferences

## Data Leaving the Device

No analytics SDK, crash-reporting SDK, account system, cloud sync, or network upload client is included in the current reviewed source code.

Unknown: future dependencies, release-only SDKs, or external services must be reviewed before publishing.

## Permissions Declared

- `SYSTEM_ALERT_WINDOW` for floating controls and point picker overlays.
- `FOREGROUND_SERVICE` for foreground overlay service behavior.
- `FOREGROUND_SERVICE_SPECIAL_USE` for overlay foreground service type on modern Android.
- `POST_NOTIFICATIONS` for foreground status and quick controls.
- `BIND_ACCESSIBILITY_SERVICE` for the Android AccessibilityService.

## Foreground Services

`FloatingOverlayService` runs as a foreground service and displays a visible notification while active.

## AccessibilityService

`AutoClickAccessibilityService` dispatches configured taps and swipes. This remains the highest policy-risk area and needs clear store listing text, screenshots, onboarding, and permission disclosures.

## Data Safety Notes

Likely declarations if the codebase remains unchanged:

- Data collected: none found in source.
- Data shared: none found in source.
- Local-only data: presets, click points, pattern steps, onboarding state, settings.
- Sensitive permissions: AccessibilityService, overlay, notifications, foreground service.

## Before Publishing

- Verify privacy policy URL is public.
- Verify responsible-use URL is public.
- Review final dependencies for analytics, crash reporting, or networking.
- Confirm Play Console Data Safety matches the shipped build exactly.
- Do not promise Play Store approval.
