# Milestone 12 Simulator QA

Date: June 30, 2026

## Device matrix

| Device | Runtime | Result |
| --- | --- | --- |
| iPhone 17 | iOS 26.5 | Build, install, launch, and main tool-list layout passed |
| iPhone SE (3rd generation) | iOS 18.2 | Build, install, launch, and compact-width layout passed |
| iPad Pro 11-inch (M4) | iOS 18.5 | Build, install, launch, split-view detail, and calculator controls passed |

## Runtime regression

- Entered `.35 × .1` using the visible calculator controls.
- The calculator accepted the leading decimal in both operands.
- The formatted result displayed `0.0350` (`3.50×10⁻²` in scientific notation).
- The iPad accessibility snapshot exposed 23 actionable calculator controls.

## Diagnostics

- No DrPhos crashes, fatal errors, uncaught exceptions, or failed assertions appeared in the captured runtime logs.
- iOS 26.5 emitted a Simulator-owned duplicate accessibility-bundle warning involving WebCore and WebKit. The app does not link or invoke either framework directly.

## Before App Store submission

- Perform a human VoiceOver traversal of the phone sidebar; SwiftUI's selection-based list rows were readable in the accessibility tree but were not classified as automation tap targets.
- Repeat representative chemistry calculations on at least one physical iPhone and iPad.
- Complete the App Store Connect metadata and screenshot checks in `RELEASE_CHECKLIST.md`.
