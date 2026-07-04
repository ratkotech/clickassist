# ClickAssist Analysis Documentation

This folder contains the current project analysis for ClickAssist. It is split into focused files so reviewers can understand the app purpose, architecture, UI direction, Android integration, tests, and known limitations without reading one long document.

The documentation describes what currently exists in the repository. Planned work is explicitly marked as planned or recommended.

Current version: 1.0.1

## Analysis index

- [01. Project overview](01-project-overview.md) — what ClickAssist is, who it is for, and why Android accessibility permission is required.
- [02. Current feature set](02-current-feature-set.md) — implemented, partially implemented, and planned features.
- [03. Architecture](03-architecture.md) — folder structure, Flutter layers, native Android bridge, and important files.
- [04. UI/UX analysis](04-ui-ux-analysis.md) — dashboard, setup guide, start button, overlay experience, and UX gaps.
- [05. Theme and typography](05-theme-and-typography.md) — centralized theme and typography system.
- [06. Overlay and accessibility analysis](06-overlay-accessibility-analysis.md) — native overlay behavior, accessibility service behavior, and overlay safe-zone protection.
- [07. Clicker flow analysis](07-clicker-flow-analysis.md) — end-to-end clicker lifecycle and communication sequence.
- [08. Presets and settings](08-presets-and-settings.md) — saved configuration, local preferences, presets, and limitations.
- [09. Testing and quality](09-testing-and-quality.md) — current tests, quality guards, and recommended future coverage.
- [10. Limitations and future improvements](10-limitations-and-future-improvements.md) — known constraints, risks, and roadmap.
- [Diagrams](diagrams.md) — Mermaid diagrams for architecture, flows, overlay lifecycle, and testing strategy.

## Related documentation

- [Screenshots](../screenshots/README.md)
- [Outdated documentation archive](../outdated/README.md)
- [Play Store review checklist](../play-store-review-checklist.md)

## Current documentation status

The current docs reflect the latest local implementation state, including:

- centralized typography in `implementation/clickassist/lib/app/theme/app_text_styles.dart`
- app-wide theme wiring in `implementation/clickassist/lib/app/theme/app_theme.dart`
- updated dashboard/setup/start-button styling
- current logo and app icon assets
- Android overlay controls using play/pause/stop-style controls rather than the full app logo as the start/stop control
- overlay safe-zone protection logic in the native Android layer
- pick-on-screen target selection with a native marker overlay, live coordinate feedback, confirm/cancel actions, and clearer confirmed-target cards
- Settings/About release metadata for version `1.0.1`

Current screenshots still need to be captured from a running emulator/device after the latest UI changes. See [screenshots](../screenshots/README.md).
