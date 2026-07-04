# 08. Presets and Settings

ClickAssist includes local configuration and preset behavior for reusing common clicker setups.

## Current behavior

The clicker feature stores user-facing configuration locally. Based on the current codebase, presets/settings are used to support repeatable automation settings such as:

- click points
- click interval/speed
- run mode
- click behavior/mode
- saved user preferences for app behavior

The settings/legal area also includes support, privacy, responsible-use, and repository-related information.

## Storage

The app uses local app storage for preferences and presets. There is no documentation or code indicating account-based cloud sync, remote configuration, analytics, or server-side preset storage.

## Presets and clicker configuration

Presets are intended to reduce repeated manual setup. A user can configure clicker behavior and reuse a saved configuration rather than rebuilding it each time.

Presets affect the clicker by providing the configuration sent from Flutter to the native Android side when the clicker starts.

## Current limitations

- Preset behavior should be covered by more explicit save/load tests.
- Import/export behavior should be documented further if expanded.
- The docs should stay conservative until screenshots and user flows are verified on a device.

## Future improvement ideas

- Add clearer preset naming and duplicate/rename/delete flows if not already complete.
- Add explicit validation messages for invalid timing or missing click points.
- Add tests for preset persistence and loading behavior.
- Add screenshots for preset/configuration screens after running the current app UI.
