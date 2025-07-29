import Foundation

class ChatGPTService {
    static let shared = ChatGPTService()
    
    private init() {}
    
    func transcribeAudio(from audioURL: URL) async throws -> String {
        let url = URL(string: Config.openAIBaseURL + Config.whisperEndpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.chatGPTAPIKey)", forHTTPHeaderField: "Authorization")
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = try createMultipartBody(
            audioURL: audioURL,
            boundary: boundary
        )
        request.httpBody = httpBody
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatGPTError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("API Error (\(httpResponse.statusCode)): \(errorMessage)")
            throw ChatGPTError.apiError(httpResponse.statusCode, errorMessage)
        }
        
        let transcriptionResponse = try JSONDecoder().decode(TranscriptionResponse.self, from: data)
        return transcriptionResponse.text
    }
    
    private func createMultipartBody(audioURL: URL, boundary: String) throws -> Data {
        var body = Data()
        
        // Add audio file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        
        let audioData = try Data(contentsOf: audioURL)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add model parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        
        // Language parameter removed - Whisper will auto-detect the language
        // This enables support for 99+ languages including Spanish, Portuguese, French, German, etc.
        
        // Add response format
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"response_format\"\r\n\r\n".data(using: .utf8)!)
        body.append("json\r\n".data(using: .utf8)!)
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    func generateCaption(from text: String, for platform: SocialMediaPlatform) async throws -> String {
        let url = URL(string: Config.openAIBaseURL + "/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.chatGPTAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let style = CaptionStyle.style(for: platform)
        let prompt = createCaptionPrompt(text: text, style: style)
        
        let requestBody = ChatCompletionRequest(
            model: "gpt-4",
            messages: [
                ChatMessage(role: "system", content: prompt.systemMessage),
                ChatMessage(role: "user", content: prompt.userMessage)
            ],
            maxTokens: 500,
            temperature: 0.7
        )
        
        let jsonData = try JSONEncoder().encode(requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatGPTError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("API Error (\(httpResponse.statusCode)): \(errorMessage)")
            throw ChatGPTError.apiError(httpResponse.statusCode, errorMessage)
        }
        
        let chatResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        let rawCaption = chatResponse.choices.first?.message.content ?? "Unable to generate caption"
        
        // Remove surrounding quotes if present
        let cleanCaption = rawCaption.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanCaption.hasPrefix("\"") && cleanCaption.hasSuffix("\"") && cleanCaption.count > 1 {
            return String(cleanCaption.dropFirst().dropLast())
        }
        
        return cleanCaption
    }
    
    private func createCaptionPrompt(text: String, style: CaptionStyle) -> (systemMessage: String, userMessage: String) {
        let systemMessage = """
        You are a social media expert specializing in creating engaging content for \(style.platform.displayName).
        
        Platform: \(style.platform.displayName)
        Tone: \(style.tone)
        Character Limit: \(style.characterLimit)
        Recommended Hashtags: \(style.hashtagCount)
        
        Special Instructions: \(style.specialInstructions)
        
        Rules:
        1. PRESERVE THE ORIGINAL LANGUAGE - Write the caption in the same language as the input text
        2. Stay within the character limit
        3. Use appropriate hashtags (\(style.hashtagCount) recommended)
        4. Match the platform's typical \(style.tone) tone
        5. Make it engaging and shareable
        6. Include relevant emojis where appropriate
        7. Optimize for the platform's algorithm and user behavior
        8. DO NOT surround the caption with quotation marks - return the raw caption text only
        """
        
        let userMessage = """
        Convert this transcribed text into an optimized \(style.platform.displayName) caption:
        
        "\(text)"
        
        IMPORTANT: 
        - Keep the caption in the SAME LANGUAGE as the original text
        - DO NOT put the caption in quotation marks
        - Return only the raw caption text ready to post
        - If the input is in Spanish, write the caption in Spanish. If it's in Portuguese, write in Portuguese, etc.
        - Only the hashtags can be in English if they are commonly used that way
        
        Create a caption that's perfectly tailored for \(style.platform.displayName) with the right tone, hashtags, and formatting.
        """
        
        return (systemMessage, userMessage)
    }
}

// MARK: - Response Models
struct TranscriptionResponse: Codable {
    let text: String
}

struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let maxTokens: Int
    let temperature: Double
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatCompletionResponse: Codable {
    let choices: [ChatChoice]
}

struct ChatChoice: Codable {
    let message: ChatMessage
}

// MARK: - Error Types
enum ChatGPTError: Error, LocalizedError {
    case invalidResponse
    case apiError(Int, String)
    case noAudioData
    case invalidAudioFormat
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let code, let message):
            return "API Error (\(code)): \(message)"
        case .noAudioData:
            return "No audio data available"
        case .invalidAudioFormat:
            return "Invalid audio format"
        }
    }
}