import SwiftUI
import SwiftData

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VoiceRecording.timestamp, order: .reverse) private var recordings: [VoiceRecording]
    
    @State private var currentTime = Date()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Quick Stats
                    statsSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Recent Recordings Preview
                    if !recordings.isEmpty {
                        recentRecordingsSection
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .background(appState.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Welcome")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .onReceive(timer) { _ in
                currentTime = Date()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Ready to create amazing content?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // App Logo/Icon
                ZStack {
                    Circle()
                        .fill(appState.primaryColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(appState.primaryColor)
                }
            }
            
            Divider()
                .padding(.top, 8)
        }
    }
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Stats")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 12) {
                StatsCard(
                    title: "\(recordings.count)",
                    subtitle: "Recordings",
                    icon: "waveform",
                    color: appState.primaryColor
                )
                
                StatsCard(
                    title: formatTotalDuration(),
                    subtitle: "Total Time",
                    icon: "clock",
                    color: .green
                )
                
                StatsCard(
                    title: "\(totalWords())",
                    subtitle: "Words",
                    icon: "textformat",
                    color: .orange
                )
            }
        }
        .padding(.vertical, 8)
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Quick Actions")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Start Recording Button
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    appState.selectTab(1) // Switch to Record tab
                }) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "mic.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start Recording")
                                .font(.system(size: 19, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Record your voice in any language")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(24)
                    .background(
                        ZStack {
                            // Base gradient
                            LinearGradient(
                                gradient: Gradient(colors: [appState.primaryColor, appState.secondaryColor]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            
                            // Shimmer overlay
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .clear,
                                    .white.opacity(0.15),
                                    .clear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .rotationEffect(.degrees(45))
                        }
                    )
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: appState.primaryColor.opacity(0.4), radius: 16, x: 0, y: 8)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                // View History Button
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    appState.selectTab(2) // Switch to History tab
                }) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(appState.primaryColor.opacity(0.15))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "clock.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(appState.primaryColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("View History")
                                .font(.system(size: 19, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Browse your saved recordings")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.3),
                                        .clear,
                                        appState.primaryColor.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                }
            }
        }
    }
    
    private var recentRecordingsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Recordings")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("View All") {
                    appState.selectTab(2) // Switch to History tab
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(appState.primaryColor)
            }
            
            VStack(spacing: 8) {
                ForEach(Array(recordings.prefix(3)), id: \.id) { recording in
                    RecentRecordingRow(recording: recording)
                }
            }
        }
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: currentTime)
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    private func formatTotalDuration() -> String {
        let totalSeconds = recordings.reduce(0) { $0 + $1.duration }
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func totalWords() -> Int {
        return recordings.reduce(0) { total, recording in
            total + recording.transcription.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        }
    }
}

struct StatsCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            // Enhanced icon with background
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.8)
            
            Text(subtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.3),
                            .clear,
                            color.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct RecentRecordingRow: View {
    let recording: VoiceRecording
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced play button
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }) {
                ZStack {
                    Circle()
                        .fill(appState.primaryColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(appState.primaryColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(recording.transcription.prefix(60) + (recording.transcription.count > 60 ? "..." : ""))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Text(formatDate(recording.timestamp))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Circle()
                        .fill(.secondary)
                        .frame(width: 3, height: 3)
                    
                    Text(formatDuration(recording.duration))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.2),
                            .clear,
                            appState.primaryColor.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AppState())
        .modelContainer(for: VoiceRecording.self, inMemory: true)
}