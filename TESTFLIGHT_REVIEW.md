# TestFlight Review – It's mono, yo!

**Scope**
- App name: **It's mono, yo!** (internal Xcode folder/target names still use `SampleDrumConverter`).
- Reviewed source and config files in `SampleDrumConverter/` plus tests in `SampleDrumConverterTests/` and `SampleDrumConverterUITests/`.
- I did not run tests or build the app.

**Findings (ordered by severity)**
1. **Blocker** – External update flow likely to be rejected for TestFlight/App Store.
   The app checks GitHub releases and opens the GitHub download page from the in‑app update alert. For TestFlight/App Store builds, linking to external distribution is usually disallowed and can cause rejection. Consider disabling this flow for App Store/TestFlight builds or switch to an App Store update path.
   Files: `SampleDrumConverter/ContentView.swift`

2. **High** – UI tests are out of sync with the current UI and will fail if executed.
   The tests look for a button and text labeled “Select WAV Files,” but the UI now uses a tappable drop area with text “Click to select WAV files or drag files here,” and there is no “Select WAV Files” button. Update the UI tests to match the current labels or add accessibility identifiers.
   Files: `SampleDrumConverterUITests/SampleDrumConverterUITests.swift`, `SampleDrumConverter/ContentView.swift`

3. **Medium** – Output folder access may be unreliable in sandboxed environments.
   The output folder chosen via `NSOpenPanel` is used for writing without calling `startAccessingSecurityScopedResource`. In some sandboxed configurations this can fail after the panel closes. Consider calling `startAccessingSecurityScopedResource` on the output folder URL during conversion (and stopping afterward), or store a security‑scoped bookmark.
   Files: `SampleDrumConverter/ContentView.swift`

4. **Medium** – Potential data loss if output file already exists.
   Conversion uses `AudioFileFlags.eraseFile`, so any existing `*.Mono.wav` file in the output folder is silently overwritten. Consider generating unique filenames or prompting before overwrite.
   Files: `SampleDrumConverter/ContentView.swift`

5. **Low** – Bit depth is always converted to 16‑bit.
   Input files with higher bit depth will be down‑converted, which may be unexpected. If this is intentional, surface it in the UI/README; otherwise consider preserving input bit depth or offering a setting.
   Files: `SampleDrumConverter/ContentView.swift`

6. **Low** – Unit test coverage is minimal and one fixture is missing.
   `SampleDrumConverterTests` contains no assertions, and `AudioConversionTests` expects `test_stereo.wav` which isn’t in the repo, so the test is skipped. Add a small WAV fixture to the test bundle or generate it on the fly, and add meaningful tests for conversion and error cases.
   Files: `SampleDrumConverterTests/SampleDrumConverterTests.swift`, `SampleDrumConverterTests/AudioConversionTests.swift`

7. **Low** – Build number/version hygiene.
   Ensure `CFBundleVersion` is incremented for each TestFlight upload and that `CFBundleShortVersionString` matches the release you intend to test.
   Files: `SampleDrumConverter/Info.plist`

**Recommendations Summary**
- Gate or remove the GitHub update checker for App Store/TestFlight builds.
- Update UI tests to match current UI labels or add accessibility identifiers for stable selectors.
- Add security‑scoped access for the output folder during conversion.
- Avoid silent overwrite of existing output files.
- Document or preserve bit depth behavior.
- Add/restore test fixtures and basic assertions for conversion logic.
- Verify build and version numbers before uploading to TestFlight.
