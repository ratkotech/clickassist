# 02. Current Feature Set

This file separates implemented behavior from partial or planned work based on the current repository.

Current visible version: `1.0.1`.

## Implemented

### Auto clicker functionality

ClickAssist supports configurable click automation through the Flutter clicker feature and the native Android accessibility service. Current configuration includes click points, interval/speed behavior, run mode, and gesture/click behavior used by the Android service.

### Start, pause, resume, and stop behavior

The UI exposes a start button for launching the clicker flow. The Android overlay exposes controls for runtime actions. Recent overlay updates use dedicated play/pause-style controls instead of using the full app logo as the start/stop button.

### Floating overlay controls

The native Android overlay is implemented by `FloatingOverlayService`. It stays available while the clicker is running, supports compact/expanded behavior, and provides manual controls such as pause/resume and close/stop. The overlay is designed to remain touchable so emergency controls are still reachable.

### Overlay safe-zone protection

The native implementation includes `OverlayProtection.kt` and Android unit tests. Before dispatching an auto-generated gesture, the service checks whether the target coordinate intersects the current overlay bounds plus a safety margin. If the tap would hit the overlay, the code attempts to relocate the overlay; if it cannot safely relocate, the tap is skipped.

### Accessibility setup guide

The setup guide guides the user through required Android permissions and status checks. The UI includes permission status, settings navigation, and refresh behavior. Accessibility remains the core required permission for actual tap dispatch.

### Presets and configuration

The app includes preset/configuration support and local storage for clicker-related settings. Presets are used to make repeated click configurations easier to reuse.

### Pick-on-screen target selection

The app includes a native point picker overlay for capturing tap targets outside the Flutter screen. When the picker is active, Flutter shows short active-picker copy and the native overlay provides:

- a top instruction card
- a draggable bullseye/crosshair marker
- live screen-coordinate feedback on the marker and bottom action bar
- explicit Cancel and Confirm actions
- clamped saved coordinates so edge selections stay inside the visible screen

Confirmed targets are shown in Flutter as readable target cards with saved X/Y coordinates, relative percentages, edit/delete actions, and semantic labels.

### Dashboard and status cards

Dashboard/status-card widgets summarize app state and setup readiness. Recent styling work improved spacing, typography consistency, and visual alignment with the app brand.

### Theme and typography consistency

Typography is centralized in `app_text_styles.dart`, and app-wide theme configuration is handled through `app_theme.dart`. Widget-level typography overrides have been reduced where practical.

### Settings and legal/support screens

Settings/legal UI exists in the Flutter app, including support/privacy/responsible-use related content and improved spacing. The About ClickAssist section shows the current app name, visible version `1.0.1`, open-source status, developer label, support email, privacy/responsible-use links, and repository URL.

## Partially implemented or requiring device verification

- Current screenshots are not yet regenerated from the latest UI.
- Overlay behavior has native logic tests, but complete reliability still requires real Android device/emulator validation across screen sizes and Android versions.
- Pick-on-screen target selection has widget/structure guard coverage, but full overlay dragging and confirmation behavior still needs device/emulator verification.
- Permission flows are represented in the UI, but Android settings screens vary by device manufacturer.
- App store assets and final release metadata are not documented as complete.

## Planned or recommended

- Regenerate current screenshots from a running emulator/device.
- Add more integration tests around permission state transitions.
- Expand native tests around overlay relocation edge cases.
- Add device-specific QA notes for Android overlay and battery optimization behavior.
- Continue polishing preset management and setup guidance based on real-device testing.
