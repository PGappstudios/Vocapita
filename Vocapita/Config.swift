import Foundation

struct Config {
    static var chatGPTAPIKey: String {
        // First, try to get from environment variable (recommended for production)
        if let apiKey = ProcessInfo.processInfo.environment["CHATGPT_API_KEY"], !apiKey.isEmpty {
            return apiKey
        }
        
        // Fallback: You can paste your API key here for testing (NOT recommended for production)
        // Replace "your_api_key_here" with your actual ChatGPT API key
        let hardcodedKey = "your_api_key_here"
        
        if hardcodedKey == "your_api_key_here" {
            fatalError("Please set your ChatGPT API key either as an environment variable 'CHATGPT_API_KEY' or replace 'your_api_key_here' in Config.swift")
        }
        
        return hardcodedKey
    }
    
    static let openAIBaseURL = "https://api.openai.com/v1"
    static let whisperEndpoint = "/audio/transcriptions"
}

// MARK: - Setup Instructions
/*
 To add your ChatGPT API key:
 
 OPTION 1 (Recommended - Secure):
 1. In Xcode, go to Product → Scheme → Edit Scheme
 2. Select "Run" on the left
 3. Go to "Environment Variables" tab
 4. Click "+" and add:
    Name: CHATGPT_API_KEY
    Value: [your actual API key]
 
 OPTION 2 (For testing only):
 Replace "your_api_key_here" above with your actual API key.
 ⚠️ WARNING: Never commit real API keys to version control!
 */