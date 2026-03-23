# It's mono, yo!

![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![License](https://img.shields.io/github/license/JarlLyng/It-s-mono-yo-)
![Website](https://img.shields.io/website?url=https%3A%2F%2Fitsmonoyo.iamjarl.com)

**Open-source** macOS app for batch converting stereo WAV and AIFF audio files to mono with configurable bit depth, sample rate, and output format. Built for hardware samplers like the Erica Synths Sample Drum, Elektron Digitakt, Roland SP-404, and Eurorack modules.

[Website](https://itsmonoyo.iamjarl.com) · [Mac App Store](https://apps.apple.com/app/its-mono-yo/id6758866918?mt=12) · [Report Issue](https://github.com/JarlLyng/It-s-mono-yo-/issues)

![App Screenshot](screenshots/Screenshot.png)

## Features

- **Batch conversion** — drag in unlimited WAV and AIFF files
- **Configurable bit depth** — 16-bit (default), 24-bit, or 32-bit float output
- **Output format** — WAV or AIFF
- **Sample rate conversion** — keep original, or convert to 44.1 / 48 / 96 kHz
- **Intelligent downmix** — proper stereo summing (not just left channel)
- **Multi-channel support** — weighted downmix using ITU-R BS.775 coefficients for surround audio
- **Overwrite protection** — existing files are auto-renamed, never replaced
- **Drag and drop** — drop files directly into the app
- **Keyboard shortcuts** — ⌘O to open, ESC to go back
- **Accessibility** — VoiceOver support, Reduce Motion, system dark mode
- **Native macOS** — built with SwiftUI, lightweight, no internet required

## Installation

**[Mac App Store](https://apps.apple.com/app/its-mono-yo/id6758866918?mt=12)** — the recommended way to install with automatic updates.

### Build from source

1. Clone the repository:
   ```bash
   git clone https://github.com/JarlLyng/It-s-mono-yo-.git
   ```
2. Open `It's mono, yo!.xcodeproj` in Xcode 16+
3. Select your development team in signing settings
4. Build and run (⌘R)

## System Requirements

- macOS 11.0 or later
- WAV and AIFF file format support

## Usage

1. Launch the app
2. Add audio files — click "Select Files" (⌘O) or drag and drop
3. Configure output settings (format, bit depth, sample rate)
4. Choose an output folder
5. Click Convert
6. Open converted files with "Show in Finder"

## Technical Architecture

- **Audio engine** — AudioToolbox / ExtAudioFile API for format conversion
- **UI** — SwiftUI with step-based conversion flow
- **Downmix** — float32 intermediate processing, ITU-R BS.775 weighted multi-channel downmix
- **Concurrency** — Swift async/await with per-file progress tracking

## Release Notes

### Version 1.2.0
- Configurable output bit depth (16-bit, 24-bit, 32-bit float)
- AIFF input and output support
- Sample rate conversion (44.1 / 48 / 96 kHz)
- No file count or size limits
- Overwrite protection with auto-rename
- Weighted multi-channel downmix (ITU-R BS.775)
- Reduce Motion accessibility support
- Code architecture: extracted AudioConverter, OutputSettings, ReducedMotion modules

### Version 1.0.8
- App Store release with sandbox and accessibility support
- Export compliance declaration
- VoiceOver, dark mode, accessibility URL

### Version 1.0.7
- Semantic versioning fix
- Removed AudioKit dependency
- Improved mono conversion quality
- Async/await conversion pipeline

## Contributing

Contributions are welcome:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes
4. Push and open a [Pull Request](https://github.com/JarlLyng/It-s-mono-yo-/compare)

## License

MIT License — see [LICENSE](LICENSE) for details.

## Support

- **Bugs & feature requests:** [GitHub Issues](https://github.com/JarlLyng/It-s-mono-yo-/issues)
- **Website:** [itsmonoyo.iamjarl.com](https://itsmonoyo.iamjarl.com)
