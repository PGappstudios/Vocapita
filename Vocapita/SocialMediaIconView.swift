import SwiftUI

struct SlackIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Create Slack's hashtag-like shape with rounded corners
        let thickness = width * 0.15
        let _ = width * 0.25 // spacing for potential future use
        
        // Horizontal bars
        path.addRoundedRect(
            in: CGRect(x: 0, y: height * 0.3, width: width, height: thickness),
            cornerSize: CGSize(width: thickness/2, height: thickness/2)
        )
        path.addRoundedRect(
            in: CGRect(x: 0, y: height * 0.55, width: width, height: thickness),
            cornerSize: CGSize(width: thickness/2, height: thickness/2)
        )
        
        // Vertical bars
        path.addRoundedRect(
            in: CGRect(x: width * 0.3, y: 0, width: thickness, height: height),
            cornerSize: CGSize(width: thickness/2, height: thickness/2)
        )
        path.addRoundedRect(
            in: CGRect(x: width * 0.55, y: 0, width: thickness, height: height),
            cornerSize: CGSize(width: thickness/2, height: thickness/2)
        )
        
        return path
    }
}

struct EmailIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Envelope body
        path.addRoundedRect(
            in: CGRect(x: 0, y: height * 0.2, width: width, height: height * 0.6),
            cornerSize: CGSize(width: height * 0.05, height: height * 0.05)
        )
        
        // Envelope flap
        path.move(to: CGPoint(x: 0, y: height * 0.2))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.6))
        path.addLine(to: CGPoint(x: width, y: height * 0.2))
        
        return path
    }
}

struct MessagesIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Speech bubble with tail
        let bubbleHeight = height * 0.75
        let bubbleWidth = width * 0.9
        let cornerRadius = bubbleHeight * 0.2
        
        // Main bubble
        path.addRoundedRect(
            in: CGRect(x: width * 0.05, y: 0, width: bubbleWidth, height: bubbleHeight),
            cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
        )
        
        // Tail
        path.move(to: CGPoint(x: width * 0.2, y: bubbleHeight))
        path.addLine(to: CGPoint(x: width * 0.1, y: height))
        path.addLine(to: CGPoint(x: width * 0.35, y: bubbleHeight))
        path.closeSubpath()
        
        return path
    }
}

struct TeamsIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Microsoft Teams "T" shape
        let strokeWidth = width * 0.15
        
        // Horizontal bar of T
        path.addRoundedRect(
            in: CGRect(x: 0, y: height * 0.1, width: width, height: strokeWidth),
            cornerSize: CGSize(width: strokeWidth/2, height: strokeWidth/2)
        )
        
        // Vertical bar of T
        path.addRoundedRect(
            in: CGRect(x: width * 0.425, y: height * 0.1, width: strokeWidth, height: height * 0.8),
            cornerSize: CGSize(width: strokeWidth/2, height: strokeWidth/2)
        )
        
        return path
    }
}

struct DiscordIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Discord's characteristic controller/headset shape
        let bodyWidth = width * 0.8
        let bodyHeight = height * 0.6
        let bodyX = width * 0.1
        let bodyY = height * 0.2
        
        // Main body (rounded rectangle)
        path.addRoundedRect(
            in: CGRect(x: bodyX, y: bodyY, width: bodyWidth, height: bodyHeight),
            cornerSize: CGSize(width: bodyHeight * 0.3, height: bodyHeight * 0.3)
        )
        
        // Left "ear" or controller grip
        path.addEllipse(in: CGRect(
            x: bodyX - width * 0.08,
            y: bodyY + bodyHeight * 0.2,
            width: width * 0.15,
            height: bodyHeight * 0.4
        ))
        
        // Right "ear" or controller grip
        path.addEllipse(in: CGRect(
            x: bodyX + bodyWidth - width * 0.07,
            y: bodyY + bodyHeight * 0.2,
            width: width * 0.15,
            height: bodyHeight * 0.4
        ))
        
        return path
    }
}

struct WhatsAppIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Speech bubble with phone icon inside
        let bubbleWidth = width * 0.85
        let bubbleHeight = height * 0.7
        let bubbleX = width * 0.075
        let bubbleY = height * 0.1
        
        // Main speech bubble
        path.addRoundedRect(
            in: CGRect(x: bubbleX, y: bubbleY, width: bubbleWidth, height: bubbleHeight),
            cornerSize: CGSize(width: bubbleHeight * 0.25, height: bubbleHeight * 0.25)
        )
        
        // Tail of the speech bubble
        path.move(to: CGPoint(x: bubbleX + bubbleWidth * 0.15, y: bubbleY + bubbleHeight))
        path.addLine(to: CGPoint(x: bubbleX, y: height * 0.9))
        path.addLine(to: CGPoint(x: bubbleX + bubbleWidth * 0.3, y: bubbleY + bubbleHeight))
        path.closeSubpath()
        
        // Phone handset shape inside the bubble
        let phoneWidth = bubbleWidth * 0.4
        let phoneHeight = bubbleHeight * 0.6
        let phoneX = bubbleX + (bubbleWidth - phoneWidth) / 2
        let phoneY = bubbleY + (bubbleHeight - phoneHeight) / 2
        
        // Phone receiver (curved shape)
        path.move(to: CGPoint(x: phoneX + phoneWidth * 0.2, y: phoneY))
        path.addCurve(
            to: CGPoint(x: phoneX + phoneWidth * 0.8, y: phoneY + phoneHeight),
            control1: CGPoint(x: phoneX + phoneWidth * 0.7, y: phoneY + phoneHeight * 0.2),
            control2: CGPoint(x: phoneX + phoneWidth * 0.3, y: phoneY + phoneHeight * 0.8)
        )
        path.addCurve(
            to: CGPoint(x: phoneX + phoneWidth * 0.2, y: phoneY),
            control1: CGPoint(x: phoneX + phoneWidth * 0.6, y: phoneY + phoneHeight * 0.9),
            control2: CGPoint(x: phoneX + phoneWidth * 0.4, y: phoneY + phoneHeight * 0.1)
        )
        
        return path
    }
}

struct TikTokIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Create the TikTok musical note/stylized "d" shape
        // Main body of the note
        let centerX = width * 0.35
        let centerY = height * 0.7
        let radius = width * 0.15
        
        // Add the circular part (note head)
        path.addEllipse(in: CGRect(
            x: centerX - radius,
            y: centerY - radius,
            width: radius * 2,
            height: radius * 2
        ))
        
        // Add the stem going up
        let stemWidth = width * 0.08
        let stemHeight = height * 0.55
        path.addRoundedRect(
            in: CGRect(
                x: centerX + radius - stemWidth/2,
                y: centerY - stemHeight,
                width: stemWidth,
                height: stemHeight
            ),
            cornerSize: CGSize(width: stemWidth/2, height: stemWidth/2)
        )
        
        // Add the characteristic curve at the top
        let curveStartX = centerX + radius - stemWidth/2
        let curveStartY = centerY - stemHeight
        
        path.move(to: CGPoint(x: curveStartX, y: curveStartY))
        path.addCurve(
            to: CGPoint(x: width * 0.75, y: height * 0.25),
            control1: CGPoint(x: width * 0.55, y: curveStartY),
            control2: CGPoint(x: width * 0.75, y: height * 0.35)
        )
        
        path.addCurve(
            to: CGPoint(x: width * 0.65, y: height * 0.15),
            control1: CGPoint(x: width * 0.75, y: height * 0.2),
            control2: CGPoint(x: width * 0.7, y: height * 0.15)
        )
        
        path.addCurve(
            to: CGPoint(x: curveStartX + stemWidth, y: curveStartY),
            control1: CGPoint(x: width * 0.6, y: height * 0.15),
            control2: CGPoint(x: width * 0.5, y: curveStartY)
        )
        
        return path
    }
}

struct SocialMediaIconView: View {
    let platform: SocialMediaPlatform
    let size: CGFloat
    
    init(platform: SocialMediaPlatform, size: CGFloat = 40) {
        self.platform = platform
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(platform.primaryColor)
                .frame(width: size, height: size)
            
            // Custom icon design for each platform
            switch platform {
            case .facebook:
                Text("f")
                    .font(.system(size: size * 0.6, weight: .bold))
                    .foregroundColor(.white)
                
            case .instagram:
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.2)
                        .stroke(Color.white, lineWidth: size * 0.08)
                        .frame(width: size * 0.7, height: size * 0.7)
                    
                    Circle()
                        .stroke(Color.white, lineWidth: size * 0.06)
                        .frame(width: size * 0.35, height: size * 0.35)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: size * 0.12, height: size * 0.12)
                        .offset(x: size * 0.2, y: -size * 0.2)
                }
                
            case .twitter:
                // Twitter bird shape approximation
                Text("𝕏")
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundColor(.white)
                
            case .threads:
                Text("@")
                    .font(.system(size: size * 0.6, weight: .bold))
                    .foregroundColor(.white)
                
            case .tiktok:
                ZStack {
                    // Create the layered effect characteristic of TikTok logo
                    // Red/Pink layer (shadow effect)
                    TikTokIconShape()
                        .fill(Color(red: 1.0, green: 0.04, blue: 0.29))
                        .frame(width: size * 0.6, height: size * 0.7)
                        .offset(x: -1, y: 1)
                    
                    // Cyan layer (shadow effect)
                    TikTokIconShape()
                        .fill(Color.cyan)
                        .frame(width: size * 0.6, height: size * 0.7)
                        .offset(x: 1, y: -1)
                    
                    // Main white layer (foreground)
                    TikTokIconShape()
                        .fill(Color.white)
                        .frame(width: size * 0.6, height: size * 0.7)
                }
                
            case .linkedin:
                Text("in")
                    .font(.system(size: size * 0.35, weight: .bold))
                    .foregroundColor(.white)
            
            case .slack:
                SlackIconShape()
                    .fill(Color.white)
                    .frame(width: size * 0.65, height: size * 0.65)
            
            case .email:
                EmailIconShape()
                    .fill(Color.white)
                    .frame(width: size * 0.7, height: size * 0.5)
            
            case .iosMessages:
                MessagesIconShape()
                    .fill(Color.white)
                    .frame(width: size * 0.7, height: size * 0.6)
            
            case .microsoftTeams:
                TeamsIconShape()
                    .fill(Color.white)
                    .frame(width: size * 0.6, height: size * 0.6)
            
            case .discord:
                DiscordIconShape()
                    .fill(Color.white)
                    .frame(width: size * 0.7, height: size * 0.6)
            
            case .whatsapp:
                WhatsAppIconShape()
                    .fill(Color.white)
                    .frame(width: size * 0.7, height: size * 0.7)
            }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        ForEach(SocialMediaPlatform.allCases) { platform in
            SocialMediaIconView(platform: platform, size: 60)
        }
    }
    .padding()
}