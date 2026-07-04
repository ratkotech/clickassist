# 07. Clicker Flow Analysis

This document describes the current end-to-end clicker flow.

The current documented flow reflects version `1.0.1`, including overlay safe-zone checks and the improved pick-on-screen target picker.

## Runtime flow

1. User opens ClickAssist.
2. App checks setup/permission state.
3. If accessibility permission is missing, the setup guide directs the user to Android settings.
4. User configures click points, clicker mode, speed, and related options, or selects a preset.
5. If the user chooses Pick On Screen, Flutter opens `PointPickerOverlayService.kt`.
6. The native picker lets the user drag the marker, review live coordinates, and confirm or cancel.
7. User starts the clicker.
8. Flutter sends the command/configuration to the native Android layer.
9. `AutoClickAccessibilityService.kt` runs the click loop through accessibility gestures.
10. `FloatingOverlayService.kt` shows runtime controls above other apps.
11. Before each generated tap, the native layer checks whether the target would intersect the overlay protected zone.
12. User pauses, resumes, or stops the clicker from the overlay.
13. Native services clean up overlay/runtime state.

## User flow

```mermaid
flowchart TD
    Open["Open app"]
    Check["Check accessibility permission"]
    Missing{"Permission enabled?"}
    Setup["Show setup guide"]
    Settings["Open Android settings"]
    Configure["Configure clicker or choose preset"]
    Pick{"Pick target on screen?"}
    Picker["Drag marker, confirm or cancel"]
    Start["Start clicker"]
    Overlay["Use overlay controls"]
    PauseStop["Pause or stop"]
    Cleanup["Cleanup overlay/service state"]

    Open --> Check
    Check --> Missing
    Missing -- "No" --> Setup
    Setup --> Settings
    Settings --> Check
    Missing -- "Yes" --> Configure
    Configure --> Pick
    Pick -- "Yes" --> Picker
    Picker --> Configure
    Pick -- "No" --> Start
    Start --> Overlay
    Overlay --> PauseStop
    PauseStop --> Cleanup
```

## Sequence diagram

```mermaid
sequenceDiagram
    participant User
    participant UI as Flutter UI
    participant State as Clicker controller/state
    participant Bridge as Native Android bridge
    participant Service as Accessibility service
    participant Overlay as Overlay controls

    User->>UI: Configure clicker
    UI->>State: Save selected options
    User->>UI: Press start
    UI->>State: Start requested
    State->>Bridge: Send clicker configuration
    Bridge->>Service: Start gestures
    Service->>Overlay: Show controls
    Service->>Overlay: Check protected zone before taps
    Overlay-->>User: Pause/stop controls remain touchable
    User->>Overlay: Pause or stop
    Overlay->>Service: Runtime command
    Service->>Bridge: Status update
    Bridge->>State: Runtime state
    State->>UI: Refresh UI
```

## Cleanup expectations

The native Android side should remove overlay UI and stop pending click work when the clicker is stopped. If the service is unavailable or permission is missing, the app should guide the user back to setup rather than pretending the clicker can run.
