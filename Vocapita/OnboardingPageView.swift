import SwiftUI

struct OnboardingPageView: View {
    let title: String
    let subtitle: String
    let description: String
    let contentType: OnboardingContentType
    let backgroundGradient: LinearGradient
    let hasAnimation: Bool
    
    // Convenience initializer for backward compatibility
    init(title: String, subtitle: String, description: String, iconName: String, iconColor: Color, backgroundGradient: LinearGradient, hasAnimation: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.contentType = .icon(name: iconName, color: iconColor)
        self.backgroundGradient = backgroundGradient
        self.hasAnimation = hasAnimation
    }
    
    init(title: String, subtitle: String, description: String, contentType: OnboardingContentType, backgroundGradient: LinearGradient, hasAnimation: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.contentType = contentType
        self.backgroundGradient = backgroundGradient
        self.hasAnimation = hasAnimation
    }
    
    private var primaryColor: Color {
        switch contentType {
        case .icon(_, let color):
            return color
        case .customView(_):
            return .blue
        case .socialMediaComparison:
            return .green
        case .platformShowcase:
            return .purple
        case .engagementMetrics:
            return .blue
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full-screen background
                backgroundGradient
                    .ignoresSafeArea(.all)
                
                // Simplified particle effects
                subtleParticleBackground(geometry: geometry)
                
                // Modern full-screen layout with proper spacing
                VStack(spacing: 0) {
                    // Top safe area spacer
                    Spacer(minLength: geometry.safeAreaInsets.top + 20)
                    
                    // Visual Content Section - flexible height
                    visualContentSection(geometry: geometry)
                        .frame(height: geometry.size.height * 0.35)
                    
                    // Spacing between visual and text
                    Spacer().frame(height: geometry.size.height * 0.05)
                    
                    // Text Content Section - adaptive height
                    textContentSection(geometry: geometry)
                        .frame(maxHeight: geometry.size.height * 0.4)
                    
                    // Bottom spacer for navigation controls
                    Spacer(minLength: geometry.size.height * 0.15)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, adaptivePadding(for: geometry))
            }
        }
        .ignoresSafeArea(.all)
    }
    
    @ViewBuilder
    private func visualContentSection(geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            
            switch contentType {
            case .icon(let name, let color):
                iPhoneOptimizedIconView(iconName: name, iconColor: color, geometry: geometry)
                
            case .customView(let view):
                view
                    .frame(maxHeight: geometry.size.height * 0.25)
                
            case .socialMediaComparison:
                iPhoneSocialMediaComparisonView()
                
            case .platformShowcase:
                iPhonePlatformShowcaseView()
                
            case .engagementMetrics:
                iPhoneEngagementMetricsView(hasAnimation: hasAnimation)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func textContentSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: adaptiveSpacing(for: geometry)) {
            // Title - Responsive and readable
            Text(title)
                .font(.system(size: titleFontSize(for: geometry), weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.primary, .primary.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.7)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            
            // Subtitle - Brand colored with proper scaling
            Text(subtitle)
                .font(.system(size: subtitleFontSize(for: geometry), weight: .semibold))
                .foregroundColor(primaryColor)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.8)
                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            
            // Description - Optimized body text
            Text(description)
                .font(.system(size: bodyFontSize(for: geometry), weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(adaptiveLineSpacing(for: geometry))
                .lineLimit(nil)
                .minimumScaleFactor(0.7)
                .dynamicTypeSize(...DynamicTypeSize.xLarge)
                .padding(.horizontal, adaptiveHorizontalPadding(for: geometry))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private func subtleParticleBackground(geometry: GeometryProxy) -> some View {
        ForEach(0..<3, id: \.self) { index in
            Circle()
                .fill(primaryColor.opacity(0.04))
                .frame(width: 6, height: 6)
                .position(
                    x: CGFloat.random(in: 50...geometry.size.width - 50),
                    y: CGFloat.random(in: 100...geometry.size.height - 100)
                )
                .animation(
                    .easeInOut(duration: Double.random(in: 6...8))
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 1.0),
                    value: Date().timeIntervalSince1970
                )
        }
    }
    
    // MARK: - Responsive Design Helpers
    private func adaptivePadding(for geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        switch screenWidth {
        case 0...375: return 16    // iPhone SE, 12 mini
        case 376...414: return 20  // iPhone 12, 13, 14, 15
        default: return 24         // iPhone Plus, Pro Max
        }
    }
    
    private func adaptiveSpacing(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        switch screenHeight {
        case 0...667: return 12   // iPhone SE
        case 668...844: return 16 // iPhone 12 mini, regular
        default: return 20        // iPhone Pro Max
        }
    }
    
    private func adaptiveLineSpacing(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        return screenHeight > 800 ? 6 : 4
    }
    
    private func adaptiveHorizontalPadding(for geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        switch screenWidth {
        case 0...375: return 8     // iPhone SE, 12 mini
        case 376...414: return 12  // iPhone 12, 13, 14, 15
        default: return 16         // iPhone Plus, Pro Max
        }
    }
    
    // MARK: - Responsive Font Sizes
    private func titleFontSize(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        let baseSize: CGFloat
        switch screenHeight {
        case 0...667: baseSize = 24    // iPhone SE, 8
        case 668...844: baseSize = 28  // iPhone 12 mini, 13 mini
        case 845...926: baseSize = 30  // iPhone 12, 13, 14, 15
        default: baseSize = 32         // iPhone Pro Max
        }
        return min(baseSize, geometry.size.width * 0.08)
    }
    
    private func subtitleFontSize(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        let baseSize: CGFloat
        switch screenHeight {
        case 0...667: baseSize = 16    // iPhone SE, 8
        case 668...844: baseSize = 18  // iPhone 12 mini, 13 mini
        case 845...926: baseSize = 20  // iPhone 12, 13, 14, 15
        default: baseSize = 22         // iPhone Pro Max
        }
        return min(baseSize, geometry.size.width * 0.055)
    }
    
    private func bodyFontSize(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        let baseSize: CGFloat
        switch screenHeight {
        case 0...667: baseSize = 14    // iPhone SE, 8
        case 668...844: baseSize = 15  // iPhone 12 mini, 13 mini
        case 845...926: baseSize = 16  // iPhone 12, 13, 14, 15
        default: baseSize = 17         // iPhone Pro Max
        }
        return min(baseSize, geometry.size.width * 0.045)
    }
    
    // MARK: - iPhone-Optimized Visual Components
    @ViewBuilder
    private func iPhoneOptimizedIconView(iconName: String, iconColor: Color, geometry: GeometryProxy) -> some View {
        let iconSize: CGFloat = adaptiveIconSize(for: geometry)
        
        ZStack {
            // Subtle pulse rings
            ForEach(0..<2, id: \.self) { index in
                Circle()
                    .stroke(iconColor.opacity(0.15 - Double(index) * 0.05), lineWidth: 1.5)
                    .frame(width: iconSize + CGFloat(index * 16), height: iconSize + CGFloat(index * 16))
                    .scaleEffect(hasAnimation ? 1.0 + sin(Date().timeIntervalSince1970 + Double(index)) * 0.03 : 1.0)
            }
            
            // Modern card background
            RoundedRectangle(cornerRadius: iconSize * 0.25)
                .fill(.ultraThinMaterial)
                .frame(width: iconSize, height: iconSize)
                .overlay(
                    RoundedRectangle(cornerRadius: iconSize * 0.25)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    iconColor.opacity(0.2),
                                    iconColor.opacity(0.05)
                                ]),
                                center: .center,
                                startRadius: 10,
                                endRadius: iconSize * 0.6
                            )
                        )
                )
                .shadow(color: iconColor.opacity(0.2), radius: 12, x: 0, y: 6)
            
            // Icon
            Image(systemName: iconName)
                .font(.system(size: iconSize * 0.35, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [iconColor, iconColor.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
    
    private func adaptiveIconSize(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        switch screenHeight {
        case 0...667: return 80    // iPhone SE
        case 668...844: return 100 // iPhone 12 mini, regular
        default: return 120        // iPhone Pro Max
        }
    }
    
    @ViewBuilder
    private func iPhoneSocialMediaComparisonView() -> some View {
        HStack(spacing: 12) {
            VStack(spacing: 6) {
                Text("Generic")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.red)
                
                CompactInstagramPost(
                    caption: "Check this out",
                    likes: 23,
                    isOptimized: false
                )
            }
            
            VStack(spacing: 6) {
                Text("Optimized")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.green)
                
                CompactInstagramPost(
                    caption: "🔥 Mind-blowing discovery! ✨",
                    likes: 1247,
                    isOptimized: true
                )
            }
        }
    }
    
    @ViewBuilder
    private func iPhonePlatformShowcaseView() -> some View {
        let platforms: [SocialMediaPlatform] = [.instagram, .linkedin, .tiktok, .twitter, .facebook, .discord]
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
            ForEach(Array(platforms.enumerated()), id: \.offset) { index, platform in
                SocialMediaIconView(platform: platform, size: 45)
                    .scaleEffect(hasAnimation ? 1.0 : 0.8)
                    .opacity(hasAnimation ? 1.0 : 0.6)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.8)
                        .delay(Double(index) * 0.1),
                        value: hasAnimation
                    )
            }
        }
    }
    
    @ViewBuilder
    private func iPhoneEngagementMetricsView(hasAnimation: Bool) -> some View {
        HStack(spacing: 16) {
            CompactMetricCard(
                icon: "eye.fill",
                value: hasAnimation ? 340 : 0,
                suffix: "%",
                label: "Views",
                color: .blue
            )
            
            CompactMetricCard(
                icon: "heart.fill",
                value: hasAnimation ? 250 : 0,
                suffix: "%",
                label: "Likes",
                color: .red
            )
            
            CompactMetricCard(
                icon: "arrowshape.turn.up.right.fill",
                value: hasAnimation ? 180 : 0,
                suffix: "%",
                label: "Shares",
                color: .green
            )
        }
    }
    
    @ViewBuilder
    private func iconView(iconName: String, iconColor: Color, geometry: GeometryProxy) -> some View {
        ZStack {
            // Multiple pulse rings for more depth
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .stroke(iconColor.opacity(0.3 - Double(index) * 0.05), lineWidth: 2)
                    .frame(width: CGFloat(180 + index * 15), height: CGFloat(180 + index * 15))
                    .scaleEffect(1.0 + sin(Date().timeIntervalSince1970 + Double(index) * 0.5) * 0.02)
                    .animation(
                        .easeInOut(duration: 2.0 + Double(index) * 0.3)
                        .repeatForever(autoreverses: true),
                        value: Date().timeIntervalSince1970
                    )
            }
            
            // Main icon background with gradient
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            iconColor.opacity(0.3),
                            iconColor.opacity(0.1),
                            iconColor.opacity(0.05)
                        ]),
                        center: .center,
                        startRadius: 30,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .shadow(color: iconColor.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // Icon with enhanced shadow
            Image(systemName: iconName)
                .font(.system(size: 60, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [iconColor, iconColor.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: iconColor.opacity(0.5), radius: 8, x: 0, y: 4)
        }
    }
}

enum OnboardingContentType {
    case icon(name: String, color: Color)
    case customView(AnyView)
    case socialMediaComparison
    case platformShowcase
    case engagementMetrics
}

struct OnboardingData {
    let title: String
    let subtitle: String
    let description: String
    let contentType: OnboardingContentType
    let hasAnimation: Bool
    
    // Convenience initializers for backward compatibility
    init(title: String, subtitle: String, description: String, iconName: String, iconColor: Color, hasAnimation: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.contentType = .icon(name: iconName, color: iconColor)
        self.hasAnimation = hasAnimation
    }
    
    init(title: String, subtitle: String, description: String, contentType: OnboardingContentType, hasAnimation: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.contentType = contentType
        self.hasAnimation = hasAnimation
    }
    
    static let pages: [OnboardingData] = [
        // Page 1: Welcome & Hook
        OnboardingData(
            title: "Your Voice\nHas Power",
            subtitle: "Let's Make It Viral",
            description: "Transform your voice into viral content across all platforms.",
            iconName: "megaphone.fill",
            iconColor: .blue,
            hasAnimation: true
        ),
        
        // Page 2: The Problem
        OnboardingData(
            title: "Same Message,\nDifferent Results?",
            subtitle: "Platform Optimization Matters",
            description: "See how the same content performs differently across platforms.",
            contentType: .socialMediaComparison,
            hasAnimation: true
        ),
        
        // Page 3: Social Proof with Examples
        OnboardingData(
            title: "54x More\nEngagement",
            subtitle: "Optimized Content Works",
            description: "AI-optimized content dramatically outperforms generic posts.",
            contentType: .engagementMetrics,
            hasAnimation: true
        ),
        
        // Page 4: Recording Process
        OnboardingData(
            title: "Just Speak\nNaturally",
            subtitle: "Any Language, Any Topic",
            description: "No scripts needed. Speak in 50+ languages with AI understanding.",
            iconName: "waveform.and.mic",
            iconColor: .green,
            hasAnimation: true
        ),
        
        // Page 5: AI Magic
        OnboardingData(
            title: "AI Does the\nHeavy Lifting",
            subtitle: "Smart Analysis & Creation",
            description: "AI analyzes your speech and creates platform-specific content.",
            iconName: "brain.head.profile",
            iconColor: .purple,
            hasAnimation: true
        ),
        
        // Page 6: Platform Showcase
        OnboardingData(
            title: "12 Platforms,\nPerfect Fit",
            subtitle: "Professional to Personal",
            description: "Each platform gets content tailored to its unique audience.",
            contentType: .platformShowcase,
            hasAnimation: true
        ),
        
        // Page 7: Results Preview
        OnboardingData(
            title: "Watch Your\nEngagement Soar",
            subtitle: "More Views, More Success",
            description: "Users see 340% more views and 250% more engagement.",
            iconName: "chart.line.uptrend.xyaxis",
            iconColor: .green,
            hasAnimation: true
        ),
        
        // Page 8: Call to Action
        OnboardingData(
            title: "Ready to\nGo Viral?",
            subtitle: "Your Audience Awaits",
            description: "Join thousands of creators who've transformed their social media.",
            iconName: "rocket.fill",
            iconColor: .orange,
            hasAnimation: true
        )
    ]
}

#Preview {
    let page = OnboardingData.pages[0]
    return OnboardingPageView(
        title: page.title,
        subtitle: page.subtitle,
        description: page.description,
        contentType: page.contentType,
        backgroundGradient: LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        hasAnimation: page.hasAnimation
    )
}