import Foundation

public extension VoiceAsset {
    /// Reads and decodes `wordTimestampsFileReference` from the app's Documents
    /// directory, mirroring `audioURL`'s existence check — `nil` when there's no
    /// reference at all, the file is missing, or it fails to decode, so a caller
    /// never treats a corrupt/missing sidecar file as valid alignment data.
    var wordTimestamps: [WordTiming]? {
        guard let wordTimestampsFileReference else {
            return nil
        }

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let fileURL = documentsDirectory.appendingPathComponent(wordTimestampsFileReference)

        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        return try? JSONDecoder().decode([WordTiming].self, from: data)
    }
}
