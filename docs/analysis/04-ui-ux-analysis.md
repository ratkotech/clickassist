# 04. UI/UX Analysis

ClickAssist currently follows a dark, high-contrast visual direction with cyan brand accents, rounded cards, and a prominent play-logo identity. Recent changes focused on typography consistency, spacing, and making core controls clearer.

## Current UI direction

The current UI direction is practical and utility-focused:

- dark navy background
- bright cyan primary brand/accent color
- rounded cards and buttons
- centralized typography scale
- consistent spacing tokens
- clearer status and setup affordances

The app should feel like a focused Android utility rather than a marketing-heavy consumer app.

## Branding direction

The current visual identity uses the ClickAssist play-button mark as the app logo and app icon source. The logo is used for branding surfaces, while action controls should use action-specific icons so users do not confuse the brand mark with runtime state.

Current source assets live in `design/` and runtime assets live under `implementation/clickassist/assets/branding/` and Android `res/` folders.

## Dashboard experience

Dashboard/status cards present app state and setup readiness. `dashboard_status_card.dart` was recently updated as part of the typography and spacing cleanup, reducing widget-level styling and aligning the card with the centralized theme.

## Setup guide experience

`setup_guide_card.dart` presents permission/setup progress with status, settings navigation, and refresh behavior. The setup guide is important because Android accessibility permission must be enabled outside the app in system settings.

## Pick-on-screen experience

The pick-on-screen flow now separates Flutter status copy from native target placement controls.

Flutter shows a short active state while the native picker is open:

- picker active status
- instruction to use the overlay controls
- existing cancel action from the Flutter click-point list

The native Android picker overlay provides the detailed placement UI. It includes a top instruction card, a large draggable bullseye/crosshair marker, live coordinate feedback, and a bottom action bar with Cancel and Confirm. The marker represents the exact saved tap point and is clamped inside the visible screen so edge selections remain valid.

Confirmed targets are displayed as saved target cards with clear X/Y coordinates, relative position percentages, edit/delete actions, and semantic labels for assistive technologies.

## Start button behavior

`clicker_start_button.dart` uses the centralized typography/theme system and represents the main app action. The start button should remain visually distinct from the brand logo. In the overlay, runtime pause/resume controls use play/pause-style icons rather than the full app logo.

## Overlay UX

The overlay is the most important real-world runtime UX element because it remains visible above other apps while the clicker runs. It needs to be:

- easy to pause/resume
- easy to stop/close
- draggable where supported
- compact enough not to block the screen
- visually consistent with the app brand
- protected from accidental auto-generated clicks

Recent native changes add overlay hit-zone protection so generated taps avoid the overlay controls.

## Strengths

- Consistent brand direction across app logo, app icon, overlay logo resource, and Flutter branding assets.
- Centralized theme and typography reduce visual drift.
- Setup guide makes permission requirements more understandable.
- Overlay controls remain manually touchable while auto-clicking runs.
- Native overlay protection addresses a real usability and safety risk.
- Pick-on-screen target selection now has clearer instructions, stronger marker visibility, explicit confirm/cancel controls, and readable confirmed-target cards.

## Current UX limitations

- Current screenshots have not yet been regenerated from the latest UI.
- Permission setup can still vary by Android manufacturer and OS version.
- Overlay behavior needs real-device testing across screen sizes and density settings.
- Pick-on-screen marker dragging and confirm/cancel behavior needs real-device/emulator validation with overlay permission enabled.
- Some advanced states, such as blocked overlay relocation, may need more visible user feedback after device testing.

## Recommended UX improvements

- Capture updated screenshots for dashboard, setup guide, overlay running state, settings, and preset configuration.
- Add short contextual help near advanced clicker modes.
- Continue testing overlay placement and relocation on small screens.
- Capture picker-specific screenshots for active picker, marker placement, and confirmed target cards.
- Consider subtle runtime messages when a tap is skipped because the overlay is protected.
