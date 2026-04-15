import AVFoundation
import AudioToolbox

// MARK: - Audio File Format

struct AudioFileFormat: Sendable {
    let channels: Int
    let sampleRate: Double
    let bitDepth: Int

    var description: String {
        let sampleRateInKHz = sampleRate / 1000.0
        return "\(channels == 1 ? "Mono" : "Stereo"), \(String(format: "%.1f", sampleRateInKHz)) kHz, \(bitDepth)-bit"
    }
}

/// Extracts audio format information from an audio file
func getAudioFormat(for url: URL) -> AudioFileFormat? {
    guard let file = try? AVAudioFile(forReading: url) else { return nil }
    let format = file.processingFormat

    return AudioFileFormat(
        channels: Int(format.channelCount),
        sampleRate: format.sampleRate,
        bitDepth: Int(format.streamDescription.pointee.mBitsPerChannel)
    )
}

// MARK: - Conversion Error

enum ConversionError: LocalizedError {
    case inputFileOpenFailed
    case outputFileCreateFailed
    case inputFormatReadFailed
    case clientFormatSetFailed
    case fileLengthReadFailed
    case readFramesFailed
    case writeFramesFailed

    var errorDescription: String? {
        switch self {
        case .inputFileOpenFailed:
            return "Could not open input file. Please ensure it's a valid audio file."
        case .outputFileCreateFailed:
            return "Could not create output file. Please check disk space and permissions."
        case .inputFormatReadFailed:
            return "Could not read input file format. File may be corrupted."
        case .clientFormatSetFailed:
            return "Could not set audio processing format. Please try again."
        case .fileLengthReadFailed:
            return "Could not determine file length. File may be corrupted."
        case .readFramesFailed:
            return "Error reading audio data. File may be corrupted."
        case .writeFramesFailed:
            return "Error writing audio data. Please check disk space."
        }
    }
}

// MARK: - Downmix Weights

/// Returns per-channel weights for downmixing to mono.
/// Uses ITU-R BS.775 standard weights for surround layouts.
/// Stereo uses simple equal average.
private func downmixWeights(channelCount: Int) -> [Float] {
    switch channelCount {
    case 1:
        return [1.0]
    case 2:
        // Stereo: equal average
        return [0.5, 0.5]
    case 3:
        // L, R, C — center gets more weight
        // Normalize: 1.0 + 1.0 + 1.414 = 3.414
        let norm: Float = 1.0 / 3.414
        return [1.0 * norm, 1.0 * norm, 1.414 * norm]
    case 4:
        // L, R, Ls, Rs — quad
        return [0.25, 0.25, 0.25, 0.25]
    case 5:
        // L, R, C, Ls, Rs (5.0)
        // ITU: L*1.0 + R*1.0 + C*0.707 + Ls*0.707 + Rs*0.707
        let sum: Float = 1.0 + 1.0 + 0.707 + 0.707 + 0.707
        return [1.0 / sum, 1.0 / sum, 0.707 / sum, 0.707 / sum, 0.707 / sum]
    case 6:
        // L, R, C, LFE, Ls, Rs (5.1)
        // ITU: L*1.0 + R*1.0 + C*0.707 + LFE*0.0 + Ls*0.707 + Rs*0.707
        let sum: Float = 1.0 + 1.0 + 0.707 + 0.0 + 0.707 + 0.707
        return [1.0 / sum, 1.0 / sum, 0.707 / sum, 0.0 / sum, 0.707 / sum, 0.707 / sum]
    default:
        // Unknown layout: equal average
        let weight = 1.0 / Float(channelCount)
        return Array(repeating: weight, count: channelCount)
    }
}

// MARK: - Overwrite Protection

/// Resolves the output URL to avoid overwriting existing files.
/// Appends " (1)", " (2)", etc. before the extension until a unique path is found.
func resolveOutputURL(_ proposedURL: URL) -> URL {
    guard FileManager.default.fileExists(atPath: proposedURL.path) else {
        return proposedURL
    }

    let directory = proposedURL.deletingLastPathComponent()
    let ext = proposedURL.pathExtension
    let baseName = proposedURL.deletingPathExtension().lastPathComponent

    var counter = 1
    while true {
        let newName = "\(baseName) (\(counter))"
        let newURL = directory.appendingPathComponent(newName).appendingPathExtension(ext)
        if !FileManager.default.fileExists(atPath: newURL.path) {
            return newURL
        }
        counter += 1
    }
}

// MARK: - Audio Conversion

/// Converts an audio file to mono with the specified output settings.
///
/// Uses ExtAudioFile to read the input as float32, perform weighted downmix to mono,
/// and write to the output format specified in settings. ExtAudioFile handles
/// bit depth conversion and sample rate conversion natively.
func convertAudioFile(
    inputURL: URL,
    outputURL: URL,
    settings: OutputSettings,
    updateProgress: @escaping (Float) -> Void
) async throws {
    var inputFile: ExtAudioFileRef?
    var outputFile: ExtAudioFileRef?

    // Open input file
    guard ExtAudioFileOpenURL(inputURL as CFURL, &inputFile) == noErr,
          let inputFile = inputFile else {
        throw ConversionError.inputFileOpenFailed
    }
    defer { ExtAudioFileDispose(inputFile) }

    // Get input format
    var inputFormat = AudioStreamBasicDescription()
    var propSize = UInt32(MemoryLayout<AudioStreamBasicDescription>.stride)
    guard ExtAudioFileGetProperty(inputFile,
                                kExtAudioFileProperty_FileDataFormat,
                                &propSize,
                                &inputFormat) == noErr else {
        throw ConversionError.inputFormatReadFailed
    }

    // Determine target sample rate
    let targetSampleRate = settings.targetSampleRate(inputSampleRate: inputFormat.mSampleRate)

    // Build output file format from settings
    var outputFormat = settings.buildOutputFormat(sampleRate: targetSampleRate)

    // Create output file
    guard ExtAudioFileCreateWithURL(
        outputURL as CFURL,
        settings.audioFileTypeID,
        &outputFormat,
        nil,
        AudioFileFlags.eraseFile.rawValue,
        &outputFile
    ) == noErr,
    let outputFile = outputFile else {
        throw ConversionError.outputFileCreateFailed
    }
    defer { ExtAudioFileDispose(outputFile) }

    // Set client format on input file to float32 (multi-channel, at target sample rate)
    // ExtAudioFile handles sample rate conversion when client rate differs from file rate
    let channelCount = inputFormat.mChannelsPerFrame
    var inputClientFormat = AudioStreamBasicDescription(
        mSampleRate: targetSampleRate,
        mFormatID: kAudioFormatLinearPCM,
        mFormatFlags: kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked,
        mBytesPerPacket: 4 * channelCount,
        mFramesPerPacket: 1,
        mBytesPerFrame: 4 * channelCount,
        mChannelsPerFrame: channelCount,
        mBitsPerChannel: 32,
        mReserved: 0
    )

    guard ExtAudioFileSetProperty(inputFile,
                                kExtAudioFileProperty_ClientDataFormat,
                                UInt32(MemoryLayout<AudioStreamBasicDescription>.stride),
                                &inputClientFormat) == noErr else {
        throw ConversionError.clientFormatSetFailed
    }

    // Set client format on output file to float32 mono
    // ExtAudioFile handles the conversion from float32 to the target bit depth on write
    var outputClientFormat = AudioStreamBasicDescription(
        mSampleRate: targetSampleRate,
        mFormatID: kAudioFormatLinearPCM,
        mFormatFlags: kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked,
        mBytesPerPacket: 4,
        mFramesPerPacket: 1,
        mBytesPerFrame: 4,
        mChannelsPerFrame: 1,
        mBitsPerChannel: 32,
        mReserved: 0
    )

    guard ExtAudioFileSetProperty(outputFile,
                                kExtAudioFileProperty_ClientDataFormat,
                                UInt32(MemoryLayout<AudioStreamBasicDescription>.stride),
                                &outputClientFormat) == noErr else {
        throw ConversionError.clientFormatSetFailed
    }

    // Get total number of frames
    var fileLengthFrames: Int64 = 0
    propSize = UInt32(MemoryLayout<Int64>.stride)
    guard ExtAudioFileGetProperty(inputFile,
                                kExtAudioFileProperty_FileLengthFrames,
                                &propSize,
                                &fileLengthFrames) == noErr else {
        throw ConversionError.fileLengthReadFailed
    }

    // Prepare buffers
    let bufferSize = AppConstants.bufferSize
    let intChannelCount = Int(channelCount)
    let buffer = UnsafeMutablePointer<Float>.allocate(capacity: Int(bufferSize) * intChannelCount)
    defer { buffer.deallocate() }

    let monoBuffer = UnsafeMutablePointer<Float>.allocate(capacity: Int(bufferSize))
    defer { monoBuffer.deallocate() }

    // Get downmix weights for this channel layout
    let weights = downmixWeights(channelCount: intChannelCount)

    var currentFrame: Int64 = 0

    while currentFrame < fileLengthFrames {
        var frameCount = bufferSize
        let bytesPerFrame = intChannelCount * MemoryLayout<Float>.size
        let totalBytes = Int(bufferSize) * bytesPerFrame
        var inputBufferList = AudioBufferList(
            mNumberBuffers: 1,
            mBuffers: AudioBuffer(
                mNumberChannels: channelCount,
                mDataByteSize: UInt32(totalBytes),
                mData: buffer
            )
        )

        // Read frames (at target sample rate if resampling)
        guard ExtAudioFileRead(inputFile, &frameCount, &inputBufferList) == noErr else {
            throw ConversionError.readFramesFailed
        }

        if frameCount == 0 { break }

        // Weighted downmix to mono
        let floatBuffer = UnsafeBufferPointer(start: buffer, count: Int(frameCount) * intChannelCount)
        for frame in 0..<Int(frameCount) {
            var sample: Float = 0
            for channel in 0..<intChannelCount {
                sample += floatBuffer[frame * intChannelCount + channel] * weights[channel]
            }
            // Clamp to valid range
            monoBuffer[frame] = max(-1.0, min(1.0, sample))
        }

        // Write mono float data — ExtAudioFile converts to target bit depth
        var outputBufferList = AudioBufferList(
            mNumberBuffers: 1,
            mBuffers: AudioBuffer(
                mNumberChannels: 1,
                mDataByteSize: UInt32(Int(frameCount) * MemoryLayout<Float>.stride),
                mData: monoBuffer
            )
        )

        guard ExtAudioFileWrite(outputFile, frameCount, &outputBufferList) == noErr else {
            throw ConversionError.writeFramesFailed
        }

        currentFrame += Int64(frameCount)
        updateProgress(Float(currentFrame) / Float(fileLengthFrames))
    }
}
