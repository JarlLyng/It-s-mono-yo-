//
//  Telemetry.swift
//  It's mono, yo!
//
//  Anonymous crash reports, crash-free sessions, MetricKit diagnostics and one
//  feature count, sent to Sentry (#114). Anonymous is a recipe, not Sentry's
//  default: out of the box sentry-cocoa sends a random installation ID as the
//  user, as every session's `did` and on every metric, plus a hash of the vendor
//  ID on every event. Everything here exists so that no ID leaves the Mac, and so
//  that nothing about the user's files does either: no file names, no paths, no
//  audio. TELEMETRY.md says what is sent.
//

import Foundation
import Sentry

enum Telemetry {
    /// The one user every install reports as.
    static let anonymousUser = "anonymous"

    /// The only attributes a metric may carry: the SDK's coarse facts (version,
    /// OS, device model) plus ours. Anything else, `user.id` included, is dropped.
    static let allowedMetricAttributes: Set<String> = [
        "sentry.sdk.name", "sentry.sdk.version", "sentry.environment", "sentry.release",
        "os.name", "os.version", "device.brand", "device.model", "device.family",
        "format",
    ]

    /// Starts Sentry if the build has a DSN. Not under XCTest or XCUITest, where
    /// it would only fill the project with test-harness noise.
    static func start() {
        let env = ProcessInfo.processInfo.environment
        if env["XCTestConfigurationFilePath"] != nil || env["XCTestSessionIdentifier"] != nil {
            return
        }

        guard let dsn = dsn(environment: env) else {
            #if DEBUG
            print("[Sentry] No DSN: put it in SampleDrumConverter/SentryDSN.txt (gitignored). Not in the scheme, which is shared and committed.")
            #endif
            return
        }

        let options = Options()
        options.dsn = dsn
        options.environment = environment
        #if DEBUG
        options.debug = true
        #endif
        options.sendDefaultPii = false
        // No performance tracing in any build: crash reports, crash-free sessions,
        // MetricKit and the one count are what the policy names. File I/O tracing
        // would also record the paths of the user's files.
        options.tracesSampleRate = 0
        options.enableFileIOTracing = false
        options.enableNetworkTracking = false
        options.enableAutoSessionTracking = true
        options.enableMetricKit = true
        options.beforeSend = { event in
            anonymize(event)
        }
        options.beforeBreadcrumb = { breadcrumb in
            scrub(breadcrumb)
        }
        options.beforeSendMetric = { metric in
            anonymize(metric)
        }

        // Sessions can't be given a user: sentry-cocoa sets every session's `did`
        // from the INSTALLATION file in its cache directory, and creates that file
        // with a random UUID when it's missing. Writing the shared user into it
        // before the SDK starts makes every install report the same `did`.
        // Checked against the outgoing session envelope with sentry-cocoa 9.32.0;
        // check again after every SDK upgrade (TELEMETRY.md).
        pinInstallationID(cacheDirectoryPath: options.cacheDirectoryPath)

        SentrySDK.start(options: options)
        // Before any event or metric, so nothing falls back to an installation ID.
        SentrySDK.setUser(User(userId: anonymousUser))

        #if DEBUG
        SentrySDK.capture(message: "It's mono, yo! – Sentry test (Debug build)")
        #endif
    }

    /// The DSN from SentryDSN.txt in the app bundle, which Xcode Cloud writes from
    /// its SENTRY_DSN secret (ci_scripts/ci_post_clone.sh), or from a SENTRY_DSN
    /// process variable for a one-off run (`open --env`). Never from git, and never
    /// from the scheme: it is shared, so its environment variables are committed.
    static func dsn(environment env: [String: String], bundle: Bundle = .main) -> String? {
        var raw = env["SENTRY_DSN"]
        if raw?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true,
           let url = bundle.url(forResource: "SentryDSN", withExtension: "txt") {
            raw = try? String(contentsOf: url, encoding: .utf8)
        }
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    // MARK: - The feature count

    /// A batch that finished with at least one file converted.
    static func conversionFinished(format: OutputFileType) {
        guard SentrySDK.isEnabled else { return }
        SentrySDK.metrics.count(
            "conversion.finished",
            value: 1,
            options: SentryMetricOptions(attributes: ["format": formatAttribute(format)])
        )
    }

    /// Fixed values only, never anything from the user's files.
    static func formatAttribute(_ format: OutputFileType) -> String {
        switch format {
        case .wav: "wav"
        case .aiff: "aiff"
        }
    }

    // MARK: - Anonymizing

    /// `production` only for App Store builds, so debug and local builds aren't
    /// read as real crashes. An App Store build always carries a receipt; a
    /// TestFlight build's is a sandbox receipt.
    static var environment: String {
        #if DEBUG
        return "debug"
        #else
        guard let receipt = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: receipt.path) else {
            return "development"
        }
        return receipt.lastPathComponent == "sandboxReceipt" ? "testflight" : "production"
        #endif
    }

    /// Covers errors, crashes, app hangs and MetricKit diagnostics: one shared
    /// user, and no device ID or vendor-ID hash.
    static func anonymize(_ event: Event) -> Event {
        event.user = User(userId: anonymousUser)
        if var context = event.context {
            context["app"]?.removeValue(forKey: "device_app_hash")
            context["device"]?.removeValue(forKey: "id")
            event.context = context
        }
        return event
    }

    static func anonymize(_ metric: SentryMetric) -> SentryMetric {
        var metric = metric
        metric.attributes = metric.attributes.filter { allowedMetricAttributes.contains($0.key) }
        return metric
    }

    /// Breadcrumbs keep their category and type, never their data, and lose a
    /// message that names a file or a path.
    static func scrub(_ breadcrumb: Breadcrumb) -> Breadcrumb {
        breadcrumb.data = nil
        if let message = breadcrumb.message,
           message.contains("/") || message.contains("file:") {
            breadcrumb.message = nil
        }
        return breadcrumb
    }

    static func pinInstallationID(cacheDirectoryPath: String) {
        let directory = URL(fileURLWithPath: cacheDirectoryPath)
        let url = directory.appendingPathComponent("INSTALLATION")
        let pinned = Data(anonymousUser.utf8)
        guard (try? Data(contentsOf: url)) != pinned else { return }
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try? pinned.write(to: url, options: .atomic)
    }
}
