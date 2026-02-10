# It's mono, yo!

![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![Release](https://img.shields.io/github/v/release/JarlLyng/It-s-mono-yo-)
![License](https://img.shields.io/github/license/JarlLyng/It-s-mono-yo-)
![Website](https://img.shields.io/website?url=https%3A%2F%2Fitsmonoyo.iamjarl.com)

**Open-source** macOS app for batch converting WAV audio files to mono while preserving sample rate. Ideal for hardware like the Erica Synths Sample Drum and other sample-based instruments.

[🌐 Website](https://itsmonoyo.iamjarl.com) · [⬇️ Download](https://github.com/JarlLyng/It-s-mono-yo-/releases/latest) · [🐛 Report issue](https://github.com/JarlLyng/It-s-mono-yo-/issues)

![App Screenshot](screenshots/Screenshot.png)

## Features

- Batch conversion of multiple files
- Preserves original sample rate
- Progress tracking for each file
- Error handling with retry option
- Keyboard shortcuts (⌘O, ESC)
- Context menu actions for individual files
- Direct access to converted files in Finder
- Light and dark mode (follows system appearance)
- Step-by-step conversion process
- Drag and drop support
- “Check for Updates” (directs to App Store)
- Responsive design
- [Accessibility](https://itsmonoyo.iamjarl.com/#accessibility): VoiceOver, system dark mode, status by icons and text

## System Requirements

- macOS 11.0 or later
- 64-bit processor
- Audio files in WAV format
- Maximum file size: 100 MB per file
- Up to 50 files can be converted in one batch

## Technical Architecture

### Core Components

- **Audio Processing Engine**
  - Uses AVFoundation for WAV file handling
  - Maintains original sample rates during conversion
  - Processes files in chunks to optimize memory usage

- **UI Layer**
  - Built with SwiftUI
  - MVVM-inspired architecture
  - Responsive design adapting to window size
  - Follows system light/dark appearance (IAMJARL Design System)

### Key Features Implementation

- **File Processing**
  - Asynchronous file conversion using Swift concurrency
  - Progress tracking with real-time updates
  - Error handling with retry capability

- **State Management**
  - Step-based conversion flow
  - File status tracking
  - Step and file state

### Data Flow

1. File Selection
   - File validation
   - Format detection
   - Status initialization

2. Conversion Process
   - Chunk-based processing
   - Progress updates
   - Error handling

3. Output Generation
   - Maintains file structure
   - Automatic mono conversion
   - Original sample rate preservation

## Installation

### Download
- **Mac App Store (paid):** The newest version is always on the Mac App Store — paid download with automatic updates.
- **GitHub (free):** [Releases](https://github.com/JarlLyng/It-s-mono-yo-/releases) — free builds when we publish them. Move to Applications, then right-click → Open the first time (Gatekeeper).

### Build from source
1. Clone the repository:
   ```bash
   git clone https://github.com/JarlLyng/It-s-mono-yo-.git
   ```
2. Open `It's mono, yo!.xcodeproj` in Xcode
3. Select your development team in signing settings
4. Build and run (⌘R)

## Usage

1. Launch the app
2. Add WAV files:
   - Click the "Select WAV Files" button or use ⌘O
   - Or drag and drop WAV files directly into the app
   - Select one or more WAV files
3. Choose output folder
4. Start conversion
5. Access converted files directly from the completion screen

## Keyboard Shortcuts

- **⌘O** — Open file picker
- **ESC** — Go back / cancel

## Appearance

The app follows your system light or dark mode and uses the IAMJARL Design System for consistent colors and spacing.

## Known Issues

- Large files (>100MB) are not supported
- Only WAV files are supported
- System audio dialogs may appear behind the app window

## Release Notes

### Version 1.0.8
- App Store release: sandbox, encryption declaration, accessibility (VoiceOver, dark mode, Accessibility URL)
- Export compliance: `ITSAppUsesNonExemptEncryption` set to NO (HTTPS only)
- Documentation: README, Xcode Cloud, App Accessibility; support and accessibility links
- Same app available free on GitHub and paid on Mac App Store

### Version 1.0.7
- Fixed version comparison bug (now uses proper semantic versioning)
- Removed unnecessary AudioKit dependency (reduces app size)
- Improved mono conversion quality
- Fixed keyboard shortcuts (⌘O now works correctly)
- Added visual indicator for maximum file limit (50 files)
- Converted audio conversion to async/await for better performance
- Various code improvements and bug fixes

### Version 1.0.6
- Added drag and drop support
- Added automatic update checking
- Added keyboard shortcuts
- Added modern theme option
- Improved responsive design
- Various UI improvements

### Version 1.0.5
- Initial release
- Basic stereo to mono conversion
- Batch processing support
- Dark mode interface
- Step-by-step UI

## Support

- **Bugs & feature requests:** [GitHub Issues](https://github.com/JarlLyng/It-s-mono-yo-/issues)
- **Website & accessibility info:** [itsmonoyo.iamjarl.com](https://itsmonoyo.iamjarl.com)

## Contributing

Contributions are welcome. Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add your feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a [Pull Request](https://github.com/JarlLyng/It-s-mono-yo-/compare)

See [.github/pull_request_template.md](.github/pull_request_template.md) when submitting a PR.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Documentation (maintainers)

- [XCODE_CLOUD.md](XCODE_CLOUD.md) — Setting up Xcode Cloud CI for this repo
- [APP_ACCESSIBILITY.md](APP_ACCESSIBILITY.md) — App Store Accessibility Nutrition Labels checklist

## Acknowledgments

- SwiftUI and AVFoundation
- SF Symbols for icons
- [IAMJARL Design System](https://iamjarl.com) for UI tokens