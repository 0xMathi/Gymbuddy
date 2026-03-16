import Foundation
import SwiftData

// MARK: - wger.de Image API Response Models

private struct WgerImageResponse: Codable {
    let results: [WgerImage]
}

private struct WgerImage: Codable {
    let image: String
    let isMain: Bool

    enum CodingKeys: String, CodingKey {
        case image
        case isMain = "is_main"
    }
}

// MARK: - ExerciseImageService

@MainActor
final class ExerciseImageService {
    static let shared = ExerciseImageService()

    private let baseURL = "https://wger.de/api/v2/exerciseimage"

    /// Returns a cached image URL or fetches from wger API, caching the result in SwiftData.
    /// Must be called on MainActor because Exercise and ModelContext are Main-thread-bound.
    func imageUrl(for exercise: Exercise, modelContext: ModelContext) async -> URL? {
        // 1. Already cached?
        if let cached = exercise.cachedImageUrl {
            return URL(string: cached)
        }

        // 2. No wger ID → can't fetch
        guard let wgerId = exercise.wgerBaseId else { return nil }

        // 3. Fetch from wger API (network hop off main thread via URLSession)
        let urlString = "\(baseURL)/?format=json&exercise_base=\(wgerId)&is_main=true"
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return nil
            }

            let decoded = try JSONDecoder().decode(WgerImageResponse.self, from: data)
            guard let first = decoded.results.first else { return nil }

            // 4. Cache in SwiftData (back on MainActor)
            exercise.cachedImageUrl = first.image
            try? modelContext.save()

            return URL(string: first.image)
        } catch {
            return nil
        }
    }
}
