//
//  ReviewPrompt.swift
//  It's mono, yo!
//
//  Manages when to show the macOS App Store review prompt using
//  SKStoreReviewController. Apple limits this to ~3 prompts per year
//  per user, so we only request it after meaningful success.
//

import StoreKit
import AppKit

enum ReviewPrompt {
    // Keys used in UserDefaults
    private static let successfulConversionsKey = "ItsMonoYo.successfulConversionCount"
    private static let lastPromptVersionKey = "ItsMonoYo.lastPromptedAppVersion"

    // Show the prompt after this many successful batch conversions.
    // 3 hits the sweet spot: user has clearly found the app useful,
    // but we're not pestering them on first use.
    private static let promptAfterSuccessfulConversions = 3

    /// Call this when a batch conversion finishes successfully.
    /// "Successfully" means at least one file converted without errors.
    static func recordSuccessfulConversion() {
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: successfulConversionsKey) + 1
        defaults.set(count, forKey: successfulConversionsKey)

        guard count >= promptAfterSuccessfulConversions else { return }

        // Don't prompt twice for the same app version. StoreKit also
        // enforces its own rate limits (max 3 prompts per 365 days).
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let lastPromptedVersion = defaults.string(forKey: lastPromptVersionKey) ?? ""
        guard currentVersion != lastPromptedVersion else { return }

        // Slight delay so the user sees the success screen first.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            requestReview()
            defaults.set(currentVersion, forKey: lastPromptVersionKey)
        }
    }

    /// Request the system review prompt. Apple may choose not to display
    /// it (rate limiting, opt-out in Settings, etc.) — that's expected.
    private static func requestReview() {
        SKStoreReviewController.requestReview()
    }
}
