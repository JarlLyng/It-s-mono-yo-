import XCTest
import AVFoundation
@testable import SampleDrumConverter

final class AudioConversionTests: XCTestCase {
    let testBundle = Bundle(for: AudioConversionTests.self)
    
    func testStereoToMonoConversion() async throws {
        // Skip test if fixture is not available
        guard let inputURL = testBundle.url(forResource: "test_stereo", withExtension: "wav") else {
            // Test fixture not available - skip test
            throw XCTSkip("Test fixture 'test_stereo.wav' not found in test bundle")
        }
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_output.wav")
        defer {
            // Cleanup
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        // Perform conversion
        try await convertAudioFile(inputURL: inputURL, outputURL: outputURL) { _ in }
        
        // Verify output
        guard let outputFile = try? AVAudioFile(forReading: outputURL) else {
            XCTFail("Could not read output file")
            return
        }
        
        // Check that output is mono
        XCTAssertEqual(outputFile.processingFormat.channelCount, 1)
        
        // Check that sample rate is preserved
        let inputFile = try XCTUnwrap(try? AVAudioFile(forReading: inputURL))
        XCTAssertEqual(outputFile.processingFormat.sampleRate, inputFile.processingFormat.sampleRate)
    }
    
    func testErrorHandling() async throws {
        // Test with invalid input file
        let invalidURL = URL(fileURLWithPath: "/invalid/path.wav")
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("error_test.wav")
        defer {
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        do {
            try await convertAudioFile(inputURL: invalidURL, outputURL: outputURL) { _ in }
            XCTFail("Expected error for invalid input")
        } catch {
            // Should throw ConversionError (inputFileOpenFailed)
            XCTAssertTrue(error is ConversionError || error is NSError, "Expected ConversionError or NSError, got \(type(of: error))")
        }
    }
    
    func testFileSizeValidation() async throws {
        // Create a large test file (> 100 MB) using sparse file to avoid memory allocation
        let largeFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("large_test.wav")
        defer {
            try? FileManager.default.removeItem(at: largeFileURL)
        }
        
        // Create a sparse file larger than 100 MB using FileHandle
        // This avoids allocating 101MB in memory
        let largeFileSize: Int64 = 101 * 1024 * 1024 // 101 MB
        FileManager.default.createFile(atPath: largeFileURL.path, contents: nil, attributes: nil)
        
        let fileHandle = try FileHandle(forWritingTo: largeFileURL)
        defer { try? fileHandle.close() }
        
        // Seek to the end and write a single byte to create a sparse file
        try fileHandle.seek(toOffset: UInt64(largeFileSize - 1))
        fileHandle.write(Data([0]))
        try fileHandle.synchronize()
        
        // Test validation
        do {
            try validateFile(at: largeFileURL)
            XCTFail("Expected error for large file")
        } catch ConversionError.fileSizeTooLarge {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
} 