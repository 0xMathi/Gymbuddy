import Foundation
import MediaPlayer
import AVFoundation

/// Service for displaying workout info on the lockscreen and handling remote commands
@Observable
final class NowPlayingService {

    // MARK: - Properties

    private var audioSession: AVAudioSession { AVAudioSession.sharedInstance() }
    private var nowPlayingInfoCenter: MPNowPlayingInfoCenter { .default() }
    private var remoteCommandCenter: MPRemoteCommandCenter { .shared() }

    private var isActive = false

    // Callbacks for remote commands
    var onPlayPause: (() -> Void)?
    var onSkipNext: (() -> Void)?

    // MARK: - Initialization

    init() {
        setupAudioSession()
    }

    // MARK: - Audio Session

    private func setupAudioSession() {
        do {
            // Configure audio session for background playback
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("NowPlayingService: Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Public Methods

    /// Activates the Now Playing service and registers remote commands
    func activate() {
        guard !isActive else { return }
        isActive = true

        setupRemoteCommands()
        UIApplication.shared.beginReceivingRemoteControlEvents()

        print("NowPlayingService: Activated")
    }

    /// Deactivates the Now Playing service
    func deactivate() {
        guard isActive else { return }
        isActive = false

        clearRemoteCommands()
        clearNowPlayingInfo()
        UIApplication.shared.endReceivingRemoteControlEvents()

        print("NowPlayingService: Deactivated")
    }

    /// Updates the lockscreen with current workout info
    func updateNowPlaying(
        exerciseName: String,
        currentSet: Int,
        totalSets: Int,
        isResting: Bool,
        restTimeRemaining: Int? = nil
    ) {
        var nowPlayingInfo: [String: Any] = [:]

        // Title: Exercise name
        nowPlayingInfo[MPMediaItemPropertyTitle] = exerciseName.uppercased()

        // Artist: Set info or Rest status
        if isResting, let remaining = restTimeRemaining {
            nowPlayingInfo[MPMediaItemPropertyArtist] = "REST - \(formatTime(remaining))"
        } else {
            nowPlayingInfo[MPMediaItemPropertyArtist] = "SET \(currentSet) OF \(totalSets)"
        }

        // Album: App name
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "GymBuddy Workout"

        // Playback state
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isResting ? 0.0 : 1.0

        // Duration and elapsed time for rest timer
        if isResting, let remaining = restTimeRemaining {
            // Show rest progress
            let totalRest = remaining + 5 // Approximate, will be updated
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: totalRest)
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: totalRest - remaining)
        }

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }

    /// Updates rest timer countdown on lockscreen
    func updateRestTimer(exerciseName: String, currentSet: Int, totalSets: Int, remaining: Int, total: Int) {
        var nowPlayingInfo: [String: Any] = [:]

        nowPlayingInfo[MPMediaItemPropertyTitle] = "REST"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "\(formatTime(remaining)) - Next: \(exerciseName)"
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "GymBuddy Workout"

        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: total)
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: total - remaining)

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }

    /// Clears all now playing info
    func clearNowPlayingInfo() {
        nowPlayingInfoCenter.nowPlayingInfo = nil
    }

    // MARK: - Remote Commands

    private func setupRemoteCommands() {
        // Play/Pause command - toggles pause state
        remoteCommandCenter.playCommand.isEnabled = true
        remoteCommandCenter.playCommand.addTarget { [weak self] _ in
            self?.onPlayPause?()
            return .success
        }

        remoteCommandCenter.pauseCommand.isEnabled = true
        remoteCommandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.onPlayPause?()
            return .success
        }

        remoteCommandCenter.togglePlayPauseCommand.isEnabled = true
        remoteCommandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.onPlayPause?()
            return .success
        }

        // Next track command - complete current set
        remoteCommandCenter.nextTrackCommand.isEnabled = true
        remoteCommandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.onSkipNext?()
            return .success
        }

        // Disable unused commands
        remoteCommandCenter.previousTrackCommand.isEnabled = false
        remoteCommandCenter.skipForwardCommand.isEnabled = false
        remoteCommandCenter.skipBackwardCommand.isEnabled = false
        remoteCommandCenter.seekForwardCommand.isEnabled = false
        remoteCommandCenter.seekBackwardCommand.isEnabled = false
        remoteCommandCenter.changePlaybackRateCommand.isEnabled = false
        remoteCommandCenter.changeRepeatModeCommand.isEnabled = false
        remoteCommandCenter.changeShuffleModeCommand.isEnabled = false
    }

    private func clearRemoteCommands() {
        remoteCommandCenter.playCommand.removeTarget(nil)
        remoteCommandCenter.pauseCommand.removeTarget(nil)
        remoteCommandCenter.togglePlayPauseCommand.removeTarget(nil)
        remoteCommandCenter.nextTrackCommand.removeTarget(nil)
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if mins > 0 {
            return String(format: "%d:%02d", mins, secs)
        }
        return "\(secs)s"
    }
}
