import XCTest
import AVFoundation
@testable import It_s_mono__yo_

final class AudioConversionTests: XCTestCase {
    let testBundle = Bundle(for: AudioConversionTests.self)

    // MARK: - Basic Conversion

    func testStereoToMonoConversion() async throws {
        guard let inputURL = testBundle.url(forResource: "test_stereo", withExtension: "wav") else {
            throw XCTSkip("Test fixture 'test_stereo.wav' not found in test bundle")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_output.wav")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        // Default settings: 16-bit WAV
        try await convertAudioFile(inputURL: inputURL, outputURL: outputURL, settings: OutputSettings()) { _ in }

        guard let outputFile = try? AVAudioFile(forReading: outputURL) else {
            XCTFail("Could not read output file")
            return
        }

        XCTAssertEqual(outputFile.processingFormat.channelCount, 1)

        let inputFile = try XCTUnwrap(try? AVAudioFile(forReading: inputURL))
        XCTAssertEqual(outputFile.processingFormat.sampleRate, inputFile.processingFormat.sampleRate)
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
        guard let inputURL = testBundle.url(forResource: "test_stereo", withExtension: "wav") else {
            throw XCTSkip("Test fixture 'test_stereo.wav' not found in test bundle")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_24bit.wav")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        var settings = OutputSettings()
        settings.bitDepth = .int24
        try await convertAudioFile(inputURL: inputURL, outputURL: outputURL, settings: settings) { _ in }

        let outputFile = try XCTUnwrap(try? AVAudioFile(forReading: outputURL))
        XCTAssertEqual(outputFile.processingFormat.channelCount, 1)
        XCTAssertEqual(outputFile.fileFormat.streamDescription.pointee.mBitsPerChannel, 24)
    }

    func test32BitFloatOutput() async throws {
        guard let inputURL = testBundle.url(forResource: "test_stereo", withExtension: "wav") else {
            throw XCTSkip("Test fixture 'test_stereo.wav' not found in test bundle")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_32float.wav")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        var settings = OutputSettings()
        settings.bitDepth = .float32
        try await convertAudioFile(inputURL: inputURL, outputURL: outputURL, settings: settings) { _ in }

        let outputFile = try XCTUnwrap(try? AVAudioFile(forReading: outputURL))
        XCTAssertEqual(outputFile.processingFormat.channelCount, 1)
        XCTAssertEqual(outputFile.fileFormat.streamDescription.pointee.mBitsPerChannel, 32)
    }

    // MARK: - AIFF Output

    func testAIFFOutput() async throws {
        guard let inputURL = testBundle.url(forResource: "test_stereo", withExtension: "wav") else {
            throw XCTSkip("Test fixture 'test_stereo.wav' not found in test bundle")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_output.aiff")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        var settings = OutputSettings()
        settings.fileType = .aiff
        try await convertAudioFile(inputURL: inputURL, outputURL: outputURL, settings: settings) { _ in }

        let outputFile = try XCTUnwrap(try? AVAudioFile(forReading: outputURL))
        XCTAssertEqual(outputFile.processingFormat.channelCount, 1)
    }

    // MARK: - Sample Rate Conversion

    func testSampleRateConversion() async throws {
        guard let inputURL = testBundle.url(forResource: "test_stereo", withExtension: "wav") else {
            throw XCTSkip("Test fixture 'test_stereo.wav' not found in test bundle")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_48k.wav")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        var settings = OutputSettings()
        settings.sampleRate = .resample(48000)
        try await convertAudioFile(inputURL: inputURL, outputURL: outputURL, settings: settings) { _ in }

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
}
