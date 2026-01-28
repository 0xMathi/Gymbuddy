import Foundation

/// ElevenLabs Text-to-Speech API Service
/// Uses the eleven_flash_v2_5 model for lowest latency
class ElevenLabsService {
    static let shared = ElevenLabsService()

    private let baseURL = "https://api.elevenlabs.io/v1"

    // Default voice: Rachel (clear, natural female voice)
    private let defaultVoiceId = "21m00Tcm4TlvDq8ikWAM"

    // MARK: - Error Types

    enum ElevenLabsError: Error, LocalizedError {
        case noApiKey
        case invalidURL
        case networkError(Error)
        case invalidResponse
        case apiError(statusCode: Int, message: String?)
        case quotaExceeded

        var errorDescription: String? {
            switch self {
            case .noApiKey:
                return "No ElevenLabs API key configured"
            case .invalidURL:
                return "Invalid API URL"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid response from API"
            case .apiError(let code, let message):
                return "API error (\(code)): \(message ?? "Unknown")"
            case .quotaExceeded:
                return "Monthly character quota exceeded"
            }
        }
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Public API

    /// Generates speech audio from text using ElevenLabs API
    /// - Parameter text: The text to convert to speech
    /// - Returns: MP3 audio data
    /// - Throws: ElevenLabsError if the request fails
    func generateSpeech(text: String) async throws -> Data {
        let settings = AppSettings.shared

        guard let apiKey = settings.elevenLabsApiKey, !apiKey.isEmpty else {
            throw ElevenLabsError.noApiKey
        }

        let voiceId = settings.elevenLabsVoiceId.isEmpty ? defaultVoiceId : settings.elevenLabsVoiceId

        guard let url = URL(string: "\(baseURL)/text-to-speech/\(voiceId)") else {
            throw ElevenLabsError.invalidURL
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("audio/mpeg", forHTTPHeaderField: "Accept")

        // Request body
        let body: [String: Any] = [
            "text": text,
            "model_id": "eleven_flash_v2_5",  // Fastest model
            "voice_settings": [
                "stability": 0.5,
                "similarity_boost": 0.75,
                "style": 0.3,  // Slight expressiveness for coaching
                "use_speaker_boost": true
            ],
            "output_format": "mp3_44100_128"
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        // Execute request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw ElevenLabsError.networkError(error)
        }

        // Check response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ElevenLabsError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            return data
        case 401:
            throw ElevenLabsError.apiError(statusCode: 401, message: "Invalid API key")
        case 429:
            throw ElevenLabsError.quotaExceeded
        default:
            // Try to parse error message
            let message = try? JSONDecoder().decode(ErrorResponse.self, from: data).detail?.message
            throw ElevenLabsError.apiError(statusCode: httpResponse.statusCode, message: message)
        }
    }

    // MARK: - Response Types

    private struct ErrorResponse: Codable {
        let detail: ErrorDetail?
    }

    private struct ErrorDetail: Codable {
        let message: String?
    }
}
