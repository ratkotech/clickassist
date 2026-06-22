# High-Quality Logo Export Design

## Goal

Replace `design/logo.png` with a high-resolution recreation of the supplied ClickAssist logo lockup and add `design/logo.svg` as its resolution-independent master.

## Source of Truth

The export will use the existing Flutter startup-screen implementation and theme values rather than enlarging screenshot pixels. The supplied image defines the composition and aspect ratio.

## Artwork

- Preserve the dark `#050B1D` background and the original 485:578 canvas ratio.
- Recreate the circular cyan gradient mark, dark inner circle, subtle glow, and rounded play symbol as vector shapes.
- Recreate "ClickAssist" in Roboto ExtraBold using `#1ECFFF`.
- Recreate "Precision tap automation" in Roboto Medium using `#93A4C8`.
- Preserve the supplied image's spacing, alignment, and visual proportions.

## Outputs

- `design/logo.svg`: editable, resolution-independent master.
- `design/logo.png`: lossless RGBA PNG rendered 4096 pixels wide at the original aspect ratio.

The previous launcher-icon exports created during the initial misunderstanding will be removed, and `design/README.md` will describe the corrected logo outputs.

## Verification

- Parse the SVG as XML.
- Confirm the PNG is 4096 pixels wide, uses the 485:578 aspect ratio, and opens successfully.
- Inspect the rendered PNG visually against the supplied reference.
- Confirm the final Git diff contains only the intended design assets and documentation changes.
