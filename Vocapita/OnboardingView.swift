import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var showingGetStarted = false
    
    private let pages = OnboardingData.pages
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full-screen background
                appState.backgroundGradient
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Skip button - positioned at top with safe area
                    HStack {
                        Spacer()
                        if currentPage < pages.count - 1 {
                            Button("Skip") {
                                completeOnboarding()
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.trailing, 24)
                            .padding(.top, geometry.safeAreaInsets.top + 16)
                        }
                    }
                    
                    // Page Content - full screen utilization
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingPageView(
                                title: pages[index].title,
                                subtitle: pages[index].subtitle,
                                description: pages[index].description,
                                contentType: pages[index].contentType,
                                backgroundGradient: appState.backgroundGradient,
                                hasAnimation: pages[index].hasAnimation
                            )
                            .tag(index)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                )
                            )
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3), value: currentPage)
                    .frame(height: geometry.size.height * 0.82) // Maximize screen usage
                    
                    // Modern floating controls
                    ZStack {
                        // Floating control background
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.ultraThinMaterial)
                            .frame(height: adaptiveControlHeight(for: geometry))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: adaptiveControlSpacing(for: geometry)) {
                            // Compact page indicators
                            HStack(spacing: 8) {
                                ForEach(0..<pages.count, id: \.self) { index in
                                    Capsule()
                                        .fill(index == currentPage ? 
                                              LinearGradient(
                                                gradient: Gradient(colors: [appState.primaryColor, appState.secondaryColor]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                              ) :
                                              LinearGradient(
                                                gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                              )
                                        )
                                        .frame(width: index == currentPage ? 20 : 6, height: 6)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                                }
                            }
                    
                            
                            // Compact navigation buttons
                            HStack(spacing: adaptiveButtonSpacing(for: geometry)) {
                                // Back Button - minimal design
                                if currentPage > 0 {
                                    Button(action: previousPage) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "chevron.left")
                                                .font(.system(size: 12, weight: .medium))
                                            Text("Back")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(appState.primaryColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                    }
                                }
                                
                                Spacer()
                                
                                // Compact Next/Get Started Button
                                Button(action: nextPageOrComplete) {
                                    HStack(spacing: 6) {
                                        Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        
                                        if currentPage < pages.count - 1 {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundColor(.white)
                                        } else {
                                            Image(systemName: "rocket.fill")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(height: 32)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        appState.primaryColor,
                                                        appState.secondaryColor
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                                    .shadow(color: appState.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom + 10, 20))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            checkForGetStartedAnimation()
        }
        .onChange(of: currentPage) { _, _ in
            checkForGetStartedAnimation()
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    let threshold: CGFloat = 50
                    if gesture.translation.width > threshold && currentPage > 0 {
                        previousPage()
                    } else if gesture.translation.width < -threshold && currentPage < pages.count - 1 {
                        nextPage()
                    }
                }
        )
    }
    
    private func checkForGetStartedAnimation() {
        showingGetStarted = currentPage == pages.count - 1
    }
    
    private func nextPage() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3)) {
            currentPage += 1
        }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func previousPage() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3)) {
            currentPage -= 1
        }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func nextPageOrComplete() {
        if currentPage == pages.count - 1 {
            completeOnboarding()
        } else {
            nextPage()
        }
    }
    
    private func completeOnboarding() {
        // Add success haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0.4)) {
            appState.completeOnboarding()
        }
    }
    
    // MARK: - Adaptive UI Helpers
    private func adaptiveControlHeight(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        switch screenHeight {
        case 0...667: return 75    // iPhone SE
        case 668...844: return 85  // iPhone 12 mini, regular
        default: return 95         // iPhone Pro Max
        }
    }
    
    private func adaptiveControlSpacing(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        return screenHeight > 800 ? 16 : 12
    }
    
    private func adaptiveButtonSpacing(for geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        return screenWidth > 375 ? 16 : 12
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}