# App Review: It's mono, yo!

## Findings
- High: Status and error messaging is never shown to the user, so failures are silent and UX guidance doesn't appear. `SampleDrumConverter/ContentView.swift:234`, `SampleDrumConverter/ContentView.swift:1064`, `SampleDrumConverter/ContentView.swift:1181`. Recommendation: render `statusMessage` in the main view and surface `errorMessage` in ConvertView/CompletionView (inline text or alert), and ensure `setStatusMessage` updates are visible.
- Medium: Drag-and-drop file handling may fail in the sandbox because dropped URLs are not security-scoped; this can break conversion for files outside the app container. `SampleDrumConverter/ContentView.swift:833`. Recommendation: call `startAccessingSecurityScopedResource()`/`stopAccessingSecurityScopedResource()` around file access or resolve to a security-scoped bookmark before conversion.
- Medium: "Show in Finder" during conversion does nothing; `showInFinder()` exists but is never called. `SampleDrumConverter/ContentView.swift:1108`, `SampleDrumConverter/ContentView.swift:1205`. Recommendation: wire the button to `showInFinder()` or remove it until conversion completes.
- Low: Audio format display labels Hz values as kHz, which misreports sample rate. `SampleDrumConverter/ContentView.swift:162`. Recommendation: divide by 1000 and format (e.g. `44.1 kHz`) or label as Hz.
- Low: Update check assumes release tags start with `v` and drops the first character, which breaks parsing if tags are `1.0.7`. `SampleDrumConverter/ContentView.swift:455`. Recommendation: only strip a leading `v`, otherwise use the tag as-is.
- Low: Tests are currently unreliable/failing:
  - Missing fixture `test_stereo.wav` means `testStereoToMonoConversion` cannot run. `SampleDrumConverterTests/AudioConversionTests.swift:10`.
  - `testFileSizeValidation` never creates a large file, so it throws a file-not-found error instead of `fileSizeTooLarge`. `SampleDrumConverterTests/AudioConversionTests.swift:49`.
  - `testErrorHandling` expects `ConversionError`, but `validateFile` can throw `NSError` for missing files. `SampleDrumConverterTests/AudioConversionTests.swift:36`.
  - `testErrorStates` looks for a "Try Again" button that doesn't exist in the UI. `SampleDrumConverterUITests/SampleDrumConverterUITests.swift:63`.
  Recommendation: add fixtures, fix the test setup (create/truncate file sizes), and align UI tests with the actual UI or implement the retry UI.

## Open Questions / Assumptions
- Are GitHub release tags guaranteed to be `vX.Y.Z`? If not, the version parsing needs to be tolerant.
- The README mentions "retry option" and "context menu actions"; should those be available after conversion, or should the README be updated?

## Testing Gaps
- No tests cover drag-and-drop in sandboxed environments or security-scoped access.
- No tests assert error/status messaging in the UI (which currently isn't displayed).
