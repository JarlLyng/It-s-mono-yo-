import SwiftUI

// MARK: - Adaptive Animation

/// A view modifier that respects the system's Reduce Motion accessibility setting.
/// When Reduce Motion is enabled, animations are suppressed.
struct AdaptiveAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation?
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: value)
    }
}

extension View {
    /// Applies animation only when Reduce Motion is not enabled.
    func adaptiveAnimation<V: Equatable>(_ animation: Animation?, value: V) -> some View {
        self.modifier(AdaptiveAnimationModifier(animation: animation, value: value))
    }
}

// MARK: - Adaptive withAnimation replacement

/// Returns whether the system Reduce Motion setting is enabled.
func shouldReduceMotion() -> Bool {
    return NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
}

/// Performs a state change with animation, unless Reduce Motion is enabled.
func adaptiveWithAnimation<Result>(_ animation: Animation? = .default, _ body: () throws -> Result) rethrows -> Result {
    if shouldReduceMotion() {
        return try body()
    } else {
        return try withAnimation(animation, body)
    }
}
