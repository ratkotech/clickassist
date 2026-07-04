# ClickAssist 1.0.1 Export

This folder contains the local Android export package for ClickAssist version `1.0.1+2`.

## Files

- `clickassist-1.0.1+2-release.apk` — signed Android release APK.
- `SHA256SUMS.txt` — SHA-256 checksums for the versioned APK and convenience APK.
- `APK-METADATA.txt` — package name, version, SDK, and app label extracted from the APK.
- `APK-SIGNATURE.txt` — APK signature verification output.
- `RELEASE_NOTES.md` — human-readable release notes.
- `previews/` — emulator screenshots and a combined preview sheet for the current UI.

## Verified metadata

- Package: `app.clickassist.android`
- Version name: `1.0.1`
- Version code: `2`
- App label: `ClickAssist`

## Notes

The Play Store app bundle was not exported in this package because `flutter build appbundle --release` failed during native debug-symbol stripping in the local Android toolchain. The APK export was built and verified successfully.
