import SwiftUI
import SwiftData

struct RecordingTabView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @StateObject private var voiceRecorder = VoiceRecorderManager()
    
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showingSavedAlert = false
    @State private var showingSocialMediaSelection = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                visualizerSection
                
                transcriptionSection
                
                Spacer()
                
                controlsSection
            }
            .padding(.horizontal, 24)
            .background(appState.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Record")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
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
        ZStack {
            // Background subtle rings
            ForEach(0..<3, id: \.self) { index in
                let size = CGFloat(160 + index * 30)
                Circle()
                    .stroke(appState.primaryColor.opacity(0.1), lineWidth: 1)
                    .frame(width: size, height: size)
                    .scaleEffect(voiceRecorder.isRecording ? 1.0 + sin(Date().timeIntervalSince1970 + Double(index)) * 0.05 : 1.0)
                    .animation(
                        .easeInOut(duration: 3.0 + Double(index))
                        .repeatForever(autoreverses: true),
                        value: voiceRecorder.isRecording
                    )
            }
            
            // Main pulse rings
            ForEach(0..<5, id: \.self) { index in
                let size = CGFloat(120 + index * 15)
                let baseOpacity = voiceRecorder.isRecording ? 0.7 - Double(index) * 0.12 : 0.2
                let dynamicOpacity = voiceRecorder.isRecording ? 
                    baseOpacity + (Double(voiceRecorder.recordingLevel) * 0.4) : baseOpacity
                let scale = voiceRecorder.isRecording ? 
                    1.0 + (Double(voiceRecorder.recordingLevel) * 0.2) + Double(index) * 0.02 : 1.0
                
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                appState.primaryColor.opacity(dynamicOpacity),
                                appState.secondaryColor.opacity(dynamicOpacity * 0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: voiceRecorder.isRecording ? 3 : 2
                    )
                    .frame(width: size, height: size)
                    .scaleEffect(scale)
                    .opacity(dynamicOpacity)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.6)
                        .delay(Double(index) * 0.05),
                        value: voiceRecorder.recordingLevel
                    )
                    .animation(
                        .easeInOut(duration: 1.5 + Double(index) * 0.2)
                        .repeatForever(autoreverses: true),
                        value: voiceRecorder.isRecording
                    )
            }
            
            // Audio level indicator bars
            if voiceRecorder.isRecording {
                audioLevelBars
            }
        }
    }
    
    private var audioLevelBars: some View {
        HStack(spacing: 4) {
            ForEach(0..<8, id: \.self) { index in
                let height = CGFloat(20 + Double(voiceRecorder.recordingLevel) * 40 * Double.random(in: 0.5...1.0))
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                appState.primaryColor,
                                appState.secondaryColor
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 3, height: height)
                    .animation(
                        .easeInOut(duration: 0.1)
                        .delay(Double(index) * 0.02),
                        value: voiceRecorder.recordingLevel
                    )
            }
        }
        .opacity(0.8)
        .offset(y: 80)
    }
    
    private var recordingButton: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            toggleRecording()
        }) {
            ZStack {
                // Enhanced glass background with depth
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 140, height: 140)
                    .overlay(
                        Circle()
                            .fill(.regularMaterial)
                            .frame(width: 135, height: 135)
                            .opacity(0.3)
                    )
                
                // Dynamic gradient overlay
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                voiceRecorder.isRecording ? .red : appState.primaryColor,
                                voiceRecorder.isRecording ? .red.opacity(0.7) : appState.primaryColor.opacity(0.7),
                                voiceRecorder.isRecording ? .red.opacity(0.9) : appState.secondaryColor.opacity(0.9)
                            ]),
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(voiceRecorder.isRecording ? 1.0 + (CGFloat(voiceRecorder.recordingLevel) * 0.1) : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: voiceRecorder.recordingLevel)
                
                // Enhanced glass rim with shimmer effect
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.6),
                                .clear,
                                .white.opacity(0.3),
                                .clear,
                                .white.opacity(0.6)
                            ]),
                            center: .center
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(voiceRecorder.isRecording ? 360 : 0))
                    .animation(
                        voiceRecorder.isRecording ? 
                        .linear(duration: 4.0).repeatForever(autoreverses: false) : .none,
                        value: voiceRecorder.isRecording
                    )
                
                // Icon with enhanced effects
                ZStack {
                    // Glow effect behind icon
                    Image(systemName: voiceRecorder.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(
                            voiceRecorder.isRecording ? .red.opacity(0.3) : appState.primaryColor.opacity(0.3)
                        )
                        .blur(radius: 8)
                        .scaleEffect(1.2)
                    
                    // Main icon
                    Image(systemName: voiceRecorder.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(.white)
                        .shadow(color: .white.opacity(0.5), radius: 6, x: 0, y: 3)
                }
                .scaleEffect(voiceRecorder.isRecording ? 1.0 + (CGFloat(voiceRecorder.recordingLevel) * 0.05) : 1.0)
                .animation(.easeInOut(duration: 0.1), value: voiceRecorder.recordingLevel)
            }
        }
        .shadow(
            color: voiceRecorder.isRecording ? .red.opacity(0.4) : appState.primaryColor.opacity(0.4),
            radius: voiceRecorder.isRecording ? 25 : 20,
            x: 0,
            y: voiceRecorder.isRecording ? 12 : 10
        )
        .scaleEffect(voiceRecorder.isRecording ? 1.05 : 1.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: voiceRecorder.isRecording)
    }
    
    private var recordingStatusView: some View {
        VStack(spacing: 8) {
            Text(voiceRecorder.isRecording ? "Recording..." : "Tap to Start Recording")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if voiceRecorder.isRecording {
                Text(formatTime(recordingTime))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(appState.primaryColor)
                    .monospacedDigit()
            } else if !voiceRecorder.hasPermission {
                Text("Microphone permission required")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var transcriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Enhanced header with better spacing
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "text.quote")
                        .font(.title3)
                        .foregroundColor(appState.primaryColor)
                    
                    Text("Transcription")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                if voiceRecorder.isTranscribing {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: appState.primaryColor))
                        
                        Text("AI Processing...")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(appState.primaryColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(appState.primaryColor.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                // Word count badge
                if !voiceRecorder.transcription.isEmpty {
                    Text("\(wordCount) words")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                }
            }
            
            // Enhanced transcription display
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let errorMessage = voiceRecorder.errorMessage {
                        errorStateView(errorMessage)
                    } else if voiceRecorder.transcription.isEmpty && !voiceRecorder.isTranscribing {
                        emptyTranscriptionView
                    } else if !voiceRecorder.transcription.isEmpty {
                        transcriptionTextView
                    } else if voiceRecorder.isTranscribing {
                        processingStateView
                    }
                }
                .padding(20)
            }
            .frame(minHeight: 140, maxHeight: 220)
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
            .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
            .shadow(color: appState.primaryColor.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    private var wordCount: Int {
        voiceRecorder.transcription.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }.count
    }
    
    private func errorStateView(_ errorMessage: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                Text("Error Occurred")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }
            
            Text(errorMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var emptyTranscriptionView: some View {
        VStack(spacing: 12) {
            Image(systemName: "waveform.and.mic")
                .font(.system(size: 32))
                .foregroundColor(appState.primaryColor.opacity(0.6))
            
            Text("Your transcription will appear here...")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .italic()
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var transcriptionTextView: some View {
        Text(voiceRecorder.transcription)
            .font(.body)
            .fontWeight(.regular)
            .foregroundColor(.primary)
            .lineSpacing(6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
            .animation(.smooth(duration: 0.5), value: voiceRecorder.transcription)
    }
    
    private var processingStateView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(appState.primaryColor)
                        .frame(width: 8, height: 8)
                        .scaleEffect(1.0 + sin(Date().timeIntervalSince1970 * 2 + Double(index) * 0.5) * 0.5)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: Date().timeIntervalSince1970
                        )
                }
            }
            
            VStack(spacing: 8) {
                Text("AI is analyzing your speech...")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(appState.primaryColor)
                
                Text("Detecting language and generating transcription")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var controlsSection: some View {
        VStack(spacing: 20) {
            if !voiceRecorder.transcription.isEmpty && !voiceRecorder.isTranscribing {
                // Primary action: Create Social Media Captions
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    showingSocialMediaSelection = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "megaphone.fill")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Create Social Media Captions")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
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
                                    .white.opacity(0.2),
                                    .clear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .rotationEffect(.degrees(45))
                        }
                    )
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.3),
                                        .clear,
                                        .white.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: appState.primaryColor.opacity(0.4), radius: 12, x: 0, y: 6)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                // Secondary actions with enhanced styling
                HStack(spacing: 16) {
                    // Copy button
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        UIPasteboard.general.string = voiceRecorder.transcription
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 16, weight: .medium))
                            Text("Copy")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(appState.primaryColor)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.4),
                                            .clear,
                                            appState.primaryColor.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
                    }
                    
                    // Save button
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        saveRecording()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 16, weight: .medium))
                            Text("Save")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(appState.primaryColor)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.4),
                                            .clear,
                                            appState.primaryColor.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
                    }
                }
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
            
            // Clear the current recording
            voiceRecorder.transcription = ""
            recordingTime = 0
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

#Preview {
    RecordingTabView()
        .environmentObject(AppState())
        .modelContainer(for: VoiceRecording.self, inMemory: true)
}