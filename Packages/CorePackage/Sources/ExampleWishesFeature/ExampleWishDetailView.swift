import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI

/// Read-only product demo of the Voice WishDetail experience — no Edit/Save/Copy/Create
/// Voice/Create Video Card/Share/Download/Regenerate, since this wish was never
/// generated or saved by the user.
struct ExampleWishDetailView: View {
    let wish: Wish

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WSSpacing.md) {
                metadata

                if let voiceAsset = wish.voiceAsset {
                    voiceSection(voiceAsset)
                }

                Text(wish.text)
                    .font(.system(size: 16))
                    .foregroundColor(.wsPrimaryText)
                    .lineSpacing(5)
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.vertical, WSSpacing.md)
        }
        .background(Color.wsBackground)
        .navigationTitle(wish.recipient)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton()
    }

    private var metadata: some View {
        Text(WishMetadataText.format(occasionKind: wish.occasionKind, variant: wish.variant))
            .font(.system(size: 15))
            .foregroundColor(.wsSecondaryText)
    }

    private func voiceSection(_ voiceAsset: VoiceAsset) -> some View {
        VStack(alignment: .leading, spacing: WSSpacing.xs) {
            HStack(spacing: 4) {
                Image(systemName: "waveform")
                    .font(.system(size: 13))
                Text(voiceAsset.voiceDisplayName)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.wsPrimary)

            InlineVoicePlayer(voiceAsset: voiceAsset, audioURL: voiceAsset.audioURL)
                .padding(WSSpacing.sm)
                .background(Color.wsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous)
                        .stroke(Color.wsSoftBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
        }
    }
}
