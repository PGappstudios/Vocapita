import Foundation
import AVFoundation

@MainActor
class VoiceRecorderManager: ObservableObject {
    @Published var isRecording = false
    @Published var isTranscribing = false
    @Published var transcription = ""
    @Published var recordingLevel: Float = 0.0
    @Published var hasPermission = false
    @Published var errorMessage: String?
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var levelTimer: Timer?
    private let chatGPTService = ChatGPTService.shared
    
    // Callback for when transcription completes successfully
    var onTranscriptionComplete: ((String, TimeInterval) -> Void)?
    private var recordingStartTime: Date?
    
    init() {
        requestPermissions()
        setupAudioSession()
    }
    
    func requestPermissions() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPermission = granted
            }
        }
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func startRecording() {
        guard hasPermission else {
            requestPermissions()
            return
        }
        
        isRecording = true
        transcription = ""
        errorMessage = nil
        recordingStartTime = Date()
        
        startFileRecording()
        startAudioLevelMonitoring()
    }
    
    func stopRecording() {
        isRecording = false
        
        audioRecorder?.stop()
        levelTimer?.invalidate()
        levelTimer = nil
        recordingLevel = 0.0
        
        // Start transcription after recording stops
        if let recordingURL = recordingURL {
            transcribeRecording(from: recordingURL)
        }
    }
    
    private func startFileRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        recordingURL = audioFilename
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
        } catch {
            print("Could not start recording: \(error)")
            errorMessage = "Could not start recording: \(error.localizedDescription)"
            isRecording = false
        }
    }
    
    private func transcribeRecording(from url: URL) {
        isTranscribing = true
        
        Task {
            do {
                let transcribedText = try await chatGPTService.transcribeAudio(from: url)
                
                await MainActor.run {
                    self.transcription = transcribedText
                    self.isTranscribing = false
                    
                    // Calculate recording duration and trigger auto-save callback
                    if let startTime = self.recordingStartTime {
                        let duration = Date().timeIntervalSince(startTime)
                        self.onTranscriptionComplete?(transcribedText, duration)
                    }
                }
                
                // Clean up the temporary audio file
                try? FileManager.default.removeItem(at: url)
                
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isTranscribing = false
                    print("Transcription error: \(error)")
                }
            }
        }
    }
    
    private func startAudioLevelMonitoring() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let recorder = self.audioRecorder, self.isRecording else { return }
            
            recorder.updateMeters()
            let averagePower = recorder.averagePower(forChannel: 0)
            let normalizedLevel = pow(10.0, averagePower / 20.0)
            
            DispatchQueue.main.async {
                self.recordingLevel = Float(normalizedLevel)
            }
        }
    }
}