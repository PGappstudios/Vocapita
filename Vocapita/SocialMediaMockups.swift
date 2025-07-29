import SwiftUI

// MARK: - Instagram Post Mockup
struct InstagramPostMockup: View {
    let caption: String
    let engagement: EngagementMetrics
    let isOptimized: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Circle()
                    .fill(LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            )
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("yourhandle")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                    Text("Sponsored")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Image placeholder
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: isOptimized ? 
                            [Color.blue.opacity(0.3), Color.purple.opacity(0.3)] :
                            [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: isOptimized ? "photo.fill" : "photo")
                            .font(.system(size: 40))
                            .foregroundColor(isOptimized ? .blue : .gray)
                        Text(isOptimized ? "Engaging Visual" : "Generic Image")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                )
            
            // Action buttons
            HStack(spacing: 16) {
                Image(systemName: "heart")
                    .font(.system(size: 24))
                Image(systemName: "message")
                    .font(.system(size: 24))
                Image(systemName: "paperplane")
                    .font(.system(size: 24))
                
                Spacer()
                
                Image(systemName: "bookmark")
                    .font(.system(size: 24))
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Engagement
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(engagement.likes.formatted()) likes")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                }
                
                Text(caption)
                    .font(.system(size: 14))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text("View all \(engagement.comments) comments")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - LinkedIn Post Mockup
struct LinkedInPostMockup: View {
    let content: String
    let engagement: EngagementMetrics
    let isOptimized: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text("YN")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Name")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Marketing Professional • 1st")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("2h • 🌍")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Content
            Text(content)
                .font(.system(size: 15))
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            
            // Engagement bar
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.white)
                        )
                    Text("\(engagement.likes)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(engagement.comments) comments • \(engagement.shares) reposts")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            Divider()
            
            // Action buttons
            HStack {
                LinkedInActionButton(icon: "hand.thumbsup", text: "Like")
                LinkedInActionButton(icon: "message", text: "Comment")
                LinkedInActionButton(icon: "arrowshape.turn.up.right", text: "Repost")
                LinkedInActionButton(icon: "paperplane", text: "Send")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - TikTok Post Mockup
struct TikTokPostMockup: View {
    let caption: String
    let engagement: EngagementMetrics
    let isOptimized: Bool
    
    var body: some View {
        ZStack {
            // Video background
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: isOptimized ? 
                            [Color.pink.opacity(0.6), Color.purple.opacity(0.8)] :
                            [Color.gray.opacity(0.4), Color.gray.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 300)
            
            VStack {
                Spacer()
                
                // Bottom content overlay
                VStack(alignment: .leading, spacing: 8) {
                    // Profile info
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            )
                        
                        Text("@yourhandle")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    // Caption
                    Text(caption)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .lineLimit(3)
                    
                    // Music
                    HStack(spacing: 4) {
                        Image(systemName: "music.note")
                            .font(.system(size: 12))
                        Text("Original Sound - yourhandle")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
            }
            
            // Side actions
            VStack(spacing: 16) {
                Spacer()
                
                VStack(spacing: 20) {
                    TikTokActionButton(icon: "heart.fill", count: engagement.likes, color: .red)
                    TikTokActionButton(icon: "message.fill", count: engagement.comments, color: .white)
                    TikTokActionButton(icon: "arrowshape.turn.up.right.fill", count: engagement.shares, color: .white)
                }
                .padding(.trailing, 12)
                .padding(.bottom, 60)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(width: 200, height: 300)
    }
}

// MARK: - Twitter Post Mockup
struct TwitterPostMockup: View {
    let content: String
    let engagement: EngagementMetrics
    let isOptimized: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("YN")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("Your Name")
                            .font(.system(size: 15, weight: .bold))
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        Text("@yourhandle")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        Text("• 2h")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(content)
                        .font(.system(size: 15))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(1)
                    
                    // Action buttons
                    HStack(spacing: 40) {
                        TwitterActionButton(icon: "message", count: engagement.comments)
                        TwitterActionButton(icon: "arrowshape.turn.up.right", count: engagement.shares)
                        TwitterActionButton(icon: "heart", count: engagement.likes)
                        TwitterActionButton(icon: "square.and.arrow.up", count: 0)
                    }
                    .padding(.top, 8)
                }
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Supporting Components
struct EngagementMetrics {
    let likes: Int
    let comments: Int
    let shares: Int
}

struct LinkedInActionButton: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 12))
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(.secondary)
    }
}

struct TikTokActionButton: View {
    let icon: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                )
            
            Text("\(count.formatted(.number.notation(.compactName)))")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

struct TwitterActionButton: View {
    let icon: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 12))
            }
        }
        .foregroundColor(.secondary)
    }
}

// MARK: - Onboarding Specialized Views
struct SocialMediaComparisonView: View {
    @State private var showOptimized = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Generic Post")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                    
                    InstagramPostMockup(
                        caption: "Check out my product",
                        engagement: EngagementMetrics(likes: 23, comments: 2, shares: 1),
                        isOptimized: false
                    )
                    .scaleEffect(0.7)
                }
                
                VStack(spacing: 8) {
                    Text("Optimized Post")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                    
                    InstagramPostMockup(
                        caption: "🔥 This game-changing discovery will blow your mind! Can't believe I waited so long to try this... ✨ #GameChanger",
                        engagement: EngagementMetrics(likes: 1247, comments: 89, shares: 156),
                        isOptimized: true
                    )
                    .scaleEffect(0.7)
                }
            }
            
            VStack(spacing: 8) {
                Text("54x More Engagement!")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.green)
                
                Text("Platform-optimized content gets dramatically better results")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showOptimized = true
                }
            }
        }
    }
}

struct PlatformShowcaseView: View {
    let platforms: [SocialMediaPlatform] = [.instagram, .linkedin, .tiktok, .twitter, .facebook, .discord]
    @State private var animateIcons = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("12 Platforms Supported")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(Array(platforms.enumerated()), id: \.offset) { index, platform in
                    SocialMediaIconView(platform: platform, size: 50)
                        .scaleEffect(animateIcons ? 1.0 : 0.8)
                        .opacity(animateIcons ? 1.0 : 0.6)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1),
                            value: animateIcons
                        )
                }
            }
            
            Text("Each platform gets perfectly tailored content")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            withAnimation {
                animateIcons = true
            }
        }
    }
}

struct EngagementMetricsView: View {
    let hasAnimation: Bool
    @State private var animateNumbers = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Real Results")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            HStack(spacing: 32) {
                MetricCard(
                    icon: "eye.fill",
                    value: animateNumbers ? 340 : 0,
                    suffix: "%",
                    label: "More Views",
                    color: .blue
                )
                
                MetricCard(
                    icon: "heart.fill",
                    value: animateNumbers ? 250 : 0,
                    suffix: "%",
                    label: "More Likes",
                    color: .red
                )
                
                MetricCard(
                    icon: "arrowshape.turn.up.right.fill",
                    value: animateNumbers ? 180 : 0,
                    suffix: "%",
                    label: "More Shares",
                    color: .green
                )
            }
            
            Text("Platform-specific content dramatically increases engagement")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .onAppear {
            if hasAnimation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 1.5)) {
                        animateNumbers = true
                    }
                }
            } else {
                animateNumbers = true
            }
        }
    }
}

struct MetricCard: View {
    let icon: String
    let value: Int
    let suffix: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text("\(value)\(suffix)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - iPhone-Optimized Compact Components
struct CompactInstagramPost: View {
    let caption: String
    let likes: Int
    let isOptimized: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Mini header
            HStack(spacing: 6) {
                Circle()
                    .fill(isOptimized ? Color.blue : Color.gray)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                    )
                
                Text("user")
                    .font(.system(size: 10, weight: .semibold))
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.top, 6)
            
            // Image placeholder
            Rectangle()
                .fill(
                    isOptimized ? 
                    LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                    LinearGradient(colors: [.gray.opacity(0.2), .gray.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(height: 80)
                .overlay(
                    Image(systemName: isOptimized ? "photo.fill" : "photo")
                        .font(.system(size: 20))
                        .foregroundColor(isOptimized ? .blue : .gray)
                )
            
            // Mini engagement
            HStack {
                HStack(spacing: 3) {
                    Image(systemName: "heart")
                        .font(.system(size: 10))
                    Image(systemName: "message")
                        .font(.system(size: 10))
                }
                .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            
            // Likes and caption
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("\(likes) likes")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(isOptimized ? .green : .red)
                    Spacer()
                }
                
                Text(caption)
                    .font(.system(size: 8))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 6)
        }
        .frame(width: 140, height: 160)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct CompactMetricCard: View {
    let icon: String
    let value: Int
    let suffix: String
    let label: String
    let color: Color
    @State private var animatedValue: Int = 0
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            Text("\(animatedValue)\(suffix)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
                .monospacedDigit()
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(width: 80, height: 70)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
        .onAppear {
            if value > 0 {
                withAnimation(.easeOut(duration: 1.5)) {
                    animatedValue = value
                }
            }
        }
        .onChange(of: value) { _, newValue in
            withAnimation(.easeOut(duration: 1.5)) {
                animatedValue = newValue
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            InstagramPostMockup(
                caption: "Just discovered the secret to perfect social media content! ✨ #ContentCreator #SocialMedia",
                engagement: EngagementMetrics(likes: 1247, comments: 89, shares: 156),
                isOptimized: true
            )
            
            LinkedInPostMockup(
                content: "After analyzing 1000+ successful social media campaigns, I discovered that platform-specific content increases engagement by 340%. Here's what most creators get wrong...",
                engagement: EngagementMetrics(likes: 892, comments: 45, shares: 67),
                isOptimized: true
            )
            
            HStack(spacing: 20) {
                TikTokPostMockup(
                    caption: "POV: You finally understand why your content isn't going viral 🤯 #ContentTips #Viral",
                    engagement: EngagementMetrics(likes: 15600, comments: 892, shares: 2341),
                    isOptimized: true
                )
                
                TwitterPostMockup(
                    content: "🧵 Thread: Why your content isn't getting engagement (and how to fix it)\n\n1/ Most creators make this critical mistake...",
                    engagement: EngagementMetrics(likes: 456, comments: 78, shares: 234),
                    isOptimized: true
                )
            }
        }
        .padding()
    }
}