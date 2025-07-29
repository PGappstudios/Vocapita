//
//  VocapitaApp.swift
//  Vocapita
//
//  Created by Pedro Gregorio on 23/07/2025.
//

import SwiftUI
import SwiftData

@main
struct VocapitaApp: App {
    @StateObject private var appState = AppState()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            VoiceRecording.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.showingOnboarding {
                    OnboardingView()
                        .environmentObject(appState)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                } else {
                    MainTabView()
                        .environmentObject(appState)
                        .preferredColorScheme(appState.currentTheme.colorScheme)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                }
            }
            .animation(.easeInOut(duration: 0.5), value: appState.showingOnboarding)
        }
        .modelContainer(sharedModelContainer)
    }
}
