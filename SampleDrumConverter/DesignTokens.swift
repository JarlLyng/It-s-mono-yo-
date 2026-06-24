//
//  DesignTokens.swift
//  It's mono, yo!
//
//  Re-exports the shared IAMJARL design tokens (SPM package) and adds the
//  app-specific, scheme-aware accessors the views use. Replaces the former
//  local token copy so there is a single source of truth across the portfolio.
//  Package: https://github.com/JarlLyng/iamjarl-design
//

import SwiftUI
@_exported import IAMJARLDesignTokens

// MARK: - App-specific convenience

extension ColorScheme {
    var isDark: Bool { self == .dark }
}

// The views reference `DesignTokens.Colors.Shared.*`; the package exposes the
// same flat state colors under `ColorToken.State`. Bridge them so the existing
// call sites compile unchanged (identical values).
extension DesignTokens {
    enum Colors {
        enum Shared {
            static let success = DesignTokens.ColorToken.State.success
            static let onSuccess = DesignTokens.ColorToken.State.onSuccess
            static let warning = DesignTokens.ColorToken.State.warning
            static let onWarning = DesignTokens.ColorToken.State.onWarning
            static let error = DesignTokens.ColorToken.State.error
            static let onError = DesignTokens.ColorToken.State.onError
        }
    }
}

// MARK: - Scheme-aware color accessors (backed by the shared package)

enum AdaptiveColor {
    static func primary(_ s: ColorScheme) -> Color { DesignTokens.Common.primary(s) }
    static func onPrimary(_ s: ColorScheme) -> Color { DesignTokens.Common.OnPrimary.text(s) }
    static func textPrimary(_ s: ColorScheme) -> Color { DesignTokens.Common.Text.primary(s) }
    static func textSecondary(_ s: ColorScheme) -> Color { DesignTokens.Common.Text.secondary(s) }
    static func textTertiary(_ s: ColorScheme) -> Color { DesignTokens.Common.Text.tertiary(s) }
    static func textInverse(_ s: ColorScheme) -> Color { DesignTokens.Common.Text.inverse(s) }
    static func backgroundApp(_ s: ColorScheme) -> Color { DesignTokens.Common.Background.app(s) }
    static func backgroundMuted(_ s: ColorScheme) -> Color { DesignTokens.Common.Background.muted(s) }
    static func backgroundCard(_ s: ColorScheme) -> Color { DesignTokens.Common.Background.card(s) }
    static func borderSubtle(_ s: ColorScheme) -> Color { DesignTokens.Common.Border.subtle(s) }
    static func borderDefault(_ s: ColorScheme) -> Color { DesignTokens.Common.Border.`default`(s) }
}
