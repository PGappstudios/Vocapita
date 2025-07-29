import SwiftUI
import SwiftData

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @State private var showingRecordingView = false
    
    var body: some View {
        ZStack {
            TabView(selection: $appState.selectedTab) {
                // Home Tab
                WelcomeView()
                    .tabItem {
                        CustomTabIcon(
                            systemName: "house", 
                            isSelected: appState.selectedTab == 0,
                            color: appState.primaryColor
                        )
                        Text("Home")
                    }
                    .tag(0)
                
                // Record Tab
                RecordingTabView()
                    .tabItem {
                        CustomTabIcon(
                            systemName: "mic.circle", 
                            isSelected: appState.selectedTab == 1,
                            color: appState.primaryColor
                        )
                        Text("Record")
                    }
                    .tag(1)
                
                // History Tab
                HistoryTabView()
                    .tabItem {
                        CustomTabIcon(
                            systemName: "clock", 
                            isSelected: appState.selectedTab == 2,
                            color: appState.primaryColor
                        )
                        Text("History")
                    }
                    .tag(2)
                
                // Settings Tab
                SettingsView()
                    .tabItem {
                        CustomTabIcon(
                            systemName: "gear", 
                            isSelected: appState.selectedTab == 3,
                            color: appState.primaryColor
                        )
                        Text("Settings")
                    }
                    .tag(3)
            }
            .accentColor(appState.primaryColor)
            .preferredColorScheme(appState.currentTheme.colorScheme)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.selectedTab)
            .onChange(of: appState.selectedTab) { _, newValue in
                // Add haptic feedback for tab changes
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingRecordButton {
                        showingRecordingView = true
                    }
                    .environmentObject(appState)
                    .padding(.trailing, 20)
                    .padding(.bottom, 90) // Above tab bar
                }
            }
        }
        .sheet(isPresented: $showingRecordingView) {
            RecordingTabView()
                .environmentObject(appState)
        }
    }
}

struct CustomTabIcon: View {
    let systemName: String
    let isSelected: Bool
    let color: Color
    
    var body: some View {
        Image(systemName: isSelected ? systemName + ".fill" : systemName)
            .font(.system(size: 24, weight: isSelected ? .semibold : .medium))
            .foregroundColor(isSelected ? color : .secondary)
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct FloatingRecordButton: View {
    let action: () -> Void
    @EnvironmentObject var appState: AppState
    @State private var isPressed = false
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action()
        }) {
            ZStack {
                // Pulsing rings
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(appState.primaryColor.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                        .frame(width: 60 + CGFloat(index * 10), height: 60 + CGFloat(index * 10))
                        .scaleEffect(isPulsing ? 1.0 + Double(index) * 0.1 : 1.0)
                        .opacity(isPulsing ? 0.8 - Double(index) * 0.2 : 0.4)
                        .animation(
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.3),
                            value: isPulsing
                        )
                }
                
                // Main button
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [appState.primaryColor, appState.secondaryColor]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                    )
                    .overlay(
                        Circle()
                            .stroke(.linearGradient(
                                colors: [.white.opacity(0.4), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 2)
                            .frame(width: 50, height: 50)
                    )
                
                // Mic icon
                Image(systemName: "mic.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .white.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: appState.primaryColor.opacity(0.4), radius: 12, x: 0, y: 6)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            isPulsing = true
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .modelContainer(for: VoiceRecording.self, inMemory: true)
}