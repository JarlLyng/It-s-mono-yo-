//
//  ItsMonoYoApp.swift
//  It's mono, yo!
//
//  Created by Jarl Lyng on 27/12/2024.
//

import SwiftUI

@main
struct ItsMonoYoApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationTitle("It's mono, yo!")
                .environmentObject(appState)
                // The completion step does not scroll: its inner ScrollView is
                // only the file list, capped at 150pt. Its natural height is
                // roughly 480pt, so below this floor the "Show in Finder" and
                // "Convert More Files" buttons are pushed out of reach and the
                // window has to be closed to start over (#66).
                // ideal* sets the initial window size; .defaultSize would be
                // the modern way to do it but needs macOS 13 and the floor is 12.
                .frame(minWidth: 700, idealWidth: 900,
                       minHeight: 560, idealHeight: 640)
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
