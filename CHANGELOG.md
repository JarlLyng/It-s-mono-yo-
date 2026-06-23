# Changelog

All notable changes to It's mono, yo! are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/).

> Entries are reconstructed from release notes. Releases up to 1.3.0 predate this
> changelog, and exact release dates for the earliest versions were not recorded.

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
