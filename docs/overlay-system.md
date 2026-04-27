# Overlay System

ClickAssist uses Android overlay windows for two user-facing features: floating controls and point capture.

## Floating Overlay

The floating overlay lets users start, pause, stop, and return to settings from outside the app.

Behavior rules:

- Requires overlay permission.
- Requires AccessibilityService for automation controls.
- Uses a foreground service while active.
- Shows a visible notification while the service runs.
- Hides while the main app is in the foreground.
- Stops when overlay is disabled or permissions are revoked.

## Point Picker Overlay

The point picker captures a tap coordinate from the real screen so users can create manual click points.

Behavior rules:

- Requires overlay permission.
- Starts only after a user action.
- Saves the captured point and exits the picker.
- Can be cancelled from the app.

## Native Files

- `FloatingOverlayService.kt`
- `PointPickerOverlayService.kt`
- `OverlayActionReceiver.kt`
- `GestureIndicatorOverlay.kt`
- `ClickAssistBridge.kt`

## Safety Notes

The overlay should remain small, predictable, and easy to dismiss. It should not obscure critical app controls or remain visible after the user disables overlay support.
