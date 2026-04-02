# Contributing to It's mono, yo!

First off, thank you for considering contributing to **It's mono, yo!**. It's people like you that make the open-source community around hardware samplers and audio production so great.

We welcome all contributions, from bug reports and feature requests, to pull requests fixing typos or adding major new features.

## Code of Conduct

By participating in this project, you are expected to uphold general open-source standards of respect and collaboration. Be communicative, constructive, and respectful when submitting issues or reviewing code.

## How Can I Contribute?

### Reporting Bugs
Bugs are tracked as [GitHub issues](https://github.com/JarlLyng/It-s-mono-yo-/issues). When creating an issue, please use the `bug_report.md` template provided in the repository and ensure you provide:
- Your macOS version.
- Exact steps to reproduce the issue.
- Expected behavior vs actual behavior.

### Suggesting Enhancements
Enhancement suggestions are recorded as [GitHub issues](https://github.com/JarlLyng/It-s-mono-yo-/issues). Please use the `feature_request.md` template provided in the repository to structure your request.

### Pull Requests (Code Contributions)

If you are a Swift developer looking to contribute to the codebase, follow these steps:

1. **Fork the repository** and create your branch from `main`.
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/It-s-mono-yo-.git
   ```
3. **Open Xcode**: Open the `It's mono, yo!.xcodeproj` file in Xcode 16 or newer.
4. **Select Development Team**: Under the project target's *Signing & Capabilities*, select your Apple Developer Team to ensure signing succeeds.
5. **Write your code**: Make your changes.
    * _Architecture note:_ Keep UI changes in SwiftUI and audio processing localized to the `AudioConverter.swift` structures. Ensure heavy conversions remain asynchronous using Swift concurrency (`async/await`).
6. **Test your code**: Ensure the app builds locally (`⌘ + R`) and that core mono downmixing functionality isn't broken. If you've modified the core `ExtAudioFile` logic, deeply test with both WAV and AIFF files.
7. **Commit your changes**: Ensure your commit messages are clear and descriptive.
8. **Push and open a PR**: Push to your fork and submit a pull request to our `main` branch. Please fill out the provided pull request template thoroughly.

## Pull Request Guidelines

- Try to keep your pull requests focused on a single issue or feature.
- Follow the existing Swift coding style and conventions used throughout the project.
- If you change any UI, please include screenshots in your Pull Request description.
- All code must support macOS 11.0 as the minimum deployment target.

Thank you for contributing!
