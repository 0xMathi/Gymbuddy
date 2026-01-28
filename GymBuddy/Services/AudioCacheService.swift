import Foundation
import CryptoKit

/// Persistent audio cache for ElevenLabs generated speech
/// Uses SHA256 hash of text as filename for deterministic cache hits
class AudioCacheService {
    static let shared = AudioCacheService()

    private let cacheDirectory: URL
    private let fileManager = FileManager.default

    // MARK: - Initialization

    private init() {
        // Get caches directory
        let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesURL.appendingPathComponent("audio_cache", isDirectory: true)

        // Create directory if needed
        createCacheDirectoryIfNeeded()
    }

    private func createCacheDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
                print("AudioCacheService: Created cache directory at \(cacheDirectory.path)")
            } catch {
                print("AudioCacheService: Failed to create cache directory: \(error)")
            }
        }
    }

    // MARK: - Public API

    /// Check if audio for this text is already cached
    /// - Parameter text: The text to check
    /// - Returns: true if cached audio exists
    func isCached(_ text: String) -> Bool {
        let fileURL = cacheFileURL(for: text)
        return fileManager.fileExists(atPath: fileURL.path)
    }

    /// Get cached audio data for text
    /// - Parameter text: The text to get audio for
    /// - Returns: Cached audio data, or nil if not cached
    func getCachedAudio(for text: String) -> Data? {
        let fileURL = cacheFileURL(for: text)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            print("AudioCacheService: Cache hit for '\(text.prefix(30))...'")
            return data
        } catch {
            print("AudioCacheService: Failed to read cached audio: \(error)")
            return nil
        }
    }

    /// Cache audio data for text
    /// - Parameters:
    ///   - data: The audio data to cache
    ///   - text: The text this audio represents
    func cacheAudio(_ data: Data, for text: String) {
        let fileURL = cacheFileURL(for: text)

        do {
            try data.write(to: fileURL)
            print("AudioCacheService: Cached audio for '\(text.prefix(30))...' (\(data.count) bytes)")
        } catch {
            print("AudioCacheService: Failed to cache audio: \(error)")
        }
    }

    /// Clear all cached audio files
    func clearCache() {
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
            print("AudioCacheService: Cleared \(files.count) cached files")
        } catch {
            print("AudioCacheService: Failed to clear cache: \(error)")
        }
    }

    /// Get total size of cached audio files
    /// - Returns: Size in bytes
    func cacheSize() -> Int64 {
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            var totalSize: Int64 = 0
            for file in files {
                let attributes = try fileManager.attributesOfItem(atPath: file.path)
                totalSize += (attributes[.size] as? Int64) ?? 0
            }
            return totalSize
        } catch {
            return 0
        }
    }

    /// Get number of cached files
    var cachedFileCount: Int {
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            return files.count
        } catch {
            return 0
        }
    }

    // MARK: - Private Helpers

    private func cacheFileURL(for text: String) -> URL {
        let hash = sha256Hash(of: text)
        return cacheDirectory.appendingPathComponent("\(hash).mp3")
    }

    private func sha256Hash(of text: String) -> String {
        let data = Data(text.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
