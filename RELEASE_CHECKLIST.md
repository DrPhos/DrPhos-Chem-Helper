# DrPhos Chemistry Pro release checklist

Release candidate: **4.0 (1)**

## Automated verification

- Run the unit-test scheme on an iPhone Simulator.
- Build the Release configuration with code signing disabled.
- Confirm the built app contains `PrivacyInfo.xcprivacy`.
- Confirm the asset catalog compiles without app-icon errors.

## Manual verification

- Exercise every chemistry tool with a representative valid and invalid input.
- Recheck the scientific calculator sequence `.35 × .1`.
- Test portrait and landscape on iPhone and iPad.
- Test the largest Dynamic Type sizes and VoiceOver navigation.
- Confirm the display name, version, build number, icon, category, screenshots, support URL, and privacy answers in App Store Connect.

## Current privacy declaration

The app declares no tracking, collected data, tracking domains, or required-reason API use. Re-audit `PrivacyInfo.xcprivacy` whenever analytics, advertising, networking, persistence, or third-party SDKs are added.
