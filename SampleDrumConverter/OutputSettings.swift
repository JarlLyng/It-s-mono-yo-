import AudioToolbox

// MARK: - Output Bit Depth

enum OutputBitDepth: String, CaseIterable, Identifiable {
    case int16 = "16-bit"
    case int24 = "24-bit"
    case float32 = "32-bit float"

    var id: String { rawValue }

    var bitsPerChannel: UInt32 {
        switch self {
        case .int16: return 16
        case .int24: return 24
        case .float32: return 32
        }
    }

    var bytesPerFrame: UInt32 {
        switch self {
        case .int16: return 2
        case .int24: return 3
        case .float32: return 4
        }
    }

    var formatFlags: AudioFormatFlags {
        switch self {
        case .int16:
            return kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked
        case .int24:
            return kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked
        case .float32:
            return kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked
        }
    }
}

// MARK: - Output File Type

enum OutputFileType: String, CaseIterable, Identifiable {
    case wav = "WAV"
    case aiff = "AIFF"

    var id: String { rawValue }

    var fileExtension: String {
        switch self {
        case .wav: return "wav"
        case .aiff: return "aiff"
        }
    }

    func audioFileTypeID(bitDepth: OutputBitDepth) -> AudioFileTypeID {
        switch self {
        case .wav:
            return kAudioFileWAVEType
        case .aiff:
            // Standard AIFF doesn't support float — use AIFF-C for 32-bit float
            if bitDepth == .float32 {
                return kAudioFileAIFCType
            }
            return kAudioFileAIFFType
        }
    }

    func formatFlags(bitDepth: OutputBitDepth) -> AudioFormatFlags {
        switch self {
        case .wav:
            return bitDepth.formatFlags
        case .aiff:
            // AIFF uses big-endian for integer formats
            switch bitDepth {
            case .int16, .int24:
                return kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsBigEndian
            case .float32:
                return kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kLinearPCMFormatFlagIsBigEndian
            }
        }
    }
}

// MARK: - Sample Rate Option

enum SampleRateOption: Hashable, Identifiable {
    case keepOriginal
    case resample(Double)

    var id: String {
        switch self {
        case .keepOriginal: return "original"
        case .resample(let rate): return "resample-\(rate)"
        }
    }

    var label: String {
        switch self {
        case .keepOriginal: return "Keep Original"
        case .resample(let rate):
            let kHz = rate / 1000.0
            if kHz == kHz.rounded() {
                return "\(Int(kHz)) kHz"
            }
            return "\(String(format: "%.1f", kHz)) kHz"
        }
    }

    static let presets: [SampleRateOption] = [
        .keepOriginal,
        .resample(44100),
        .resample(48000),
        .resample(96000)
    ]
}

// MARK: - Output Settings

struct OutputSettings {
    var bitDepth: OutputBitDepth = .int16
    var fileType: OutputFileType = .wav
    var sampleRate: SampleRateOption = .keepOriginal

    func targetSampleRate(inputSampleRate: Double) -> Double {
        switch sampleRate {
        case .keepOriginal: return inputSampleRate
        case .resample(let rate): return rate
        }
    }

    func buildOutputFormat(sampleRate: Double) -> AudioStreamBasicDescription {
        let bytesPerFrame = bitDepth.bytesPerFrame
        return AudioStreamBasicDescription(
            mSampleRate: sampleRate,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: fileType.formatFlags(bitDepth: bitDepth),
            mBytesPerPacket: bytesPerFrame,
            mFramesPerPacket: 1,
            mBytesPerFrame: bytesPerFrame,
            mChannelsPerFrame: 1,
            mBitsPerChannel: bitDepth.bitsPerChannel,
            mReserved: 0
        )
    }

    var audioFileTypeID: AudioFileTypeID {
        fileType.audioFileTypeID(bitDepth: bitDepth)
    }
}
