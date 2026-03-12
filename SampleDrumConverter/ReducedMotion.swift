import SwiftUI

// MARK: - Adaptive Animation

/// A view modifier that respects the system's Reduce Motion accessibility setting.
/// When Reduce Motion is enabled, animations are suppressed.
struct AdaptiveAnimationModifier<V: Equatable>: ViewModifier {
    let animation: Animation?
    let value: V

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(macOS 12.0, *) {
            AdaptiveAnimationContent(animation: animation, value: value) {
                content
            }
        } else {
            // macOS 11 fallback: check directly
            let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
            content.animation(reduceMotion ? nil : animation, value: value)
        }
    }
}

/// Helper view that uses @Environment for macOS 12+
@available(macOS 12.0, *)
private struct AdaptiveAnimationContent<V: Equatable, C: View>: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation?
    let value: V
    @ViewBuilder let content: () -> C

    var body: some View {
        content()
            .animation(reduceMotion ? nil : animation, value: value)
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
/// Works on macOS 11+.
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
