//
//  DesignTokens.swift
//  SampleDrumConverter
//
//  IAMJARL Design System Tokens
//  Source: https://jarllyng.github.io/iamjarl-design/tokens.json
//

import SwiftUI

// MARK: - Design Tokens

struct DesignTokens {
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }
    
    // MARK: - Radius
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
    }
    
    // MARK: - Typography
    struct Typography {
        struct Size {
            static let xs: CGFloat = 12
            static let sm: CGFloat = 14
            static let base: CGFloat = 16
            static let lg: CGFloat = 18
            static let xl: CGFloat = 24
            static let xxl: CGFloat = 36
        }
        
        struct Weight {
            static let regular: Font.Weight = .regular
            static let semibold: Font.Weight = .semibold
            static let bold: Font.Weight = .bold
        }
        
        struct LineHeight {
            static let tight: CGFloat = 20
            static let normal: CGFloat = 24
            static let relaxed: CGFloat = 28
            static let sm: CGFloat = 18
            static let xxl: CGFloat = 43.2
        }
    }
    
    // MARK: - Colors
    struct Colors {
        // Static colors
        struct Static {
            static let black = Color(hex: "000000")
            static let white = Color(hex: "FFFFFF")
        }
        
        // Shared state colors
        struct Shared {
            static let success = Color(hex: "4CAF50")
            static let warning = Color(hex: "FF6B35")
            static let error = Color(hex: "FF3B30")
        }
        
        // Mode-specific colors
        struct Light {
            static let primary = Color(hex: "00FF7B")
            
            struct Text {
                static let primary = Color(hex: "000000")
                static let secondary = Color(hex: "000000").opacity(0.70)
                static let tertiary = Color(hex: "000000").opacity(0.55)
                static let inverse = Color(hex: "FFFFFF")
            }
            
            struct Background {
                static let app = Color(hex: "FFFFFF")
                static let muted = Color(hex: "000000").opacity(0.04)
                static let card = Color(hex: "000000").opacity(0.04)
            }
            
            struct Surface {
                static let `default` = Color(hex: "FFFFFF")
                static let raised = Color(hex: "000000").opacity(0.02)
            }
            
            struct Border {
                static let subtle = Color(hex: "000000").opacity(0.10)
                static let `default` = Color(hex: "000000").opacity(0.16)
            }
        }
        
        struct Dark {
            static let primary = Color(hex: "D0FF00")
            
            struct Text {
                static let primary = Color(hex: "FFFFFF")
                static let secondary = Color(hex: "FFFFFF").opacity(0.75)
                static let tertiary = Color(hex: "FFFFFF").opacity(0.60)
                static let inverse = Color(hex: "000000")
            }
            
            struct Background {
                static let app = Color(hex: "000000")
                static let muted = Color(hex: "FFFFFF").opacity(0.05)
                static let card = Color(hex: "FFFFFF").opacity(0.05)
            }
            
            struct Surface {
                static let `default` = Color(hex: "000000")
                static let raised = Color(hex: "FFFFFF").opacity(0.03)
            }
            
            struct Border {
                static let subtle = Color(hex: "FFFFFF").opacity(0.12)
                static let `default` = Color(hex: "FFFFFF").opacity(0.18)
            }
        }
    }
}

// MARK: - Environment-aware color helpers

extension ColorScheme {
    var isDark: Bool {
        self == .dark
    }
}

// Removed adaptiveColor extension - use AdaptiveColor helper functions instead

// MARK: - Color Scheme Helper

struct AdaptiveColor {
    static func primary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? DesignTokens.Colors.Dark.primary : DesignTokens.Colors.Light.primary
    }
    
    static func textPrimary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? DesignTokens.Colors.Dark.Text.primary : DesignTokens.Colors.Light.Text.primary
    }
    
    static func textSecondary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? DesignTokens.Colors.Dark.Text.secondary : DesignTokens.Colors.Light.Text.secondary
    }
    
    static func textTertiary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? DesignTokens.Colors.Dark.Text.tertiary : DesignTokens.Colors.Light.Text.tertiary
    }
    
    static func textInverse(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? DesignTokens.Colors.Dark.Text.inverse : DesignTokens.Colors.Light.Text.inverse
    }
    
    static func backgroundApp(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? DesignTokens.Colors.Dark.Background.app : DesignTokens.Colors.Light.Background.app
    }
    
    static func backgroundMuted(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? DesignTokens.Colors.Dark.Background.muted : DesignTokens.Colors.Light.Background.muted
    }
    
    static func backgroundCard(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? DesignTokens.Colors.Dark.Background.card : DesignTokens.Colors.Light.Background.card
    }
    
    static func surfaceDefault(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? DesignTokens.Colors.Dark.Surface.default : DesignTokens.Colors.Light.Surface.default
    }
    
    static func surfaceRaised(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? DesignTokens.Colors.Dark.Surface.raised : DesignTokens.Colors.Light.Surface.raised
    }
    
    static func borderSubtle(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? DesignTokens.Colors.Dark.Border.subtle : DesignTokens.Colors.Light.Border.subtle
    }
    
    static func borderDefault(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? DesignTokens.Colors.Dark.Border.default : DesignTokens.Colors.Light.Border.default
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
