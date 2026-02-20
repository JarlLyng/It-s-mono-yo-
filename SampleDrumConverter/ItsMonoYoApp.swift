//
//  ItsMonoYoApp.swift
//  It's mono, yo!
//
//  Created by Jarl Lyng on 27/12/2024.
//

import SwiftUI
import AppKit

/// AppDelegate for App Store Guideline 4 (Design): quit when main window is closed.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

@main
struct ItsMonoYoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationTitle("It's mono, yo!")
                .environmentObject(appState)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Files...") {
                    appState.openFiles()
                }
                .keyboardShortcut("o", modifiers: .command)
            }
        }
    }
}

class AppState: ObservableObject {
    func openFiles() {
        NotificationCenter.default.post(name: NSNotification.Name("OpenFiles"), object: nil)
    }
}
