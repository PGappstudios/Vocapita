import SwiftUI
import SwiftData
import AVFoundation

struct HistoryTabView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VoiceRecording.timestamp, order: .reverse) private var recordings: [VoiceRecording]
    
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var recordingToDelete: VoiceRecording?
    @State private var selectedRecording: VoiceRecording?
    @State private var showingSocialMediaSelection = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentlyPlayingRecording: VoiceRecording?
    
    var filteredRecordings: [VoiceRecording] {
        if searchText.isEmpty {
            return recordings
        } else {
            return recordings.filter { recording in
                recording.transcription.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if recordings.isEmpty {
                    emptyStateView
                } else {
                    recordingsListView
                }
            }
            .background(appState.backgroundGradient.ignoresSafeArea())
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("History")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !recordings.isEmpty {
                        Menu {
                            Button(action: deleteAllRecordings) {
                                Label("Delete All", systemImage: "trash")
                            }
                            
                            Button(action: exportAllRecordings) {
                                Label("Export All", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(action: {
                                appState.selectTab(1) // Switch to Record tab
                            }) {
                                Label("New Recording", systemImage: "mic.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(appState.primaryColor)
                        }
                    } else {
                        Button("Record") {
                            appState.selectTab(1) // Switch to Record tab
                        }
                        .foregroundColor(appState.primaryColor)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search transcriptions...")
            .sheet(item: $selectedRecording) { recording in
                SocialMediaSelectionView(transcribedText: recording.transcription)
            }
            .alert("Delete Recording", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let recording = recordingToDelete {
                        deleteRecording(recording)
                    }
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(appState.primaryColor.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "waveform.circle")
                    .font(.system(size: 60))
                    .foregroundColor(appState.primaryColor)
            }
            
            VStack(spacing: 12) {
                Text("No Recordings Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Your saved recordings will appear here. Start by creating your first recording!")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button("Start Recording") {
                appState.selectTab(1) // Switch to Record tab
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [appState.primaryColor, appState.secondaryColor]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: appState.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
            
            Spacer()
        }
    }
    
    private var recordingsListView: some View {
        VStack(spacing: 0) {
            // Stats header
            statsHeaderView
            
            // Recordings list
            List {
                ForEach(filteredRecordings) { recording in
                    HistoryRecordingRowView(
                        recording: recording,
                        isPlaying: currentlyPlayingRecording?.id == recording.id && isPlaying,
                        onPlay: { playRecording(recording) },
                        onStop: { stopPlayback() },
                        onCreateCaption: { 
                            selectedRecording = recording
                        },
                        onDelete: {
                            recordingToDelete = recording
                            showingDeleteAlert = true
                        }
                    )
                    .listRowBackground(Color(.systemBackground).opacity(0.8))
                }
                .onDelete(perform: deleteRecordings)
            }
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden)
        }
    }
    
    private var statsHeaderView: some View {
        HStack(spacing: 16) {
            HistoryStatsCard(
                icon: "waveform",
                title: "\(recordings.count)",
                subtitle: "Recordings",
                color: appState.primaryColor
            )
            
            HistoryStatsCard(
                icon: "clock",
                title: formatTotalDuration(),
                subtitle: "Total Time",
                color: .green
            )
            
            HistoryStatsCard(
                icon: "textformat",
                title: "\(totalWords())",
                subtitle: "Words",
                color: .orange
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    private func playRecording(_ recording: VoiceRecording) {
        // Stop any current playback
        stopPlayback()
        
        // For now, we'll just simulate playback since we don't have actual audio files
        // In a real implementation, you'd use the audioFileName property
        currentlyPlayingRecording = recording
        isPlaying = true
        
        // Simulate playback completion after the recording duration
        DispatchQueue.main.asyncAfter(deadline: .now() + min(recording.duration, 3.0)) {
            stopPlayback()
        }
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentlyPlayingRecording = nil
    }
    
    private func deleteRecording(_ recording: VoiceRecording) {
        withAnimation {
            modelContext.delete(recording)
            try? modelContext.save()
        }
    }
    
    private func deleteRecordings(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredRecordings[index])
            }
            try? modelContext.save()
        }
    }
    
    private func deleteAllRecordings() {
        withAnimation {
            for recording in recordings {
                modelContext.delete(recording)
            }
            try? modelContext.save()
        }
    }
    
    private func exportAllRecordings() {
        let allTranscriptions = recordings.map { recording in
            "[\(formatDate(recording.timestamp))] \(recording.transcription)"
        }.joined(separator: "\n\n")
        
        let activityVC = UIActivityViewController(
            activityItems: [allTranscriptions],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct HistoryRecordingRowView: View {
    let recording: VoiceRecording
    let isPlaying: Bool
    let onPlay: () -> Void
    let onStop: () -> Void
    let onCreateCaption: () -> Void
    let onDelete: () -> Void
    
    @EnvironmentObject var appState: AppState
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with date and controls
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDate(recording.timestamp))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(formatDuration(recording.duration))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "textformat")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(wordCount) words")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Control buttons
                HStack(spacing: 8) {
                    // Play/Stop button (simulated)
                    Button(action: isPlaying ? onStop : onPlay) {
                        Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(appState.primaryColor)
                    }
                    
                    // Expand/Collapse button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(appState.primaryColor)
                    }
                }
            }
            
            // Transcription text
            if !recording.transcription.isEmpty {
                Text(isExpanded ? recording.transcription : String(recording.transcription.prefix(120)) + (recording.transcription.count > 120 ? "..." : ""))
                    .font(.body)
                    .foregroundColor(.primary)
                    .animation(.easeInOut(duration: 0.3), value: isExpanded)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("No transcription available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            // Expanded action buttons
            if isExpanded && !recording.transcription.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        HistoryActionButton(
                            icon: "megaphone.fill",
                            title: "Create Captions",
                            color: appState.primaryColor,
                            action: onCreateCaption
                        )
                        
                        HistoryActionButton(
                            icon: "doc.on.doc",
                            title: "Copy",
                            color: .green
                        ) {
                            UIPasteboard.general.string = recording.transcription
                        }
                        
                        HistoryActionButton(
                            icon: "square.and.arrow.up",
                            title: "Share",
                            color: .orange
                        ) {
                            shareText(recording.transcription)
                        }
                        
                        HistoryActionButton(
                            icon: "trash",
                            title: "Delete",
                            color: .red,
                            action: onDelete
                        )
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var wordCount: Int {
        recording.transcription.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
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
    
    private func shareText(_ text: String) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

struct HistoryStatsCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct HistoryActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.1))
            .cornerRadius(16)
        }
    }
}

#Preview {
    HistoryTabView()
        .environmentObject(AppState())
        .modelContainer(for: VoiceRecording.self, inMemory: true)
}