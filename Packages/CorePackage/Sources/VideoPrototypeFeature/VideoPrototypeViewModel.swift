import Foundation
import Observation

@MainActor
@Observable
final class VideoPrototypeViewModel {
    static let testDurations: [Double] = [15, 30, 60]

    struct RenderRun: Identifiable {
        let id = UUID()
        let runIndex: Int
        let requestedDurationSeconds: Double
        let totalDuration: TimeInterval
        let compositionDuration: TimeInterval
        let renderDuration: TimeInterval
        let writeFinishDuration: TimeInterval
        let fileSizeBytes: Int64
        let outputURL: URL?
    }

    var results: [RenderRun] = []
    var errorMessage: String?

    private var renderingDurations: Set<Double> = []
    private var runCounters: [Double: Int] = [:]

    var isRenderingAny: Bool {
        !renderingDurations.isEmpty
    }

    func isRendering(durationSeconds: Double) -> Bool {
        renderingDurations.contains(durationSeconds)
    }

    func didTapRender(durationSeconds: Double) {
        guard !renderingDurations.contains(durationSeconds) else {
            return
        }

        renderingDurations.insert(durationSeconds)
        errorMessage = nil

        Task {
            defer { renderingDurations.remove(durationSeconds) }

            do {
                let result = try await PrototypeRenderer.renderBasicClip(
                    durationSeconds: durationSeconds,
                    text: "Ania, wszystkiego najlepszego z okazji urodzin!"
                )
                runCounters[durationSeconds, default: 0] += 1
                results.insert(
                    RenderRun(
                        runIndex: runCounters[durationSeconds] ?? 1,
                        requestedDurationSeconds: durationSeconds,
                        totalDuration: result.totalDuration,
                        compositionDuration: result.compositionDuration,
                        renderDuration: result.renderDuration,
                        writeFinishDuration: result.writeFinishDuration,
                        fileSizeBytes: result.fileSizeBytes,
                        outputURL: result.outputURL
                    ),
                    at: 0
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
