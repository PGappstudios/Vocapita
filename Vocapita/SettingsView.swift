import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query private var recordings: [VoiceRecording]
    
    @State private var showingDeleteAllAlert = false
    @State private var showingOnboardingResetAlert = false
    @State private var showingTermsAndPolicies = false
    
    var body: some View {
        NavigationStack {
            List {
                // Theme Section
                themeSection
                
                // App Preferences
                appPreferencesSection
                
                // Data Management
                dataManagementSection
                
                // About Section
                aboutSection
            }
            .listStyle(InsetGroupedListStyle())
            .background(appState.backgroundGradient.ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .sheet(isPresented: $showingTermsAndPolicies) {
                TermsAndPoliciesView()
            }
            .alert("Delete All Recordings", isPresented: $showingDeleteAllAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete All", role: .destructive) {
                    deleteAllRecordings()
                }
            } message: {
                Text("This will permanently delete all \(recordings.count) recordings. This action cannot be undone.")
            }
            .alert("Reset Onboarding", isPresented: $showingOnboardingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    appState.resetOnboarding()
                }
            } message: {
                Text("This will show the onboarding screens again when you restart the app.")
            }
        }
    }
    
    private var themeSection: some View {
        Section {
            VStack(spacing: 20) {
                // Section Header
                HStack {
                    Image(systemName: "paintbrush.fill")
                        .font(.title2)
                        .foregroundColor(appState.primaryColor)
                    
                    Text("Appearance")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                // Theme Options Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 16) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        themeCardButton(for: theme)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .listRowBackground(Color(.systemBackground).opacity(0.8))
        .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
    }
    
    private var appPreferencesSection: some View {
        Section("App Preferences") {
            // Reset Onboarding
            Button(action: {
                showingOnboardingResetAlert = true
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Reset Onboarding")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
            .padding(.vertical, 4)
        }
        .listRowBackground(Color(.systemBackground).opacity(0.8))
    }
    
    private var dataManagementSection: some View {
        Section("Data Management") {
            // Recordings count
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Saved Recordings")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("\(recordings.count) recordings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
            
            // Export All Data
            Button(action: exportAllData) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Export All Data")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
            .padding(.vertical, 4)
            
            // Delete All Data
            if !recordings.isEmpty {
                Button(action: {
                    showingDeleteAllAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text("Delete All Recordings")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listRowBackground(Color(.systemBackground).opacity(0.8))
    }
    
    private var aboutSection: some View {
        Section("About") {
            // App Version
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Version")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("v\(appState.getAppVersion()) (\(appState.getBuildNumber()))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
            
            // Developer Info
            HStack {
                Image(systemName: "building.2.fill")
                    .foregroundColor(.purple)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Developer")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("PG APP STUDIOS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
            
            // Made with Love
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Made with")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("💖 Love & SwiftUI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
            
            // Terms & Policies
            Button(action: {
                showingTermsAndPolicies = true
            }) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    
                    Text("Terms & Policies")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .listRowBackground(Color(.systemBackground).opacity(0.8))
    }
    
    
    private func deleteAllRecordings() {
        withAnimation {
            for recording in recordings {
                modelContext.delete(recording)
            }
            try? modelContext.save()
        }
    }
    
    private func exportAllData() {
        let allData = recordings.map { recording in
            """
            Date: \(formatDate(recording.timestamp))
            Duration: \(formatDuration(recording.duration))
            Transcription: \(recording.transcription)
            ---
            """
        }.joined(separator: "\n")
        
        let exportText = """
        Vocapita Export
        Generated: \(formatDate(Date()))
        Total Recordings: \(recordings.count)
        
        \(allData)
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [exportText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func themeCardButton(for theme: AppTheme) -> some View {
        let themeColor: Color = theme == .light ? .orange : theme == .dark ? .purple : appState.primaryColor
        
        return Button(action: {
            withAnimation(.bouncy(duration: 0.6)) {
                appState.setTheme(theme)
            }
        }) {
            VStack(spacing: 8) {
                // Theme Icon
                ZStack {
                    Circle()
                        .fill(themeColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: theme.iconName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(themeColor)
                }
                
                // Theme Name
                Text(theme.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Selection Indicator
                Circle()
                    .fill(appState.currentTheme == theme ? themeColor : Color.clear)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(themeColor.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(appState.currentTheme == theme ? themeColor : .clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .scaleEffect(appState.currentTheme == theme ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TermsAndPoliciesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Terms & Policies")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Last updated: \(getCurrentDate())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                    
                    // Terms of Service
                    termsSection
                    
                    // Privacy Policy
                    privacySection
                    
                    // Refund Policy
                    refundSection
                    
                    // Contact
                    contactSection
                }
                .padding(20)
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea())
            .navigationTitle("Terms & Policies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.linearGradient(
                                colors: [.white.opacity(0.3), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
            }
        }
    }
    
    private var termsSection: some View {
        PolicySection(
            title: "Terms of Service",
            icon: "checkmark.seal.fill",
            color: .green,
            content: """
            By using Vocapita, you agree to the following terms:
            
            • You may use this app for personal and commercial purposes
            • You are responsible for the content you record and generate
            • We reserve the right to update these terms at any time
            • Continued use of the app constitutes acceptance of any changes
            • You must comply with all applicable laws when using this service
            """
        )
    }
    
    private var privacySection: some View {
        PolicySection(
            title: "Privacy Policy",
            icon: "lock.shield.fill",
            color: .blue,
            content: """
            Your privacy is important to us:
            
            • All recordings are stored locally on your device
            • We do not collect or store your personal recordings
            • No audio data is transmitted to our servers
            • App usage analytics may be collected to improve the experience
            • Your data is never sold or shared with third parties
            • You can delete all data at any time from the app settings
            """
        )
    }
    
    private var refundSection: some View {
        PolicySection(
            title: "Refund Policy",
            icon: "dollarsign.circle.fill",
            color: .red,
            content: """
            Please read carefully:
            
            🚫 NO REFUNDS POLICY
            
            • All purchases are final and non-refundable
            • We do not provide refunds for any reason
            • This includes but is not limited to: change of mind, compatibility issues, or dissatisfaction
            • Please try the free version before making any purchases
            • Contact support for technical issues before purchasing
            
            By purchasing, you acknowledge and accept this no-refund policy.
            """
        )
    }
    
    private var contactSection: some View {
        PolicySection(
            title: "Contact & Support",
            icon: "envelope.fill",
            color: .purple,
            content: """
            Get in touch with PG APP STUDIOS:
            
            📧 Email: pgmetastudios@gmail.com
            🌐 Website: www.pgappstudios.com
            
            For technical support or questions about these terms, please reach out through the official channels above.
            
            Made with 💖 by PG APP STUDIOS
            """
        )
    }
    
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
}

struct PolicySection: View {
    let title: String
    let icon: String
    let color: Color
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Content
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.linearGradient(
                    colors: [.white.opacity(0.2), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                ))
        )
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .modelContainer(for: VoiceRecording.self, inMemory: true)
}