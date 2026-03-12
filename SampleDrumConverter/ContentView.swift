import SwiftUI
import UniformTypeIdentifiers

// MARK: - Constants
enum AppConstants {
    static let bufferSize: UInt32 = 32768
    static let githubRepository = "JarlLyng/It-s-mono-yo-"
    static let githubReleasesURL = "https://api.github.com/repos/\(githubRepository)/releases/latest"
    static let githubReleasesPageURL = "https://github.com/\(githubRepository)/releases/latest"
    static let defaultAppVersion = "1.2.0"
}

// AppTheme replaced with IAMJARL Design Tokens
// Use AdaptiveColor helper functions for color scheme-aware colors

// Spacing and Color extensions moved to DesignTokens.swift

struct AudioFile: Identifiable, Sendable {
    let id = UUID()
    let url: URL
    var status: ConversionStatus = .pending
    var progress: Float = 0.0
    var errorMessage: String?
    
    var format: AudioFileFormat?
    
    enum ConversionStatus: Sendable {
        case pending
        case converting
        case completed
        case failed
        
        var description: String {
            switch self {
            case .pending: return "Pending"
            case .converting: return "Converting"
            case .completed: return "Completed"
            case .failed: return "Failed"
            }
        }
        
        var icon: String {
            switch self {
            case .pending: return "circle"
            case .converting: return "arrow.triangle.2.circlepath"
            case .completed: return "checkmark.circle.fill"
            case .failed: return "exclamationmark.circle.fill"
            }
        }
        
        func color(colorScheme: ColorScheme) -> Color {
            switch self {
            case .pending: return AdaptiveColor.textTertiary(colorScheme)
            case .converting: return AdaptiveColor.primary(colorScheme)
            case .completed: return DesignTokens.Colors.Shared.success
            case .failed: return DesignTokens.Colors.Shared.error
            }
        }
    }
}

// AudioFileFormat, getAudioFormat, and ConversionError are in AudioConverter.swift

enum ConversionStep {
    case selectFiles
    case selectOutput
    case convert
    case completed
    
    var title: String {
        switch self {
        case .selectFiles: return "Select Files"
        case .selectOutput: return "Select Output"
        case .convert: return "Convert"
        case .completed: return "Completed"
        }
    }
    
    var icon: String {
        switch self {
        case .selectFiles: return "plus.rectangle.fill"
        case .selectOutput: return "folder.fill"
        case .convert: return "waveform.circle.fill"
        case .completed: return "checkmark.circle.fill"
        }
    }
}

struct ContentView: View {
    @State private var currentStep = ConversionStep.selectFiles
    @State private var audioFiles: [AudioFile] = []
    @State private var isProcessing = false
    @State private var outputFolder: URL?
    @State private var customStatusMessage: String?
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingUpdateAlert = false
    @State private var latestVersion: String = ""
    @State private var updateURL: String = ""
    @State private var outputSettings = OutputSettings()

    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? AppConstants.defaultAppVersion
    
    private var statusMessage: String {
        if let custom = customStatusMessage {
            return custom
        }
        if isProcessing {
            let completed = audioFiles.filter { $0.status == .completed }.count
            let total = audioFiles.count
            return "Converting... (\(completed)/\(total) completed)"
        }
        if audioFiles.isEmpty {
            return "Click to select audio files or drag and drop files here"
        }
        if outputFolder == nil {
            return "Select output folder to start conversion"
        }
        let pending = audioFiles.filter { $0.status == .pending }.count
        if pending > 0 {
            return "Ready to convert \(pending) files"
        }
        let failed = audioFiles.filter { $0.status == .failed }.count
        if failed > 0 {
            return "\(failed) files failed to convert"
        }
        return "All files converted successfully"
    }
    
    var totalFileSize: Int64 {
        audioFiles.compactMap { try? FileManager.default.attributesOfItem(atPath: $0.url.path)[.size] as? Int64 }
            .reduce(0, +)
    }
    
    var body: some View {
        ZStack {
            // Background - IAMJARL design system
            AdaptiveColor.backgroundApp(colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: DesignTokens.Spacing.xl) {
                // Progress indicators
                HStack(spacing: 15) {
                    ForEach([ConversionStep.selectFiles, .selectOutput, .convert, .completed], id: \.self) { step in
                        Circle()
                            .fill(currentStep == step ? AdaptiveColor.primary(colorScheme) : AdaptiveColor.textTertiary(colorScheme))
                            .frame(width: 10, height: 10)
                            .adaptiveAnimation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
                .padding(.top, DesignTokens.Spacing.lg)
                
                // Status message
                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.subheadline)
                        .foregroundColor(AdaptiveColor.textSecondary(colorScheme))
                        .padding(.horizontal)
                        .padding(.bottom, DesignTokens.Spacing.sm)
                }
                
                // Current step content
                switch currentStep {
                case .selectFiles:
                    SelectFilesView(
                        audioFiles: $audioFiles,
                        onNext: { 
                            adaptiveWithAnimation(.easeInOut) { 
                                currentStep = .selectOutput
                                clearStatusMessage()
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                case .selectOutput:
                    SelectOutputView(
                        outputFolder: $outputFolder,
                        settings: $outputSettings,
                        onBack: {
                            adaptiveWithAnimation(.easeInOut) {
                                currentStep = .selectFiles
                                clearStatusMessage()
                            }
                        },
                        onNext: {
                            adaptiveWithAnimation(.easeInOut) {
                                currentStep = .convert
                                clearStatusMessage()
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                case .convert:
                    ConvertView(
                        audioFiles: $audioFiles,
                        currentStep: $currentStep,
                        isProcessing: $isProcessing,
                        outputFolder: outputFolder,
                        settings: outputSettings,
                        onBack: {
                            adaptiveWithAnimation(.easeInOut) {
                                currentStep = .selectOutput
                                clearStatusMessage()
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                case .completed:
                    CompletionView(
                        audioFiles: audioFiles,
                        outputFolder: outputFolder,
                        onStartOver: { 
                            adaptiveWithAnimation(.easeInOut) { 
                                currentStep = .selectFiles
                                audioFiles.removeAll()
                                isProcessing = false
                                clearStatusMessage()
                            }
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .foregroundColor(AdaptiveColor.textPrimary(colorScheme))
            .adaptiveAnimation(.easeInOut, value: currentStep)
        }
        // Add theme toggle button for testing
        .toolbar {
            ToolbarItem {
                Menu {
                    Button(action: checkForUpdates) {
                        Label("Check for Updates", systemImage: "arrow.triangle.2.circlepath")
                    }
                    
                    // Theme toggle removed - using system color scheme
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("More options")
            }
        }
        .modifier(UpdateAlertModifier(showing: $showingUpdateAlert, latestVersion: $latestVersion, updateURL: $updateURL))
        // Update check disabled: app uses only user-selected file access (no network entitlement) for App Store compliance.
        .onChange(of: isProcessing) { _ in
            // Clear custom status message when processing state changes
            if isProcessing && customStatusMessage != nil {
                clearStatusMessage()
            }
        }
        .onChange(of: currentStep) { _ in
            // Clear custom status message on step transitions
            clearStatusMessage()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenFiles"))) { _ in
            if currentStep == .selectFiles {
                selectFiles()
            }
        }
    }

    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    private func removeFiles(at offsets: IndexSet) {
        audioFiles.remove(atOffsets: offsets)
    }

    private func clearFiles() {
        audioFiles.removeAll()
    }

    func selectFiles() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.wav, .aiff]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false

        if panel.runModal() == .OK {
            let newFiles = panel.urls.compactMap { url -> AudioFile? in
                return AudioFile(url: url, format: getAudioFormat(for: url))
            }
            audioFiles.append(contentsOf: newFiles)
        }
    }
    
    func selectOutputFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = "Choose Output Folder"
        
        if panel.runModal() == .OK {
            outputFolder = panel.url
            setStatusMessage("Output folder selected: \(panel.url?.lastPathComponent ?? "")")
        }
    }
    
    

    @MainActor
    private func addFile(from url: URL) {
        let newFile = AudioFile(url: url, format: getAudioFormat(for: url))
        audioFiles.append(newFile)
    }

    /// Logs a debug message with timestamp
    /// - Parameter message: The message to log
    /// - Note: Only logs in DEBUG builds
    private func log(_ message: String) {
        #if DEBUG
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        print("[\(formatter.string(from: Date()))] \(message)")
        #endif
    }

    /// Shows user where to get updates (App Store). No network access – app uses minimal entitlements for App Review.
    private func checkForUpdates() {
        latestVersion = ""
        updateURL = ""
        showingUpdateAlert = true
    }
    
    /// Compares two semantic version strings
    /// - Returns: > 0 if v1 > v2, < 0 if v1 < v2, 0 if equal
    private func compareVersions(_ v1: String, _ v2: String) -> Int {
        let parts1 = v1.split(separator: ".").compactMap { Int($0) }
        let parts2 = v2.split(separator: ".").compactMap { Int($0) }
        
        let maxCount = max(parts1.count, parts2.count)
        
        for i in 0..<maxCount {
            let p1 = i < parts1.count ? parts1[i] : 0
            let p2 = i < parts2.count ? parts2[i] : 0
            
            if p1 > p2 { return 1 }
            if p1 < p2 { return -1 }
        }
        
        return 0
    }

    /// Updates the status message shown to the user
    /// - Parameter message: The message to display
    /// - Note: Message will be cleared when state changes (e.g., conversion starts/stops)
    private func setStatusMessage(_ message: String) {
        customStatusMessage = message
    }
    
    /// Clears the custom status message to allow dynamic status messages
    private func clearStatusMessage() {
        customStatusMessage = nil
    }
}

private struct UpdateAlertModifier: ViewModifier {
    @Binding var showing: Bool
    @Binding var latestVersion: String
    @Binding var updateURL: String

    func body(content: Content) -> some View {
        if #available(macOS 12.0, *) {
            content.alert(latestVersion.isEmpty ? "Updates" : "Update Available", isPresented: $showing) {
                if latestVersion.isEmpty {
                    Button("OK", role: .cancel) { }
                } else {
                    Button("Download") {
                        if let url = URL(string: updateURL), !url.absoluteString.isEmpty {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    Button("Later", role: .cancel) { }
                }
            } message: {
                Text(latestVersion.isEmpty
                     ? "Check the App Store for the latest version."
                     : "Version \(latestVersion) is available.")
            }
        } else {
            content.alert(isPresented: $showing) {
                Alert(
                    title: Text(latestVersion.isEmpty ? "Updates" : "Update Available"),
                    message: Text(latestVersion.isEmpty
                                 ? "Check the App Store for the latest version."
                                 : "Version \(latestVersion) is available."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

// FileRowView til at vise individuelle filer
struct FileRowView: View {
    let file: AudioFile
    let onRemove: () -> Void
    var onRetry: (() -> Void)?
    var onReveal: (() -> Void)?
    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: file.status.icon)
                .foregroundColor(file.status.color(colorScheme: colorScheme))
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(file.url.lastPathComponent)
                    .font(.system(.body))
                    .foregroundColor(AdaptiveColor.textPrimary(colorScheme))
                if let format = file.format {
                    Text(format.description)
                        .font(.system(size: DesignTokens.Typography.Size.xs))
                        .foregroundColor(AdaptiveColor.textSecondary(colorScheme))
                }
            }
            
            Spacer()
            
            if file.status == .converting {
                ProgressView(value: file.progress)
                    .progressViewStyle(.linear)
                    .frame(width: 100)
                    .accentColor(AdaptiveColor.primary(colorScheme))
            }
        }
        .padding(.vertical, DesignTokens.Spacing.sm)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .background(isHovering ? AdaptiveColor.backgroundCard(colorScheme) : AdaptiveColor.backgroundMuted(colorScheme))
        .cornerRadius(DesignTokens.Radius.sm)
        .onHover { hovering in
            isHovering = hovering
        }
        .adaptiveAnimation(.easeInOut(duration: 0.2), value: isHovering)
        .contextMenu {
            if file.status == .failed {
                Button(action: { onRetry?() }) {
                    Label("Retry Conversion", systemImage: "arrow.clockwise")
                }
            }
            if file.status == .completed {
                Button(action: { onReveal?() }) {
                    Label("Show in Finder", systemImage: "folder")
                }
            }
            Divider()
            if #available(macOS 12.0, *) {
                Button(role: .destructive, action: { onRemove() }) {
                    Label("Remove", systemImage: "trash")
                }
            } else {
                Button(action: { onRemove() }) {
                    Label("Remove", systemImage: "trash")
                }
            }
        }
    }
}

// convertAudioFile and ConversionError are in AudioConverter.swift

struct SelectFilesView: View {
    @Binding var audioFiles: [AudioFile]
    let onNext: () -> Void
    @State private var isDropTargeted = false
    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: geometry.size.height * 0.015) {  // Minimal spacing
                    // Icon and drop zone - moved up
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        Image(systemName: "plus.rectangle.fill")
                            .font(.system(size: min(35, geometry.size.width * 0.05), weight: .ultraLight))
                            .foregroundColor(isDropTargeted || isHovering ? AdaptiveColor.textPrimary(colorScheme) : AdaptiveColor.textTertiary(colorScheme))
                        
                        Text("Click to select WAV or AIFF files\nor drag files here")
                            .font(.system(size: min(DesignTokens.Typography.Size.sm, geometry.size.width * 0.018)))
                            .multilineTextAlignment(.center)
                            .foregroundColor(isDropTargeted || isHovering ? AdaptiveColor.textPrimary(colorScheme) : AdaptiveColor.textTertiary(colorScheme))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: max(120, geometry.size.height * 0.15))  // Further reduced height
                    .background(isDropTargeted || isHovering ? AdaptiveColor.backgroundCard(colorScheme) : AdaptiveColor.backgroundMuted(colorScheme))
                    .cornerRadius(DesignTokens.Radius.lg)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                            .stroke(isDropTargeted || isHovering ? AdaptiveColor.borderDefault(colorScheme) : AdaptiveColor.borderSubtle(colorScheme), lineWidth: 1)
                    )
                    .adaptiveAnimation(.easeInOut(duration: 0.2), value: isDropTargeted)
                    .adaptiveAnimation(.easeInOut(duration: 0.2), value: isHovering)
                    .onHover { hovering in
                        isHovering = hovering
                    }
                    .onTapGesture {
                        selectFiles()
                    }
                    .onDrop(of: [.fileURL], isTargeted: .init(get: { isDropTargeted },
                                                             set: { isDropTargeted = $0 })) { providers in
                        guard !providers.isEmpty else { return false }
                        
                        #if DEBUG
                        print("Received \(providers.count) dropped file(s)")
                        #endif
                        
                        for provider in providers {
                            let _ = provider.loadObject(ofClass: URL.self) { url, error in
                                if let error = error {
                                    #if DEBUG
                                    print("Error reading dropped file: \(error.localizedDescription)")
                                    #endif
                                    return
                                }
                                
                                guard let url = url else {
                                    #if DEBUG
                                    print("Dropped item is not a valid URL")
                                    #endif
                                    return
                                }
                                
                                // Check file extension
                                let ext = url.pathExtension.lowercased()
                                guard ext == "wav" || ext == "aiff" || ext == "aif" else {
                                    #if DEBUG
                                    print("Skipped unsupported file: \(url.lastPathComponent)")
                                    #endif
                                    return
                                }
                                
                                // Access security-scoped resource for sandboxed environments
                                let isAccessing = url.startAccessingSecurityScopedResource()
                                defer {
                                    if isAccessing {
                                        url.stopAccessingSecurityScopedResource()
                                    }
                                }
                                
                                Task { @MainActor in
                                    do {
                                        // Create a security-scoped bookmark for persistent access
                                        let bookmarkData = try url.bookmarkData(
                                            options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess],
                                            includingResourceValuesForKeys: nil,
                                            relativeTo: nil
                                        )
                                        
                                        // Resolve bookmark to get a URL that can be accessed later
                                        var isStale = false
                                        let resolvedURL = try URL(
                                            resolvingBookmarkData: bookmarkData,
                                            options: [.withSecurityScope, .withoutUI],
                                            relativeTo: nil,
                                            bookmarkDataIsStale: &isStale
                                        )
                                        
                                        // Start accessing the resolved URL for validation
                                        let resolvedAccessing = resolvedURL.startAccessingSecurityScopedResource()
                                        defer {
                                            if resolvedAccessing {
                                                resolvedURL.stopAccessingSecurityScopedResource()
                                            }
                                        }
                                        
                                        // Read format and add file
                                        let format = getAudioFormat(for: resolvedURL)
                                        
                                        // Store the resolved URL - access will be re-established during conversion
                                        audioFiles.append(AudioFile(url: resolvedURL, format: format))
                                        
                                        #if DEBUG
                                        print("Successfully added dropped file: \(resolvedURL.lastPathComponent)")
                                        #endif
                                    } catch {
                                        #if DEBUG
                                        print("Error processing dropped file \(url.lastPathComponent): \(error.localizedDescription)")
                                        #endif
                                        // Silently skip invalid files
                                    }
                                }
                            }
                        }
                        // Accept drop so UI feedback is correct; files are added asynchronously
                        return true
                    }
                    
                    // File count indicator
                    if !audioFiles.isEmpty {
                        Text("\(audioFiles.count) \(audioFiles.count == 1 ? "file" : "files")")
                            .font(.system(size: min(DesignTokens.Typography.Size.sm, geometry.size.width * 0.02)))
                            .foregroundColor(AdaptiveColor.textSecondary(colorScheme))
                            .padding(.horizontal)
                    }
                    
                    // Selected files list
                    if !audioFiles.isEmpty {
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
                            Text("Selected Files:")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(audioFiles) { file in
                                        FileRowView(file: file, onRemove: {
                                            // Handle file removal here
                                            if let index = audioFiles.firstIndex(where: { $0.id == file.id }) {
                                                audioFiles.remove(at: index)
                                            }
                                        })
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .frame(maxHeight: geometry.size.height * 0.4)  // Relative height
                        }
                        .padding(DesignTokens.Spacing.xl)
                        .background(AdaptiveColor.backgroundMuted(colorScheme))
                        .cornerRadius(DesignTokens.Radius.lg)
                    }
                    
                    // Next button with hover
                    Button(action: onNext) {
                        Text("Next")
                            .fontWeight(.medium)
                            .frame(width: min(120, geometry.size.width * 0.15),
                                   height: min(36, geometry.size.height * 0.06))
                    }
                    .buttonStyle(HoverButtonStyle(colorScheme: colorScheme))
                    .disabled(audioFiles.isEmpty)
                    .opacity(audioFiles.isEmpty ? 0.5 : 1.0)
                    .adaptiveAnimation(.easeInOut, value: audioFiles.isEmpty)
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, min(24, geometry.size.width * 0.03))
                .padding(.top, min(12, geometry.size.height * 0.01))
            }
        }
    }
    
    private func selectFiles() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.wav, .aiff]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.title = "Select Audio Files"
        panel.prompt = "Select"

        let response = panel.runModal()

        #if DEBUG
        print("NSOpenPanel response: \(response == .OK ? "OK" : "Cancel")")
        #endif

        guard response == .OK else {
            #if DEBUG
            print("User cancelled file selection")
            #endif
            return
        }

        #if DEBUG
        print("Selected \(panel.urls.count) files")
        #endif

        let newFiles = panel.urls.map { url -> AudioFile in
            let format = getAudioFormat(for: url)
            #if DEBUG
            print("Added file: \(url.lastPathComponent)")
            #endif
            return AudioFile(url: url, format: format)
        }

        audioFiles.append(contentsOf: newFiles)

        #if DEBUG
        print("Added \(newFiles.count) files to list. Total: \(audioFiles.count)")
        #endif
    }
}

// Custom button style with color-scheme support for light/dark mode
struct HoverButtonStyle: ButtonStyle {
    var colorScheme: ColorScheme
    @State private var isHovering = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if configuration.isPressed {
                        AdaptiveColor.backgroundCard(colorScheme)
                    } else if isHovering {
                        AdaptiveColor.backgroundCard(colorScheme).opacity(0.8)
                    } else {
                        AdaptiveColor.backgroundMuted(colorScheme)
                    }
                }
            )
            .cornerRadius(DesignTokens.Radius.sm)
            .onHover { hovering in
                isHovering = hovering
            }
            .adaptiveAnimation(.easeInOut(duration: 0.2), value: isHovering)
            .adaptiveAnimation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension View {
    @ViewBuilder
    func applyProminentStyleAndTint(colorScheme: ColorScheme) -> some View {
        if #available(macOS 12.0, *) {
            self.buttonStyle(.borderedProminent)
                .accentColor(AdaptiveColor.primary(colorScheme))
        } else {
            self.buttonStyle(.bordered) // Fallback without tint
        }
    }
}

struct SelectOutputView: View {
    @Binding var outputFolder: URL?
    @Binding var settings: OutputSettings
    let onBack: () -> Void
    let onNext: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Output Settings")
                    .font(.title)
                    .fontWeight(.bold)

                // Folder select area
                VStack(spacing: 16) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 36, weight: .ultraLight))

                    if let folder = outputFolder {
                        VStack(spacing: DesignTokens.Spacing.sm) {
                            Text("Output Folder:")
                                .fontWeight(.medium)
                                .foregroundColor(AdaptiveColor.textPrimary(colorScheme))
                            Text(folder.lastPathComponent)
                                .foregroundColor(AdaptiveColor.textSecondary(colorScheme))
                        }
                    } else {
                        Text("Click to select output folder")
                            .foregroundColor(AdaptiveColor.textSecondary(colorScheme))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 120)
                .background(AdaptiveColor.backgroundMuted(colorScheme))
                .cornerRadius(DesignTokens.Radius.md)
                .onTapGesture(perform: selectOutputFolder)

                // Output format settings
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    // File format
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text("Format")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AdaptiveColor.textSecondary(colorScheme))
                        Picker("Format", selection: $settings.fileType) {
                            ForEach(OutputFileType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Bit depth
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text("Bit Depth")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AdaptiveColor.textSecondary(colorScheme))
                        Picker("Bit Depth", selection: $settings.bitDepth) {
                            ForEach(OutputBitDepth.allCases) { depth in
                                Text(depth.rawValue).tag(depth)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Sample rate
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text("Sample Rate")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AdaptiveColor.textSecondary(colorScheme))
                        Picker("Sample Rate", selection: $settings.sampleRate) {
                            ForEach(SampleRateOption.presets) { option in
                                Text(option.label).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(DesignTokens.Spacing.lg)
                .background(AdaptiveColor.backgroundMuted(colorScheme))
                .cornerRadius(DesignTokens.Radius.md)

                // Navigation buttons
                HStack(spacing: 20) {
                    Button(action: onBack) {
                        Text("Back")
                            .fontWeight(.medium)
                            .frame(width: 100)
                    }
                    .buttonStyle(.bordered)

                    Button(action: onNext) {
                        Text("Next")
                            .fontWeight(.medium)
                            .frame(width: 100)
                    }
                    .applyProminentStyleAndTint(colorScheme: colorScheme)
                    .disabled(outputFolder == nil)
                }

                Spacer()
            }
            .padding()
        }
    }

    private func selectOutputFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = "Choose Output Folder"

        if panel.runModal() == .OK {
            outputFolder = panel.url
        }
    }
}

struct ConvertView: View {
    @Binding var audioFiles: [AudioFile]
    @Binding var currentStep: ConversionStep
    @Binding var isProcessing: Bool
    let outputFolder: URL?
    let settings: OutputSettings
    let onBack: () -> Void
    @State private var isConverting = false
    @State private var errorMessage: String?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 30) {
            // Title
            Text("Convert Files")
                .font(.title)
                .fontWeight(.bold)
            
            // Status and progress
            VStack(spacing: 20) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 40, weight: .ultraLight))
                
                if isConverting {
                    let completed = audioFiles.filter { $0.status == .completed }.count
                    VStack(spacing: 8) {
                        Text("Converting files...")
                            .fontWeight(.medium)
                        Text("\(completed) of \(audioFiles.count) completed")
                            .foregroundColor(AdaptiveColor.textSecondary(colorScheme))
                        
                        // Show current file progress
                        if let converting = audioFiles.first(where: { $0.status == .converting }) {
                            VStack(spacing: DesignTokens.Spacing.xs) {
                                Text(converting.url.lastPathComponent)
                                    .foregroundColor(AdaptiveColor.textSecondary(colorScheme))
                                ProgressView(value: converting.progress)
                                    .progressViewStyle(.linear)
                                    .accentColor(AdaptiveColor.primary(colorScheme))
                                    .frame(width: 200)
                            }
                            .padding(.top)
                        }
                    }
                } else {
                    Text("Ready to convert \(audioFiles.count) files")
                        .foregroundColor(AdaptiveColor.textSecondary(colorScheme))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
            .background(AdaptiveColor.backgroundMuted(colorScheme))
            .cornerRadius(DesignTokens.Radius.md)
            
            // Error message display
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(DesignTokens.Colors.Shared.error)
                    .padding()
                    .background(DesignTokens.Colors.Shared.error.opacity(0.1))
                    .cornerRadius(DesignTokens.Radius.sm)
            }
            
            // Buttons
            if isConverting {
                Button(action: showInFinder) {
                    Text("Show in Finder")
                        .fontWeight(.medium)
                        .frame(width: 150)
                }
                .buttonStyle(.bordered)
                .disabled(outputFolder == nil)
            } else {
                HStack(spacing: 20) {
                    Button(action: onBack) {
                        Text("Back")
                            .fontWeight(.medium)
                            .frame(width: 100)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: startConversion) {
                        Text("Start")
                            .fontWeight(.medium)
                            .frame(width: 100)
                    }
                    .applyProminentStyleAndTint(colorScheme: colorScheme)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func startConversion() {
        guard let outputFolder = outputFolder else { return }
        isConverting = true
        isProcessing = true
        
        // Start conversion for first pending file
        Task {
            await convertNextFile(outputFolder: outputFolder)
        }
    }
    
    private func convertNextFile(outputFolder: URL) async {
        // Find first pending file
        guard let index = audioFiles.firstIndex(where: { $0.status == .pending }) else {
            await MainActor.run {
                isConverting = false
                isProcessing = false
                currentStep = .completed
            }
            return
        }
        
        // Update file status
        await MainActor.run {
            audioFiles[index].status = .converting
        }
        
        // Get input and output URLs
        let inputURL = audioFiles[index].url
        let proposedURL = outputFolder
            .appendingPathComponent(inputURL.deletingPathExtension().lastPathComponent + ".Mono")
            .appendingPathExtension(settings.fileType.fileExtension)
        let outputURL = resolveOutputURL(proposedURL)
        
        do {
            try await convertFile(at: index, from: inputURL, to: outputURL)
            
            await MainActor.run {
                audioFiles[index].status = .completed
                // Continue with next file
                Task {
                    await convertNextFile(outputFolder: outputFolder)
                }
            }
        } catch {
            await MainActor.run {
                audioFiles[index].status = .failed
                audioFiles[index].errorMessage = error.localizedDescription
                errorMessage = "Error converting \(inputURL.lastPathComponent): \(error.localizedDescription)"
                
                // Continue with next file despite error
                Task {
                    await convertNextFile(outputFolder: outputFolder)
                }
            }
        }
    }
    
    private func convertFile(at index: Int, from inputURL: URL, to outputURL: URL) async throws {
        // Access security-scoped resource if needed (for sandboxed environments)
        // This handles URLs from drag-and-drop that may be security-scoped
        let isAccessing = inputURL.startAccessingSecurityScopedResource()
        defer {
            if isAccessing {
                inputURL.stopAccessingSecurityScopedResource()
            }
        }
        
        try await convertAudioFile(
            inputURL: inputURL,
            outputURL: outputURL,
            settings: settings,
            updateProgress: { progress in
                Task { @MainActor in
                    audioFiles[index].progress = progress
                }
            }
        )
    }
    
    private func showInFinder() {
        guard let outputFolder = outputFolder else { return }
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: outputFolder.path)
    }
}

struct CompletionView: View {
    let audioFiles: [AudioFile]
    let outputFolder: URL?
    let onStartOver: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 30) {
            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50, weight: .ultraLight))
            
            // Stats
            VStack(spacing: 10) {
                Text("Conversion Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                
                let successful = audioFiles.filter { $0.status == .completed }.count
                let failed = audioFiles.filter { $0.status == .failed }.count
                
                Text("\(successful) files converted successfully")
                    .foregroundColor(AdaptiveColor.textSecondary(colorScheme))
                
                if failed > 0 {
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        Text("\(failed) files failed")
                            .foregroundColor(DesignTokens.Colors.Shared.error)
                            .fontWeight(.semibold)
                        
                        // Show error messages for failed files
                        ScrollView {
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                ForEach(audioFiles.filter { $0.status == .failed }) { file in
                                    if let errorMessage = file.errorMessage {
                                        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(DesignTokens.Colors.Shared.error)
                                                .font(.caption)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(file.url.lastPathComponent)
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(AdaptiveColor.textPrimary(colorScheme))
                                                Text(errorMessage)
                                                    .font(.caption2)
                                                    .foregroundColor(AdaptiveColor.textSecondary(colorScheme))
                                            }
                                        }
                                        .padding(.vertical, DesignTokens.Spacing.xs)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 150)
                    }
                    .padding(.top, DesignTokens.Spacing.sm)
                }
            }
            
            // Action buttons
            VStack(spacing: 15) {
                Button(action: {
                    guard let outputFolder = outputFolder else { return }
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: outputFolder.path)
                }) {
                    Label("Show in Finder", systemImage: "folder")
                        .frame(width: 200)
                }
                .applyProminentStyleAndTint(colorScheme: colorScheme)
                
                Button(action: onStartOver) {
                    Label("Convert More Files", systemImage: "arrow.clockwise")
                        .frame(width: 200)
                }
                .buttonStyle(.bordered)
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
    }
}

struct GitHubRelease: Codable {
    let tagName: String
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
    }
}

