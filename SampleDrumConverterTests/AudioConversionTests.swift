import XCTest
import AVFoundation
@testable import It_s_mono__yo_

final class AudioConversionTests: XCTestCase {

    /// Stereo test fixture generated fresh for each test in `setUp`.
    /// Generating it programmatically keeps a binary blob out of git and
    /// guarantees the conversion tests actually run (instead of XCTSkip).
    private var stereoFixtureURL: URL!

    override func setUpWithError() throws {
        stereoFixtureURL = try Self.makeStereoFixture()
    }

    override func tearDownWithError() throws {
        if let url = stereoFixtureURL {
            try? FileManager.default.removeItem(at: url)
        }
        stereoFixtureURL = nil
    }

    // MARK: - Fixture Generation

    /// Writes a short 2-channel, 44.1 kHz WAV file where the left channel is a
    /// constant +0.5 and the right channel a constant -0.5. After an equal-weight
    /// stereo downmix the mono result is 0.0, which gives the conversion tests a
    /// deterministic value to assert against.
    private static func makeStereoFixture() throws -> URL {
        let sampleRate = 44_100.0
        let frameCount: AVAudioFrameCount = 4_410 // 0.1s

        guard let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 2,
            interleaved: false
        ), let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            throw XCTSkip("Could not allocate test audio buffer")
        }

        buffer.frameLength = frameCount
        let channels = buffer.floatChannelData!
        for frame in 0..<Int(frameCount) {
            channels[0][frame] = 0.5  // left
            channels[1][frame] = -0.5 // right
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_stereo_\(UUID().uuidString).wav")
        let file = try AVAudioFile(forWriting: url, settings: format.settings)
        try file.write(from: buffer)
        return url
    }

    // MARK: - Basic Conversion

    func testStereoToMonoConversion() async throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_output.wav")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        // Default settings: 16-bit WAV
        try await convertAudioFile(inputURL: stereoFixtureURL, outputURL: outputURL, settings: OutputSettings()) { _ in }

        let outputFile = try XCTUnwrap(try? AVAudioFile(forReading: outputURL))
        XCTAssertEqual(outputFile.processingFormat.channelCount, 1)

        let inputFile = try XCTUnwrap(try? AVAudioFile(forReading: stereoFixtureURL))
        XCTAssertEqual(outputFile.processingFormat.sampleRate, inputFile.processingFormat.sampleRate)
    }

    /// Verifies the downmix math, not just the channel count: equal-weight summing
    /// of L=+0.5 and R=-0.5 must produce silence (0.0) in the mono output.
    func testDownmixSumsChannelsCorrectly() async throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_downmix.wav")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        var settings = OutputSettings()
        settings.bitDepth = .float32
        try await convertAudioFile(inputURL: stereoFixtureURL, outputURL: outputURL, settings: settings) { _ in }

        let outputFile = try XCTUnwrap(try? AVAudioFile(forReading: outputURL))
        let format = outputFile.processingFormat
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(outputFile.length)))
        try outputFile.read(into: buffer)

        let samples = try XCTUnwrap(buffer.floatChannelData)[0]
        var peak: Float = 0
        for frame in 0..<Int(buffer.frameLength) {
            peak = max(peak, abs(samples[frame]))
        }
        XCTAssertEqual(peak, 0.0, accuracy: 0.0001, "Equal-weight downmix of +0.5/-0.5 should be silence")
    }

    func testErrorHandling() async throws {
        let invalidURL = URL(fileURLWithPath: "/invalid/path.wav")
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("error_test.wav")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        do {
            try await convertAudioFile(inputURL: invalidURL, outputURL: outputURL, settings: OutputSettings()) { _ in }
            XCTFail("Expected error for invalid input")
        } catch {
            XCTAssertTrue(error is ConversionError || error is NSError, "Expected ConversionError or NSError, got \(type(of: error))")
        }
    }

    // MARK: - Bit Depth

    func test24BitOutput() async throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_24bit.wav")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        var settings = OutputSettings()
        settings.bitDepth = .int24
        try await convertAudioFile(inputURL: stereoFixtureURL, outputURL: outputURL, settings: settings) { _ in }

        let outputFile = try XCTUnwrap(try? AVAudioFile(forReading: outputURL))
        XCTAssertEqual(outputFile.processingFormat.channelCount, 1)
        XCTAssertEqual(outputFile.fileFormat.streamDescription.pointee.mBitsPerChannel, 24)
    }

    func test32BitFloatOutput() async throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_32float.wav")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        var settings = OutputSettings()
        settings.bitDepth = .float32
        try await convertAudioFile(inputURL: stereoFixtureURL, outputURL: outputURL, settings: settings) { _ in }

        let outputFile = try XCTUnwrap(try? AVAudioFile(forReading: outputURL))
        XCTAssertEqual(outputFile.processingFormat.channelCount, 1)
        XCTAssertEqual(outputFile.fileFormat.streamDescription.pointee.mBitsPerChannel, 32)
    }

    // MARK: - AIFF Output

    func testAIFFOutput() async throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_output.aiff")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        var settings = OutputSettings()
        settings.fileType = .aiff
        try await convertAudioFile(inputURL: stereoFixtureURL, outputURL: outputURL, settings: settings) { _ in }

        let outputFile = try XCTUnwrap(try? AVAudioFile(forReading: outputURL))
        XCTAssertEqual(outputFile.processingFormat.channelCount, 1)
    }

    // MARK: - Sample Rate Conversion

    func testSampleRateConversion() async throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_48k.wav")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        var settings = OutputSettings()
        settings.sampleRate = .resample(48000)
        try await convertAudioFile(inputURL: stereoFixtureURL, outputURL: outputURL, settings: settings) { _ in }

        let outputFile = try XCTUnwrap(try? AVAudioFile(forReading: outputURL))
        XCTAssertEqual(outputFile.processingFormat.channelCount, 1)
        XCTAssertEqual(outputFile.processingFormat.sampleRate, 48000, accuracy: 1.0)
    }

    // MARK: - Overwrite Protection

    func testOverwriteAutoRename() {
        let dir = FileManager.default.temporaryDirectory
        let testFile = dir.appendingPathComponent("existing.Mono.wav")
        defer {
            try? FileManager.default.removeItem(at: testFile)
            try? FileManager.default.removeItem(at: dir.appendingPathComponent("existing.Mono (1).wav"))
        }

        // Create existing file
        FileManager.default.createFile(atPath: testFile.path, contents: Data([0]), attributes: nil)

        let resolved = resolveOutputURL(testFile)
        XCTAssertNotEqual(resolved.path, testFile.path)
        XCTAssertTrue(resolved.lastPathComponent.contains("(1)"))
    }

    func testNoOverwriteWhenFileDoesNotExist() {
        let dir = FileManager.default.temporaryDirectory
        let testFile = dir.appendingPathComponent("nonexistent_\(UUID().uuidString).wav")

        let resolved = resolveOutputURL(testFile)
        XCTAssertEqual(resolved.path, testFile.path)
    }

    // MARK: - Folder Import

    /// Writes the standard stereo test buffer to a specific URL.
    private static func writeStereoWav(to url: URL) throws {
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44_100, channels: 2, interleaved: false)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1_000)!
        buffer.frameLength = 1_000
        let channels = buffer.floatChannelData!
        for frame in 0..<1_000 {
            channels[0][frame] = 0.5
            channels[1][frame] = -0.5
        }
        let file = try AVAudioFile(forWriting: url, settings: format.settings)
        try file.write(from: buffer)
    }

    /// Folder import must find audio recursively and compute each file's relative
    /// directory (including the picked folder's own name) so output can mirror it.
    func testFolderImportComputesRelativeDirectories() throws {
        let fm = FileManager.default
        let root = fm.temporaryDirectory.appendingPathComponent("Pack_\(UUID().uuidString)")
        let kicks = root.appendingPathComponent("Kicks")
        let snares = root.appendingPathComponent("Snares")
        try fm.createDirectory(at: kicks, withIntermediateDirectories: true)
        try fm.createDirectory(at: snares, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: root) }

        try Self.writeStereoWav(to: root.appendingPathComponent("top.wav"))
        try Self.writeStereoWav(to: kicks.appendingPathComponent("kick.wav"))
        try Self.writeStereoWav(to: snares.appendingPathComponent("snare.wav"))
        // A non-audio file that must be ignored.
        try "x".write(to: root.appendingPathComponent("readme.txt"), atomically: true, encoding: .utf8)

        let found = collectAudioFiles(inFolder: root)
        XCTAssertEqual(found.count, 3, "Should find 3 audio files, ignoring the .txt")

        let packName = root.lastPathComponent
        let byName = Dictionary(uniqueKeysWithValues: found.map { ($0.url.lastPathComponent, $0) })
        XCTAssertEqual(byName["top.wav"]?.relativeDirectory, packName)
        XCTAssertEqual(byName["kick.wav"]?.relativeDirectory, "\(packName)/Kicks")
        XCTAssertEqual(byName["snare.wav"]?.relativeDirectory, "\(packName)/Snares")
        // Every folder-imported file carries the folder as its security-scope root.
        XCTAssertTrue(found.allSatisfy { $0.securityScopeRoot == root })
    }

    /// Guards the parallel-conversion race fix: two inputs sharing a base name
    /// must not resolve to the same output path even before either is written.
    func testUniqueOutputURLAvoidsReservedNames() {
        let dir = FileManager.default.temporaryDirectory
        let base = dir.appendingPathComponent("clash_\(UUID().uuidString).wav")

        let first = uniqueOutputURL(base, taken: [])
        let second = uniqueOutputURL(base, taken: [first.path])

        XCTAssertEqual(first.path, base.path)
        XCTAssertNotEqual(second.path, first.path)
        XCTAssertTrue(second.lastPathComponent.contains("(1)"))
    }
}
