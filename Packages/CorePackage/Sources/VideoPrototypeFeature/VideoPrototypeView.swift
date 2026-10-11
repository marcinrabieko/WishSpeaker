import AVKit
import Observation
import SwiftUI

/// DEBUG-only diagnostic screen for the native video renderer prototype — see
/// PrototypeRenderer.swift's doc comment for why AVAssetWriter was chosen over
/// AVVideoCompositionCoreAnimationTool. Stage 1: renders a fixed-duration clip
/// (background + border + one static text block) and reports timing/size so we can
/// confirm the AVAssetWriter/VideoToolbox pipeline actually works end-to-end on a
/// physical device before building out the full ASS-equivalent subtitle system.
public struct VideoPrototypeView: View {
    @State private var viewModel = VideoPrototypeViewModel()

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Native Video Renderer Prototype")
                    .font(.title2.bold())

                Text("Stage 1: background + border + static text. 1024x1024, 30fps, H.264.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Divider()

                ForEach(VideoPrototypeViewModel.testDurations, id: \.self) { duration in
                    Button {
                        viewModel.didTapRender(durationSeconds: duration)
                    } label: {
                        if viewModel.isRendering(durationSeconds: duration) {
                            ProgressView()
                        } else {
                            Text("Render \(Int(duration))s clip")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isRenderingAny)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Divider()

                ForEach(viewModel.results) { result in
                    resultRow(result)
                }
            }
            .padding()
        }
        .navigationTitle("Video Prototype")
    }

    private func resultRow(_ result: VideoPrototypeViewModel.RenderRun) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(Int(result.requestedDurationSeconds))s clip — run \(result.runIndex)")
                .font(.headline)
            Text(
                String(
                    format: "Total: %.2fs  |  Composition: %.2fs  |  Render: %.2fs  |  Finish: %.2fs",
                    result.totalDuration,
                    result.compositionDuration,
                    result.renderDuration,
                    result.writeFinishDuration
                )
            )
            .font(.caption)
            Text(
                String(
                    format: "File size: %.2f MB  |  Realtime factor: %.2fx",
                    Double(result.fileSizeBytes) / 1_000_000,
                    result.requestedDurationSeconds / result.totalDuration
                )
            )
            .font(.caption)
            if let url = result.outputURL {
                ShareLink(item: url) {
                    Label("Share MP4", systemImage: "square.and.arrow.up")
                }
                .font(.caption)
            }

            Divider()
        }
        .padding(.vertical, 8)
    }
}
