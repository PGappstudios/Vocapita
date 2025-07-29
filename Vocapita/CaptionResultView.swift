import SwiftUI

struct CaptionResultView: View {
    let transcribedText: String
    let platform: SocialMediaPlatform
    
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var generatedCaption = ""
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showingCopySuccess = false
    
    private let chatGPTService = ChatGPTService.shared
    private let socialMediaManager = SocialMediaManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                platformHeader
                
                if isGenerating {
                    generatingView
                } else if let error = errorMessage {
                    errorView(error)
                } else if !generatedCaption.isEmpty {
                    captionDisplayView
                } else {
                    emptyStateView
                }
                
                Spacer()
                
                if !generatedCaption.isEmpty && !isGenerating {
                    actionButtons
                }
            }
            .background(appState.backgroundGradient.ignoresSafeArea())
            .navigationTitle(platform.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Regenerate") {
                        generateCaption()
                    }
                    .disabled(isGenerating)
                }
            }
            .onAppear {
                generateCaption()
            }
        }
        .alert("Copied!", isPresented: $showingCopySuccess) {
            Button("OK") { }
        } message: {
            Text("Caption copied to clipboard and \(platform.displayName) is opening...")
        }
    }
    
    private var platformHeader: some View {
        VStack(spacing: 16) {
            HStack {
                SocialMediaIconView(platform: platform, size: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(platform.displayName)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(platform.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .background(Color(.systemBackground))
    }
    
    private var generatingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: appState.primaryColor))
            
            Text("Creating perfect caption for \(platform.displayName)...")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("AI is analyzing your content and optimizing for \(platform.tone)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Generation Failed")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(error)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                generateCaption()
            }
            .buttonStyle(.borderedProminent)
            .tint(platform.primaryColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Ready to Generate")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap regenerate to create your \(platform.displayName) caption")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var captionDisplayView: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Generated Caption")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(generatedCaption.count)/\(platform.characterLimit)")
                            .font(.caption)
                            .foregroundColor(generatedCaption.count > platform.characterLimit ? .red : .secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    Text(generatedCaption)
                        .font(.body)
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: copyAndOpen) {
                HStack(spacing: 12) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 18, weight: .medium))
                    
                    Text("Copy & Open \(platform.displayName)")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(platform.primaryColor)
                .cornerRadius(12)
                .shadow(color: platform.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            Button(action: copyToClipboard) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 16))
                    
                    Text("Copy Only")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(platform.primaryColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(platform.primaryColor.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
    
    private func generateCaption() {
        isGenerating = true
        errorMessage = nil
        
        Task {
            do {
                let caption = try await chatGPTService.generateCaption(
                    from: transcribedText,
                    for: platform
                )
                
                await MainActor.run {
                    self.generatedCaption = caption
                    self.isGenerating = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isGenerating = false
                }
            }
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = generatedCaption
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func copyAndOpen() {
        copyToClipboard()
        socialMediaManager.openApp(for: platform)
        showingCopySuccess = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}


#Preview {
    CaptionResultView(
        transcribedText: "This is a sample transcribed text about my amazing day at the beach. The weather was perfect and I had so much fun with my friends!",
        platform: .instagram
    )
}