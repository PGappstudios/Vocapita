import Foundation
import SwiftUI

enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    
    var iconName: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "gear"
        }
    }
}

class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var currentTheme: AppTheme = .system
    @Published var hasCompletedOnboarding: Bool = false
    @Published var showingOnboarding: Bool = false
    
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private let currentThemeKey = "currentTheme"
    
    init() {
        loadUserPreferences()
        checkOnboardingStatus()
    }
    
    // MARK: - Onboarding Management
    
    private func checkOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        showingOnboarding = !hasCompletedOnboarding
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        showingOnboarding = false
        UserDefaults.standard.set(true, forKey: hasCompletedOnboardingKey)
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        showingOnboarding = true
        UserDefaults.standard.set(false, forKey: hasCompletedOnboardingKey)
    }
    
    // MARK: - Theme Management
    
    func setTheme(_ theme: AppTheme) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentTheme = theme
        }
        UserDefaults.standard.set(theme.rawValue, forKey: currentThemeKey)
    }
    
    private func loadUserPreferences() {
        // Load theme preference
        if let themeString = UserDefaults.standard.string(forKey: currentThemeKey),
           let theme = AppTheme(rawValue: themeString) {
            currentTheme = theme
        }
    }
    
    // MARK: - Tab Management
    
    func selectTab(_ tabIndex: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedTab = tabIndex
        }
    }
    
    // MARK: - App Statistics
    
    func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    func getBuildNumber() -> String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - App Colors and Styling

extension AppState {
    var primaryColor: Color {
        switch currentTheme {
        case .light: return .blue
        case .dark: return Color(red: 0.4, green: 0.7, blue: 1.0)
        case .system: return .blue
        }
    }
    
    var secondaryColor: Color {
        switch currentTheme {
        case .light: return .purple
        case .dark: return Color(red: 0.8, green: 0.4, blue: 1.0)
        case .system: return .purple
        }
    }
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                primaryColor.opacity(0.1),
                secondaryColor.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}