# 10. Limitations and Future Improvements

This file records current limitations and pragmatic next steps.

Current visible version: `1.0.1`.

## Current limitations

### Android permission dependency

ClickAssist depends on Android accessibility permission. Without it, the app cannot dispatch gestures into other apps.

### Android overlay restrictions

Floating overlay behavior depends on Android overlay/window rules and device-specific behavior. The implementation must be tested across Android versions and manufacturer-customized settings screens.

### Overlay target conflicts

The native implementation now protects overlay controls from auto-generated clicks. If a click target is directly under the overlay, the service can relocate the overlay or skip that specific tap. This is safer than allowing the clicker to accidentally press stop/close/pause controls, but it means some tap targets may be skipped until the overlay is moved.

### Screenshot freshness

Current screenshots have not yet been regenerated from the latest UI and branding work. Older screenshot/media files are archived under `docs/outdated/`.

### Point picker validation

The pick-on-screen UI has code-level and widget-level guard coverage, but the native overlay still needs emulator/device verification for drag feel, coordinate accuracy, confirm/cancel reliability, and behavior near screen edges.

### Device testing requirements

Some behavior cannot be fully validated by unit/widget tests:

- accessibility service permission setup
- overlay visibility above other apps
- overlay dragging and relocation
- point picker marker dragging and target confirmation
- gesture dispatch timing
- manufacturer-specific battery/overlay restrictions

## Roadmap

### Near term

- Capture current screenshots from an emulator/device.
- Run manual overlay QA on at least one emulator and one physical device.
- Capture picker-specific screenshots for active picker, marker placement, and confirmed target cards.
- Expand tests for preset save/load behavior.
- Add more native tests around overlay relocation edge cases.

### Medium term

- Improve setup guide copy for manufacturer-specific settings.
- Add clearer feedback when a tap is skipped because it is under the overlay protected zone.
- Improve preset management UX if real use shows friction.
- Add screenshot documentation and release-readiness evidence.

### Longer term

- Build a broader device compatibility checklist.
- Consider optional export/import for presets if not already complete.
- Add more robust lifecycle recovery when Android kills or restarts services.
- Continue hardening privacy/responsible-use documentation for open-source review.
