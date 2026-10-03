//
//  Feedback.swift
//  It's mono, yo!
//
//  The app collects no usage data, so what users choose to say is the only way
//  to learn how it is used. This opens a prefilled email in the user's own mail
//  client. Nothing is sent by the app itself, and the user sees everything that
//  was filled in before deciding whether to send it (#79).
//

import AppKit

enum Feedback {
    static let address = "support@iamjarl.com"

    /// Builds the mailto URL. Pure, so the encoding can be tested.
    static func mailtoURL(appVersion: String, build: String, systemVersion: String) -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = address
        components.queryItems = [
            URLQueryItem(name: "subject", value: "It's mono, yo! \(appVersion) feedback"),
            URLQueryItem(name: "body", value: "\n\n\n---\nIt's mono, yo! \(appVersion) (\(build))\nmacOS \(systemVersion)\n"),
        ]
        return components.url
    }

    /// Opens the prefilled email for the running app and system.
    static func compose() {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "unknown"
        let build = info?["CFBundleVersion"] as? String ?? "unknown"
        let system = ProcessInfo.processInfo.operatingSystemVersionString

        if let url = mailtoURL(appVersion: version, build: build, systemVersion: system) {
            NSWorkspace.shared.open(url)
        }
    }
}
