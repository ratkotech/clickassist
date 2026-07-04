# Design Artifacts

This folder contains visual assets and product design references for ClickAssist.

## Assets

- `clickassist-app-icon.svg`: editable, resolution-independent master of the current app icon.
- `clickassist-app-icon.png`: high-resolution master app icon source used for runtime branding, README branding, and Android launcher assets.

Runtime-ready logo and launcher artwork live in `implementation/clickassist/assets/branding/`.

Current runtime branding assets include:

- `implementation/clickassist/assets/branding/clickassist-app-icon.png`: canonical Flutter branding source copied from the design master.
- `implementation/clickassist/assets/branding/clickassist-adaptive-foreground.png`: padded Android adaptive-icon foreground derived from the same current logo to avoid launcher-mask cropping.

## Archived Visuals

Older visual captures were moved out of this folder because they no longer represent the current UI:

- Previous dashboard screenshot: `../docs/outdated/screenshots/Display.png`
- Previous demo video: `../docs/outdated/media/Video.webm`

TODO: Replace with updated screenshots and demo media after running the latest app build on a device or emulator.

Current screenshot documentation lives in `../docs/screenshots/README.md`.

## Planned Design Additions

- Figma source link or exported wireframes.
- Overlay control state diagrams.
- First-run onboarding flow diagram.
- Preset import/export flow diagram.
- Play Store screenshot set.

## Visual Direction

ClickAssist uses a premium dark interface with neon blue accents, compact controls, clear status feedback, and safety-oriented permission copy.
