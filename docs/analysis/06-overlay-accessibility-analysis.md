# 06. Overlay and Accessibility Analysis

ClickAssist depends on Android native code for the parts of the product that must operate outside the Flutter view: accessibility gestures, floating overlay controls, point picking, and gesture indicators.

For the `1.0.1` release, the documented native runtime focus is overlay safety and clearer point picking.

## Accessibility service

`AutoClickAccessibilityService.kt` is the native service responsible for dispatching gestures through Android accessibility APIs. The service receives clicker configuration from the Flutter/native bridge and performs the configured tap or gesture sequence while the user keeps control through the overlay.

Accessibility permission is required because Android restricts synthetic touch dispatch to accessibility services and system-level APIs.

## Flutter to native communication

The Flutter app owns the primary configuration UI and clicker state. Native Android code performs OS-level work through the bridge layer. Important files include:

- `ClickAssistBridge.kt`
- `AutoClickAccessibilityService.kt`
- `FloatingOverlayService.kt`
- `PointPickerOverlayService.kt`

The Flutter side starts or updates the clicker through the native bridge. The native layer then coordinates the accessibility service and overlay.

## Floating overlay controls

`FloatingOverlayService.kt` creates and manages the runtime overlay shown above other apps. The overlay provides controls for the running clicker and must remain manually touchable.

Current behavior includes:

- visible runtime status
- play/pause-style runtime control
- stop/close control
- settings/tooling control where available
- draggable overlay behavior where supported
- compact/expanded overlay behavior
- tracking of overlay bounds on screen

## Point picker overlay

`PointPickerOverlayService.kt` manages the native pick-on-screen target selection overlay. This is separate from the runtime control overlay and is used when the user wants to capture a screen coordinate from another app or the Android home screen.

Current picker behavior includes:

- full-screen transparent capture surface
- top instruction card with the current task
- draggable bullseye/crosshair marker for the exact tap point
- live coordinate feedback in both the marker label and bottom action bar
- Cancel action that closes the picker without saving
- Confirm action that records the selected point through `ClickAssistBridge.recordCapturedPoint`
- coordinate clamping so the saved target remains inside the visible screen bounds

The Flutter click-point list shows a short active-picker state while the native overlay handles detailed placement. Confirmed targets are then shown by `click_point_tile.dart` with saved coordinates, relative percentages, edit/delete actions, and semantic labels.

## Overlay safe-zone protection

The repository includes `OverlayProtection.kt`, a pure Kotlin helper for overlay hit-zone logic. It is used to prevent auto-generated taps from accidentally pressing the overlay controls.

Current protection behavior:

- track the current overlay bounds on screen
- expand those bounds with a safe margin
- check each planned tap coordinate before dispatching the gesture
- if the target is outside the protected zone, dispatch normally
- if the target intersects the overlay protected zone, try to move the overlay to a safe position
- if relocation cannot make the target safe, skip that tap and log/status the protected skip

The overlay remains manually touchable. The implementation does not make the overlay permanently `FLAG_NOT_TOUCHABLE`, because the user must still be able to pause, stop, close, or drag the overlay.

## Missing controls root cause and fix

The blue tap indicator and the floating control overlay are separate native views:

- `GestureIndicatorOverlay` renders temporary tap/swipe indicators through the accessibility service.
- `FloatingOverlayService` renders the persistent pause/stop/open controls through the Android overlay window service.

A runtime issue was found where the clicker could start while the floating overlay service was not enabled or visible. In that state the user could see the blue tap indicator on the Android home screen, but the manual pause/stop/close controls were absent.

The fix is in the Flutter controller layer: starting the clicker now requires draw-over-apps permission and starts the floating overlay controls before starting native auto-click gestures. If overlay permission is missing, the clicker start is blocked with a setup message so the user is not left without visible emergency controls.

Native diagnostics with the `ClickAssistOverlay` tag log service connection, start commands, target indicator creation, control overlay creation, `WindowManager.addView` success/failure, bounds updates, relocation decisions, and remove calls.

## Overlay lifecycle

The overlay lifecycle is tied to clicker runtime state:

1. User starts the clicker from Flutter.
2. Flutter sends the start command to native Android.
3. Accessibility service prepares the click loop.
4. Floating overlay appears.
5. Overlay bounds are tracked after layout and movement.
6. Click gestures are checked against the protected zone.
7. User can pause/resume/stop from overlay controls.
8. Service removes overlay and cleans runtime state when stopped.

## Current limitations

- Overlay behavior needs physical-device and emulator validation across Android versions.
- Manufacturer-specific overlay and accessibility settings may affect setup.
- If the requested tap target is directly under the overlay and no safe relocation is possible, that specific tap can be skipped.
- The point picker overlay still requires emulator/device validation for drag feel, coordinate accuracy, and system-window behavior across Android versions.
- Visual feedback for skipped protected taps is intentionally subtle and may need UX tuning after testing.
