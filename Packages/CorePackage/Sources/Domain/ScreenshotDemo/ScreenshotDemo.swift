#if DEBUG
import Dependencies
import Foundation

/// Debug-only autopilot that walks the app through the App Store screenshot/App Preview
/// flow on its own, enabled by the `-ScreenshotDemo` launch argument (see
/// StoreAssets/capture.py). Each screen hands its scripted part of the walkthrough to
/// `run(_:_:)`, and `capture(_:)` is a handshake with the capture script: the app writes
/// `<name>.ready` into Documents/ScreenshotDemo and holds the screen until the script
/// has taken the screenshot and answered with `<name>.done`.
@MainActor
public enum ScreenshotDemo {
    public enum Step: Int, CaseIterable, Sendable {
        case start
        case occasionSelection
        case form
        case wishes
        case result
        case libraryAndExamples
    }

    public static let isActive = ProcessInfo.processInfo.arguments.contains("-ScreenshotDemo")

    /// Renders the narrated fixture video once through the real backend + on-device
    /// renderer (see `prepareFixtures()`), instead of running the walkthrough.
    public static let isPreparingFixtures = ProcessInfo.processInfo.arguments.contains("-ScreenshotDemoPrepare")

    private static var startedSteps: Set<Step> = []

    private static let captureTimeout: TimeInterval = 15.0

    static var markersDirectory: URL {
        URL.documentsDirectory.appending(path: "ScreenshotDemo")
    }

    /// Called first thing in the App's init — before anything resolves a dependency.
    public static func configureLaunch() {
        if isActive {
            prepareDependencies {
                $0.wishGenerationService = ScreenshotDemoWishGenerationService()
            }
        }

        if isPreparingFixtures {
            Task {
                await prepareFixtures()
            }
        }
    }

    /// Runs `script` once, and only right after the previous step has started — so a
    /// screen that appears again (e.g. Start, after popping back from the Create flow)
    /// never replays its step. An unstructured Task rather than `.task`, since pushing
    /// the next screen fires onDisappear on this one and would cancel the rest of it.
    public static func run(_ step: Step, _ script: @escaping @MainActor () async -> Void) {
        guard isActive, !startedSteps.contains(step) else {
            return
        }

        if let previousStep = Step(rawValue: step.rawValue - 1), !startedSteps.contains(previousStep) {
            return
        }

        startedSteps.insert(step)

        Task {
            await script()
        }
    }

    public static func pause(_ seconds: Double) async {
        try? await Task.sleep(for: .seconds(seconds))
    }

    /// Feeds `text` in one character at a time at an uneven, human pace, lingering a
    /// little longer after spaces and punctuation.
    public static func type(_ text: String, into update: (String) -> Void) async {
        var typedText = ""

        for character in text {
            typedText.append(character)
            update(typedText)

            let delay = Double.random(in: 0.04...0.09)
            let isWordBreak = character == " " || character.isPunctuation
            await pause(isWordBreak ? delay + 0.06 : delay)
        }
    }

    /// Holds the current screen until the capture script has taken its screenshot.
    public static func capture(_ name: String) async {
        writeMarker("\(name).ready")

        let doneMarkerPath = markersDirectory.appending(path: "\(name).done").path
        let deadline = Date().addingTimeInterval(captureTimeout)

        while !FileManager.default.fileExists(atPath: doneMarkerPath), Date() < deadline {
            await pause(0.05)
        }
    }

    /// A timestamp-only marker the capture script doesn't answer, e.g. where the App
    /// Preview video should start or end.
    public static func mark(_ name: String, contents: String = "") {
        writeMarker("\(name).mark", contents: contents)
    }

    private static func writeMarker(_ fileName: String, contents: String = "") {
        try? FileManager.default.createDirectory(at: markersDirectory, withIntermediateDirectories: true)
        try? Data(contents.utf8).write(to: markersDirectory.appending(path: fileName))
    }
}
#endif
