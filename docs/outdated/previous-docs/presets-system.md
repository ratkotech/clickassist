# Presets System

Presets store reusable ClickAssist configurations locally on the device.

## Storage

Presets are stored in a local Hive box through `ClickerPresetStorage`.

## Preset Contents

A preset stores:

- Preset name and ID
- Active input mode
- Interval and speed configuration
- Start delay
- Tap pattern
- Click mode and cycle count
- Multi-click and timing mode
- Gesture indicator preference
- Source-specific points and steps

## Source Separation

ClickAssist keeps Click Points and Mimic presets separate.

- Click Points presets save manual click points and manual steps only.
- Mimic presets save mimic points and mimic steps only.
- Loading a preset switches the UI to the preset source.
- Loading a preset clears inactive source data to avoid cross-contamination.

## Import / Export

Presets can be exported to JSON and imported back into the app. Import supports merge or replace behavior.

## Important Files

- `clicker_preset.dart`
- `clicker_preset_storage.dart`
- `clicker_controller.dart`
- `preset_list_section.dart`
