import Foundation
import UIKit

class SocialMediaManager {
    static let shared = SocialMediaManager()
    
    private init() {}
    
    func openApp(for platform: SocialMediaPlatform) {
        guard let url = URL(string: platform.urlScheme) else {
            openWebVersion(for: platform)
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                if !success {
                    self.openWebVersion(for: platform)
                }
            }
        } else {
            openWebVersion(for: platform)
        }
    }
    
    private func openWebVersion(for platform: SocialMediaPlatform) {
        guard let webURL = URL(string: platform.webURL) else { return }
        UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
    }
    
    func isAppInstalled(for platform: SocialMediaPlatform) -> Bool {
        guard let url = URL(string: platform.urlScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func getAppStatus(for platform: SocialMediaPlatform) -> AppStatus {
        if isAppInstalled(for: platform) {
            return .installed
        } else {
            return .notInstalled
        }
    }
}

enum AppStatus {
    case installed
    case notInstalled
    
    var description: String {
        switch self {
        case .installed:
            return "App installed"
        case .notInstalled:
            return "Open in browser"
        }
    }
    
    var icon: String {
        switch self {
        case .installed:
            return "checkmark.circle.fill"
        case .notInstalled:
            return "safari.fill"
        }
    }
}