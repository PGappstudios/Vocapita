import SwiftUI
import SwiftData

struct RecordingView: View {
    @ObservedObject var voiceRecorder: VoiceRecorderManager
    let modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showingSavedAlert = false
    @State private var showingSocialMediaSelection = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 20)
                    
                    visualizerSection
                    
                    transcriptionSection
                    
                    controlsSection
                    
                    Spacer(minLength: 120) // Extra space for tab bar
                }
                .padding(.horizontal, 24)
                .frame(minHeight: UIScreen.main.bounds.height - 200) // Ensure minimum height for centering
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Recording")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if voiceRecorder.isRecording {
                            stopRecording()
                        }
                        dismiss()
                    }
                }
            }
            .alert("Recording Saved!", isPresented: $showingSavedAlert) {
                Button("OK") { }
            } message: {
                Text("Your voice recording has been transcribed and saved.")
            }
            .sheet(isPresented: $showingSocialMediaSelection) {
                SocialMediaSelectionView(transcribedText: voiceRecorder.transcription)
            }
            .onAppear {
                setupAutoSave()
            }
        }
    }
    
    private var visualizerSection: some View {
        VStack(spacing: 20) {
            recordingVisualizerView
            recordingStatusView
        }
    }
    
    private var recordingVisualizerView: some View {
        ZStack {
            pulseRingsView
            recordingButton
        }
    }
    
    private var pulseRingsView: some View {
        ForEach(0..<5, id: \.self) { index in
            let size = CGFloat(120 + index * 20)
            let opacity = voiceRecorder.isRecording ? 0.6 - Double(index) * 0.1 : 0.3
            let scale = CGFloat(voiceRecorder.isRecording ? 1.0 + (voiceRecorder.recordingLevel * 0.3) : 1.0)
            
            Circle()
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                .frame(width: size, height: size)
                .scaleEffect(scale)
                .opacity(opacity)
                .animation(
                    reduceMotion ? .none : .bouncy(duration: 0.8)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.1),
                    value: voiceRecorder.isRecording
                )
        }
    }
    
    private var recordingButton: some View {
        Button(action: toggleRecording) {
            ZStack {
                // Glass background
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 140, height: 140)
                
                // Gradient overlay
                Circle()
                    .fill(.linearGradient(
                        colors: [
                            voiceRecorder.isRecording ? .red : .blue,
                            voiceRecorder.isRecording ? .red.opacity(0.8) : .blue.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                
                // Glass rim
                Circle()
                    .stroke(.linearGradient(
                        colors: [.white.opacity(0.4), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 2)
                    .frame(width: 120, height: 120)
                
                // Icon with glow
                Image(systemName: voiceRecorder.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(.white)
                    .shadow(color: .white.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .shadow(color: voiceRecorder.isRecording ? .red.opacity(0.3) : .blue.opacity(0.3), 
                radius: 20, x: 0, y: 10)
        .scaleEffect(voiceRecorder.isRecording ? 1.1 : 1.0)
        .animation(reduceMotion ? .none : .bouncy(duration: 0.6), value: voiceRecorder.isRecording)
        .accessibilityLabel(voiceRecorder.isRecording ? "Stop recording" : "Start recording")
        .accessibilityHint(voiceRecorder.isRecording ? "Double tap to stop voice recording" : "Double tap to begin voice recording")
        .accessibilityAddTraits(.isButton)
    }
    
    private var recordingStatusView: some View {
        VStack(spacing: 8) {
            Text(voiceRecorder.isRecording ? "Recording..." : "Tap to Start Recording")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            if voiceRecorder.isRecording {
                Text(formatTime(recordingTime))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .monospacedDigit()
                    .accessibilityLabel("Recording time: \(formatTime(recordingTime))")
                    .accessibilityValue(voiceRecorder.isRecording ? "Recording in progress" : "Not recording")
            } else if !voiceRecorder.hasPermission {
                Text("Microphone permission required")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private func toggleRecording() {
        if voiceRecorder.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private var transcriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Transcription")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityHeading(.h2)
                
                if voiceRecorder.isTranscribing {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.7)
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        Text("Detecting language...")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let errorMessage = voiceRecorder.errorMessage {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.red)
                                Text("Error")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                            
                            Text(errorMessage)
                                .font(.body)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else if voiceRecorder.transcription.isEmpty && !voiceRecorder.isTranscribing {
                        Text("Your transcription will appear here...")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else if !voiceRecorder.transcription.isEmpty {
                        Text(voiceRecorder.transcription)
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(reduceMotion ? .none : .smooth(duration: 0.4), value: voiceRecorder.transcription)
                    } else if voiceRecorder.isTranscribing {
                        Text("Detecting language and transcribing with AI...")
                            .font(.body)
                            .foregroundColor(.blue)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .frame(minHeight: 120, maxHeight: 200)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
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
    
    private var controlsSection: some View {
        VStack(spacing: 16) {
            if !voiceRecorder.transcription.isEmpty && !voiceRecorder.isTranscribing {
                // Primary action: Create Social Media Captions
                Button(action: {
                    showingSocialMediaSelection = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "megaphone.fill")
                            .font(.system(size: 18, weight: .medium))
                        Text("Create Social Media Captions")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                // Secondary actions
                HStack(spacing: 12) {
                    Button(action: {
                        UIPasteboard.general.string = voiceRecorder.transcription
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
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
                        .accessibilityLabel("Copy transcription")
                        .accessibilityHint("Copy the transcribed text to clipboard")
                    }
                    
                    Button(action: saveRecording) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
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
                        .accessibilityLabel("Save recording")
                        .accessibilityHint("Save the recording to your library")
                    }
                }
            }
        }
    }
    
    private func startRecording() {
        voiceRecorder.startRecording()
        recordingTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            recordingTime += 1
        }
    }
    
    private func stopRecording() {
        voiceRecorder.stopRecording()
        timer?.invalidate()
        timer = nil
    }
    
    private func saveRecording() {
        let recording = VoiceRecording(
            transcription: voiceRecorder.transcription,
            duration: recordingTime
        )
        
        modelContext.insert(recording)
        
        do {
            try modelContext.save()
            showingSavedAlert = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch {
            print("Failed to save recording: \(error)")
        }
    }
    
    private func setupAutoSave() {
        voiceRecorder.onTranscriptionComplete = { transcription, duration in
            let recording = VoiceRecording(
                transcription: transcription,
                duration: duration
            )
            
            modelContext.insert(recording)
            
            do {
                try modelContext.save()
                showingSavedAlert = true
            } catch {
                print("Failed to auto-save recording: \(error)")
            }
        }
    }
    
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}