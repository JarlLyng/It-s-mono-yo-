//
//  TelemetryTests.swift
//  It's mono, yo!
//
//  The anonymous recipe for Sentry (#114): nothing that identifies an install or
//  names a file may leave the Mac.
//

import XCTest
// SPI only for SentryMetric's initializer, to build a metric the way the SDK does.
@_spi(Private) import Sentry
@testable import It_s_mono__yo_

final class TelemetryTests: XCTestCase {

    func testEventsCarryOnlyTheSharedUserAndNoDeviceIDs() {
        let event = Event()
        event.user = User(userId: "4F1C2A9E-installation-id")
        event.context = [
            "app": ["device_app_hash": "a1b2c3", "app_version": "1.4.6"],
            "device": ["id": "device-id", "model": "Mac14,2"],
        ]

        let out = Telemetry.anonymize(event)

        XCTAssertEqual(out.user?.userId, "anonymous")
        XCTAssertNil(out.context?["app"]?["device_app_hash"])
        XCTAssertNil(out.context?["device"]?["id"])
        // Coarse facts stay.
        XCTAssertEqual(out.context?["app"]?["app_version"] as? String, "1.4.6")
        XCTAssertEqual(out.context?["device"]?["model"] as? String, "Mac14,2")
    }

    func testTheAccountNameIsRedactedFromPathsAndTheRestKept() {
        let appPath = "/Users/someone/Downloads/It's mono, yo!.app/Contents/MacOS/It's mono, yo!"
        XCTAssertEqual(Telemetry.redactAccountName(appPath),
                       "/Users/<user>/Downloads/It's mono, yo!.app/Contents/MacOS/It's mono, yo!")
        // Paths outside a home folder are left alone.
        let system = "/System/Library/Frameworks/AppKit.framework/Versions/C/AppKit"
        XCTAssertEqual(Telemetry.redactAccountName(system), system)
        XCTAssertEqual(Telemetry.redactAccountName("/Applications/It's mono, yo!.app"), "/Applications/It's mono, yo!.app")

        let frame = Frame()
        frame.package = appPath
        let thread = SentryThread(threadId: 1)
        thread.stacktrace = SentryStacktrace(frames: [frame], registers: [:])
        let image = DebugMeta()
        image.codeFile = appPath
        let event = Event()
        event.threads = [thread]
        event.debugMeta = [image]

        let out = Telemetry.anonymize(event)

        XCTAssertEqual(out.threads?.first?.stacktrace?.frames.first?.package,
                       "/Users/<user>/Downloads/It's mono, yo!.app/Contents/MacOS/It's mono, yo!")
        XCTAssertEqual(out.debugMeta?.first?.codeFile,
                       "/Users/<user>/Downloads/It's mono, yo!.app/Contents/MacOS/It's mono, yo!")
    }

    func testMetricsKeepOnlyTheAllowedAttributes() {
        var metric = SentryMetric(
            timestamp: Date(),
            traceId: SentryId(),
            name: "conversion.finished",
            value: .counter(1),
            unit: nil,
            attributes: [
                "format": .string("wav"),
                "user.id": .string("4F1C2A9E-installation-id"),
                "file.name": .string("Kick 01.wav"),
                "os.version": .string("26.1"),
            ]
        )
        metric = Telemetry.anonymize(metric)

        XCTAssertEqual(Set(metric.attributes.keys), ["format", "os.version"])
    }

    func testTheFormatAttributeIsAFixedValue() {
        XCTAssertEqual(Telemetry.formatAttribute(.wav), "wav")
        XCTAssertEqual(Telemetry.formatAttribute(.aiff), "aiff")
    }

    func testBreadcrumbsLoseTheirDataAndAnyPath() {
        let crumb = Breadcrumb(level: .info, category: "file")
        crumb.message = "Opened /Users/someone/Samples/Kick 01.wav"
        crumb.data = ["path": "/Users/someone/Samples/Kick 01.wav"]

        let out = Telemetry.scrub(crumb)

        XCTAssertNil(out.data)
        XCTAssertNil(out.message)
        XCTAssertEqual(out.category, "file")

        let plain = Breadcrumb(level: .info, category: "app.lifecycle")
        plain.message = "Window closed"
        XCTAssertEqual(Telemetry.scrub(plain).message, "Window closed")
    }

    func testTheInstallationIDIsPinnedToTheSharedUser() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("sentry-cache-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: dir) }
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("INSTALLATION")
        try Data("9D2B6E3A-old-random-id".utf8).write(to: file)

        Telemetry.pinInstallationID(cacheDirectoryPath: dir.path)

        XCTAssertEqual(try String(contentsOf: file, encoding: .utf8), "anonymous")
    }

    func testTheDSNComesFromTheEnvironmentAndNeverDefaultsToSomething() {
        XCTAssertEqual(Telemetry.dsn(environment: ["SENTRY_DSN": "  https://key@example.invalid/1 \n"],
                                     bundle: Bundle(for: Self.self)),
                       "https://key@example.invalid/1")
        XCTAssertNil(Telemetry.dsn(environment: ["SENTRY_DSN": "   "], bundle: Bundle(for: Self.self)))
        XCTAssertNil(Telemetry.dsn(environment: [:], bundle: Bundle(for: Self.self)))
    }
}
