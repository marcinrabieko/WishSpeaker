import Combine
import Foundation
import Observation

/// Ensures at most one `InlineVoicePlayer` is audibly playing at a time — starting
/// playback on one instance asks every other currently-playing instance to stop first,
/// so scrubbing through a list of examples/Library rows never overlaps audio.
@MainActor
@Observable
public final class VoicePlaybackCoordinator {
    public static let shared = VoicePlaybackCoordinator()

    private var activePlayerID: UUID?
    private var stopHandlers: [UUID: () -> Void] = [:]

    private init() {}

    func register(id: UUID, stopHandler: @escaping () -> Void) {
        stopHandlers[id] = stopHandler
    }

    func unregister(id: UUID) {
        stopHandlers.removeValue(forKey: id)

        if activePlayerID == id {
            activePlayerID = nil
        }
    }

    func willStartPlaying(id: UUID) {
        if let activePlayerID, activePlayerID != id {
            stopHandlers[activePlayerID]?()
        }

        activePlayerID = id
    }

    func didStopPlaying(id: UUID) {
        if activePlayerID == id {
            activePlayerID = nil
        }
    }
}
