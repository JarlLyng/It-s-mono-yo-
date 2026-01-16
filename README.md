# It's mono, yo!

![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![Release](https://img.shields.io/github/v/release/JarlLyng/It-s-mono-yo-)
![License](https://img.shields.io/github/license/JarlLyng/It-s-mono-yo-)
![Website](https://img.shields.io/website?url=https%3A%2F%2Fitsmonoyo.iamjarl.com)

A macOS application for batch converting WAV audio files to mono format while preserving original sample rates.

[🌐 Visit Website](https://itsmonoyo.iamjarl.com) | [⬇️ Download Latest Release](https://github.com/JarlLyng/It-s-mono-yo-/releases/latest)

![App Screenshot](screenshots/Screenshot.png)

Perfect for preparing samples for hardware like the Erica Synths Sample Drum module.

## Features

- Batch conversion of multiple files
- Preserves original sample rate
- Progress tracking for each file
- Error handling with retry option
- Keyboard shortcuts for common actions (⌘O, ESC)
- Context menu actions for individual files
- Direct access to converted files in Finder
- IAMJARL Design System with light & dark mode
- Drag and drop support
- Step-by-step conversion process
- Security-scoped file access

## System Requirements

- macOS 11.0 or later
- 64-bit processor
- Audio files in WAV format
- Maximum file size: 100 MB per file
- Up to 50 files can be converted in one batch

## Installation

### Download from GitHub
1. Go to the [Releases](https://github.com/JarlLyng/It-s-mono-yo-/releases) page
2. Download the latest version
3. Move the app to your Applications folder
4. Right-click and select "Open" the first time you run it

### Building from Source
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
   - Click to select WAV files or drag and drop files
   - Use ⌘O keyboard shortcut
   - Select one or more WAV files (up to 50 files)
3. Choose output folder
4. Start conversion
5. Access converted files directly from the completion screen using "Show in Finder"

## Known Issues

- Large files (>100MB) are not supported
- Only WAV files are supported
- System audio dialogs may appear behind the app window

## Release Notes

### Version 1.0.7
- Bug fixes for version check & shortcuts
- Performance improvements with async/await conversion
- Smaller app size (removed unused dependencies)
- Better UI with file limit indicator
- IAMJARL Design System integration

### Version 1.0
- Initial release
- Basic stereo to mono conversion
- Batch processing support
- Dark mode interface
- Step-by-step UI

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and AVFoundation
- Icons from SF Symbols
- Testing support from the macOS developer community