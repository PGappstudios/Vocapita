import Foundation
import SwiftUI

enum SocialMediaPlatform: String, CaseIterable, Identifiable {
    case facebook = "facebook"
    case instagram = "instagram"
    case twitter = "twitter"
    case threads = "threads"
    case tiktok = "tiktok"
    case linkedin = "linkedin"
    case slack = "slack"
    case email = "email"
    case iosMessages = "iosMessages"
    case microsoftTeams = "microsoftTeams"
    case discord = "discord"
    case whatsapp = "whatsapp"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .facebook: return "Facebook"
        case .instagram: return "Instagram"
        case .twitter: return "Twitter/X"
        case .threads: return "Threads"
        case .tiktok: return "TikTok"
        case .linkedin: return "LinkedIn"
        case .slack: return "Slack"
        case .email: return "Email"
        case .iosMessages: return "Messages"
        case .microsoftTeams: return "Microsoft Teams"
        case .discord: return "Discord"
        case .whatsapp: return "WhatsApp"
        }
    }
    
    var iconName: String {
        switch self {
        case .facebook: return "facebook-icon"
        case .instagram: return "instagram-icon"
        case .twitter: return "twitter-icon"
        case .threads: return "threads-icon"
        case .tiktok: return "tiktok-icon"
        case .linkedin: return "linkedin-icon"
        case .slack: return "slack-icon"
        case .email: return "email-icon"
        case .iosMessages: return "messages-icon"
        case .microsoftTeams: return "teams-icon"
        case .discord: return "discord-icon"
        case .whatsapp: return "whatsapp-icon"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .facebook: return Color(red: 0.23, green: 0.35, blue: 0.60)
        case .instagram: return Color(red: 0.83, green: 0.31, blue: 0.55)
        case .twitter: return Color(red: 0.11, green: 0.63, blue: 0.95)
        case .threads: return Color.black
        case .tiktok: return Color(red: 1.0, green: 0.04, blue: 0.29)
        case .linkedin: return Color(red: 0.11, green: 0.42, blue: 0.68)
        case .slack: return Color(red: 0.44, green: 0.06, blue: 0.74)
        case .email: return Color(red: 0.0, green: 0.48, blue: 0.80)
        case .iosMessages: return Color(red: 0.0, green: 0.78, blue: 0.25)
        case .microsoftTeams: return Color(red: 0.38, green: 0.36, blue: 0.80)
        case .discord: return Color(red: 0.35, green: 0.4, blue: 0.98)
        case .whatsapp: return Color(red: 0.15, green: 0.68, blue: 0.38)
        }
    }
    
    var characterLimit: Int {
        switch self {
        case .facebook: return 63206
        case .instagram: return 2200
        case .twitter: return 280
        case .threads: return 500
        case .tiktok: return 2200
        case .linkedin: return 3000
        case .slack: return 40000
        case .email: return 10000
        case .iosMessages: return 1000
        case .microsoftTeams: return 4000
        case .discord: return 2000
        case .whatsapp: return 4096
        }
    }
    
    var recommendedHashtags: Int {
        switch self {
        case .facebook: return 3
        case .instagram: return 15
        case .twitter: return 2
        case .threads: return 5
        case .tiktok: return 10
        case .linkedin: return 3
        case .slack: return 0
        case .email: return 0
        case .iosMessages: return 0
        case .microsoftTeams: return 0
        case .discord: return 0
        case .whatsapp: return 0
        }
    }
    
    var tone: String {
        switch self {
        case .facebook: return "casual and engaging"
        case .instagram: return "visual storytelling with emojis"
        case .twitter: return "concise and witty"
        case .threads: return "conversational and interactive"
        case .tiktok: return "trendy and energetic with Gen Z language"
        case .linkedin: return "professional and business-focused"
        case .slack: return "collaborative and team-focused"
        case .email: return "professional and clear"
        case .iosMessages: return "casual and friendly"
        case .microsoftTeams: return "professional and collaborative"
        case .discord: return "casual gaming and community-focused"
        case .whatsapp: return "casual and personal messaging"
        }
    }
    
    var urlScheme: String {
        switch self {
        case .facebook: return "fb://publish/text"
        case .instagram: return "instagram://camera"
        case .twitter: return "twitter://post"
        case .threads: return "threads://compose"
        case .tiktok: return "tiktok://upload"
        case .linkedin: return "linkedin://compose"
        case .slack: return "slack://open"
        case .email: return "mailto:"
        case .iosMessages: return "sms:"
        case .microsoftTeams: return "msteams://compose"
        case .discord: return "discord://open"
        case .whatsapp: return "whatsapp://send"
        }
    }
    
    var webURL: String {
        switch self {
        case .facebook: return "https://www.facebook.com"
        case .instagram: return "https://www.instagram.com"
        case .twitter: return "https://twitter.com/compose/tweet"
        case .threads: return "https://www.threads.net"
        case .tiktok: return "https://www.tiktok.com/upload"
        case .linkedin: return "https://www.linkedin.com/feed"
        case .slack: return "https://app.slack.com"
        case .email: return "https://mail.google.com/mail/u/0/#inbox?compose=new"
        case .iosMessages: return "https://messages.apple.com"
        case .microsoftTeams: return "https://teams.microsoft.com"
        case .discord: return "https://discord.com/channels/@me"
        case .whatsapp: return "https://web.whatsapp.com"
        }
    }
    
    var description: String {
        switch self {
        case .facebook: return "Personal & engaging posts"
        case .instagram: return "Visual stories & hashtags"
        case .twitter: return "Quick & impactful tweets"
        case .threads: return "Conversational content"
        case .tiktok: return "Trendy & viral content"
        case .linkedin: return "Professional networking"
        case .slack: return "Team collaboration"
        case .email: return "Professional communication"
        case .iosMessages: return "Text messaging"
        case .microsoftTeams: return "Business communication"
        case .discord: return "Gaming & community chat"
        case .whatsapp: return "Personal messaging"
        }
    }
}

struct CaptionStyle {
    let platform: SocialMediaPlatform
    let tone: String
    let characterLimit: Int
    let hashtagCount: Int
    let specialInstructions: String
    
    static func style(for platform: SocialMediaPlatform) -> CaptionStyle {
        switch platform {
        case .facebook:
            return CaptionStyle(
                platform: platform,
                tone: "casual, engaging, and personal",
                characterLimit: platform.characterLimit,
                hashtagCount: platform.recommendedHashtags,
                specialInstructions: "Create engaging content that encourages comments and shares. Use a conversational tone and include a call-to-action."
            )
        case .instagram:
            return CaptionStyle(
                platform: platform,
                tone: "visual storytelling with emojis",
                characterLimit: platform.characterLimit,
                hashtagCount: platform.recommendedHashtags,
                specialInstructions: "Focus on visual storytelling. Include relevant emojis and trending hashtags. Make it Instagram-aesthetic friendly."
            )
        case .twitter:
            return CaptionStyle(
                platform: platform,
                tone: "concise, witty, and impactful",
                characterLimit: platform.characterLimit,
                hashtagCount: platform.recommendedHashtags,
                specialInstructions: "Keep it under 280 characters. Be concise but impactful. Use Twitter-style language and relevant hashtags."
            )
        case .threads:
            return CaptionStyle(
                platform: platform,
                tone: "conversational and interactive",
                characterLimit: platform.characterLimit,
                hashtagCount: platform.recommendedHashtags,
                specialInstructions: "Create conversational content that encourages replies. End with questions or discussion starters."
            )
        case .tiktok:
            return CaptionStyle(
                platform: platform,
                tone: "trendy, energetic with Gen Z language",
                characterLimit: platform.characterLimit,
                hashtagCount: platform.recommendedHashtags,
                specialInstructions: "Use trending slang, viral hashtags, and energetic language. Include call-to-actions like 'like if you agree' or 'share this with friends'."
            )
        case .linkedin:
            return CaptionStyle(
                platform: platform,
                tone: "professional and business-focused",
                characterLimit: platform.characterLimit,
                hashtagCount: platform.recommendedHashtags,
                specialInstructions: "Maintain professional tone. Include industry keywords and business insights. Focus on value and professional growth."
            )
        case .slack:
            return CaptionStyle(
                platform: platform,
                tone: "collaborative and team-focused",
                characterLimit: platform.characterLimit,
                hashtagCount: platform.recommendedHashtags,
                specialInstructions: "Create clear, actionable team communication. Use @mentions when appropriate. Focus on collaboration and getting things done."
            )
        case .email:
            return CaptionStyle(
                platform: platform,
                tone: "professional and clear",
                characterLimit: platform.characterLimit,
                hashtagCount: platform.recommendedHashtags,
                specialInstructions: "Structure as professional email with clear subject suggestion. Use formal but approachable tone. Include clear call-to-action."
            )
        case .iosMessages:
            return CaptionStyle(
                platform: platform,
                tone: "casual and friendly",
                characterLimit: platform.characterLimit,
                hashtagCount: platform.recommendedHashtags,
                specialInstructions: "Keep it concise and conversational. Use emojis sparingly. Write like you're texting a friend."
            )
        case .microsoftTeams:
            return CaptionStyle(
                platform: platform,
                tone: "professional and collaborative",
                characterLimit: platform.characterLimit,
                hashtagCount: platform.recommendedHashtags,
                specialInstructions: "Professional team communication. Use @mentions for specific team members. Focus on clarity and actionable items."
            )
        case .discord:
            return CaptionStyle(
                platform: platform,
                tone: "casual gaming and community-focused",
                characterLimit: platform.characterLimit,
                hashtagCount: platform.recommendedHashtags,
                specialInstructions: "Use gaming terminology and community language. Include emojis and casual tone. Perfect for server announcements or community engagement."
            )
        case .whatsapp:
            return CaptionStyle(
                platform: platform,
                tone: "casual and personal messaging",
                characterLimit: platform.characterLimit,
                hashtagCount: platform.recommendedHashtags,
                specialInstructions: "Keep it personal and conversational. Write like you're messaging family or close friends. Use emojis naturally and keep tone warm and friendly."
            )
        }
    }
}