//
//  AppDelegate.swift
//  It's mono, yo!
//
//  The app has one window, and closing it quits the app (#101). App Review
//  turned down 1.4.6 because a closed window could not be brought back from the
//  menus. Quitting on close is the route Apple names for single-window apps; a
//  `Window` scene, which lists itself in the Window menu, needs macOS 13.
//
//  A batch keeps converting when its window closes, so quitting in the middle of
//  one would cut it off and leave unfinished files in the output folder. While a
//  batch runs, closing the window or quitting asks first.
//

import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()
    private lazy var closeGuard = WindowCloseGuard(appState: appState)

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard appState.isConverting else { return .terminateNow }

        let alert = NSAlert()
        alert.messageText = "Stop converting and quit?"
        alert.informativeText = "The files being converted now will be left unfinished, and the rest won't be converted."
        alert.addButton(withTitle: "Keep Converting")
        alert.addButton(withTitle: "Quit").hasDestructiveAction = true
        return alert.runModal() == .alertSecondButtonReturn ? .terminateNow : .terminateCancel
    }

    func guardClosing(of window: NSWindow) {
        closeGuard.install(on: window)
    }
}

/// Stands in front of SwiftUI's own window delegate and passes everything on to
/// it, except a close during a batch: that becomes a quit, so the question above
/// is asked while the window is still open, and it stays open if the user keeps
/// converting. SwiftUI on macOS 12 has no way to stop a window from closing.
final class WindowCloseGuard: NSObject, NSWindowDelegate {
    private let appState: AppState
    private weak var swiftUIDelegate: NSWindowDelegate?

    init(appState: AppState) {
        self.appState = appState
    }

    func install(on window: NSWindow) {
        guard window.delegate !== self else { return }
        swiftUIDelegate = window.delegate
        window.delegate = self
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if appState.isConverting {
            DispatchQueue.main.async { NSApp.terminate(nil) }
            return false
        }
        return swiftUIDelegate?.windowShouldClose?(sender) ?? true
    }

    override func responds(to aSelector: Selector!) -> Bool {
        super.responds(to: aSelector) || swiftUIDelegate?.responds(to: aSelector) == true
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        swiftUIDelegate
    }
}

/// Hands over the window the view is placed in, once SwiftUI has set it up.
struct WindowReader: NSViewRepresentable {
    let onWindow: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        ReaderView(onWindow: onWindow)
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    private final class ReaderView: NSView {
        let onWindow: (NSWindow) -> Void

        init(onWindow: @escaping (NSWindow) -> Void) {
            self.onWindow = onWindow
            super.init(frame: .zero)
        }

        required init?(coder: NSCoder) { nil }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            guard let window = window else { return }
            DispatchQueue.main.async { [onWindow] in onWindow(window) }
        }
    }
}
