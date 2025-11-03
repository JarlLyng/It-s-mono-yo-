//
//  SampleDrumConverterApp.swift
//  SampleDrumConverter
//
//  Created by Jarl Lyng on 27/12/2024.
//

import SwiftUI

@main
struct SampleDrumConverterApp: App {
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
