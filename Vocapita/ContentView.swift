//
//  ContentView.swift
//  Vocapita
//
//  Created by Pedro Gregorio on 23/07/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VoiceRecording.timestamp, order: .reverse) private var recordings: [VoiceRecording]
    @StateObject private var voiceRecorder = VoiceRecorderManager()
    @State private var showingRecordingView = false
    @State private var showingSavedRecordings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
                
                if recordings.isEmpty {
                    emptyStateView
                } else {
                    recordingsList
                }
                
                Spacer()
                recordButton
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Vocapita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Vocapita")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSavedRecordings = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "folder")
                                .font(.system(size: 16, weight: .medium))
                            Text("Saved")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
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
            .sheet(isPresented: $showingRecordingView) {
                RecordingView(voiceRecorder: voiceRecorder, modelContext: modelContext)
            }
            .sheet(isPresented: $showingSavedRecordings) {
                SavedRecordingsView()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "waveform")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Voice to Text")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Text("Speak in any language - AI will detect and transcribe")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding(.bottom, 16)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.circle")
                .font(.system(size: 80))
                .foregroundColor(.blue.opacity(0.6))
            
            Text("No Recordings Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Record in any language and get instant transcription")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var recordingsList: some View {
        List {
            ForEach(recordings) { recording in
                RecordingRowView(recording: recording)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button("Delete", role: .destructive) {
                            deleteRecording(recording)
                        }
                    }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private var recordButton: some View {
        VStack(spacing: 16) {
            Button(action: {
                showingRecordingView.toggle()
            }) {
                ZStack {
                    // Glass background
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 100, height: 100)
                    
                    // Gradient overlay
                    Circle()
                        .fill(.linearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                    
                    // Glass rim
                    Circle()
                        .stroke(.linearGradient(
                            colors: [.white.opacity(0.4), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 2)
                        .frame(width: 80, height: 80)
                    
                    // Icon with glow
                    Image(systemName: "mic.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(.white)
                        .shadow(color: .white.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
            .scaleEffect(voiceRecorder.isRecording ? 1.1 : 1.0)
            .animation(.bouncy(duration: 0.6), value: voiceRecorder.isRecording)
            .accessibilityLabel("Start recording")
            .accessibilityHint("Double tap to begin voice recording")
            .accessibilityAddTraits(.isButton)
            
            Text("Tap to Record")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 40)
    }
    
    private func deleteRecording(_ recording: VoiceRecording) {
        withAnimation {
            modelContext.delete(recording)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: VoiceRecording.self, inMemory: true)
}
