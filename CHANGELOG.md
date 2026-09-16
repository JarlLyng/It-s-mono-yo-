# Changelog

All notable changes to It's mono, yo! are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/).

> Entries are reconstructed from release notes. Releases up to 1.3.0 predate this
> changelog, and exact release dates for the earliest versions were not recorded.

## [1.4.2] - 2026-09
### Fixed
- Files were cut short when converting to a higher sample rate. A 44.1 kHz file resampled to 48 kHz stopped after 44.1/48 of its length; a 3:30 file ended at about 3:13. Converting to a lower rate, or keeping the original rate, was unaffected. Thanks to @perpetualgrimace for the report.
- The file list showed every source file as 32-bit. It now reports the file's real bit depth, so 24-bit files are labelled 24-bit.

### Changed
- Minimum macOS is now 12.0. Current Xcode can no longer build for macOS 11, and macOS 11 users can still download the last compatible version from the App Store.

## [1.4.1] - 2026-08
### Changed
- Moved to the shared IAMJARL design tokens (v1.2.1) instead of a local copy. Colours and spacing are unchanged.

### Notes
- Maintenance release. No user-facing behaviour changes; it exists so the App Store listing (subtitle, screenshots) can be corrected, since those fields are version-locked.

## [1.4.0] - 2026-06
### Added
- Folder import: drop or select a folder and convert an entire sample pack in one go, preserving the source folder structure in the output.

## [1.3.1] - 2026-06
### Added
- Conversion test suite now runs against a generated audio fixture.
### Changed
- Batches convert in parallel via a bounded task group (faster on large batches).
- 32-bit float output preserves full headroom (no unnecessary clamping).
### Removed
- Unused internal code paths.

## [1.3.0] - 2026-03
### Added
- In-app App Store review prompt after repeated successful conversions.
### Changed
- Updated to IAMJARL Design System v0.5.0.

## [1.2.0]
### Added
- Configurable output bit depth (16-bit, 24-bit, 32-bit float).
- AIFF input and output support.
- Sample rate conversion (44.1 / 48 / 96 kHz).
- Weighted multi-channel downmix (ITU-R BS.775).
- Overwrite protection with auto-rename.
- Reduce Motion accessibility support.
### Changed
- Removed file count and size limits.
- Refactored into AudioConverter, OutputSettings, and ReducedMotion modules.

## [1.0.8]
### Added
- App Store release with sandbox and accessibility support (VoiceOver, dark mode, accessibility URL).
- Export compliance declaration.

## [1.0.7]
### Changed
- Improved mono conversion quality.
- Async/await conversion pipeline.
- Semantic versioning fix.
### Removed
- AudioKit dependency.
