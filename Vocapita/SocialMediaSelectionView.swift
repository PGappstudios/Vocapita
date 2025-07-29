import SwiftUI

struct SocialMediaSelectionView: View {
    let transcribedText: String
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlatform: SocialMediaPlatform?
    @State private var showingCaptionResult = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                headerSection
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(SocialMediaPlatform.allCases) { platform in
                            SocialMediaCardView(platform: platform) {
                                selectedPlatform = platform
                                showingCaptionResult = true
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                
                Spacer()
            }
            .background(appState.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Choose Platform")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Choose Platform")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
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
        .sheet(item: $selectedPlatform) { platform in
            CaptionResultView(
                transcribedText: transcribedText,
                platform: platform
            )
            .environmentObject(appState)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "megaphone.fill")
                .font(.system(size: 40))
                .foregroundColor(appState.primaryColor)
            
            Text("Create Perfect Captions")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Choose your platform and AI will optimize your content")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top)
    }
}

struct SocialMediaCardView: View {
    let platform: SocialMediaPlatform
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Platform Icon
                SocialMediaIconView(platform: platform, size: 50)
                    .shadow(color: platform.primaryColor.opacity(0.3), radius: 6, x: 0, y: 3)
                
                // Platform Name
                Text(platform.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                // Platform Description
                Text(platform.description)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .frame(width: 100, height: 120)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.linearGradient(
                        colors: [.white.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.snappy(duration: 0.3), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    SocialMediaSelectionView(transcribedText: "This is a sample transcribed text that will be converted into social media captions for different platforms.")
}