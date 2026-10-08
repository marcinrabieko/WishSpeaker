import DesignSystem
import Domain
import Localizations
import SwiftUI

/// Selectable row for one curated voice — reused by both VoiceView (voice-only
/// generation) and VideoView (video generation, which also needs a voice choice).
public struct VoiceCard: View {
    let voice: VoiceOption
    let isSelected: Bool
    let onSelect: () -> Void

    public init(voice: VoiceOption, isSelected: Bool, onSelect: @escaping () -> Void) {
        self.voice = voice
        self.isSelected = isSelected
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: WSSpacing.sm) {
            VoicePreviewPlayer(previewURL: voice.previewURL)

            VStack(alignment: .leading, spacing: 2) {
                Text(voice.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.wsPrimaryText)

                Text(genderLabel)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.wsSecondaryText)
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelect)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.wsPrimary)
            }
        }
        .padding(WSSpacing.sm)
        .background(isSelected ? Color.wsPrimary.opacity(0.08) : Color.wsSurface)
        .overlay(
            RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous)
                .stroke(isSelected ? Color.wsPrimary : Color.wsSoftBorder, lineWidth: isSelected ? 2 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }

    private var genderLabel: String {
        voice.gender == .male ? L10n.voiceViewGenderMale : L10n.voiceViewGenderFemale
    }
}

public struct VoiceCardSkeleton: View {
    public init() {}

    public var body: some View {
        HStack(spacing: WSSpacing.sm) {
            Circle()
                .fill(Color.wsSoftBorder)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.wsSoftBorder)
                    .frame(width: 100, height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.wsSoftBorder)
                    .frame(width: 60, height: 11)
            }

            Spacer()
        }
        .padding(WSSpacing.sm)
        .background(Color.wsSurface)
        .overlay(
            RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous)
                .stroke(Color.wsSoftBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
        .redacted(reason: .placeholder)
    }
}

public struct VoiceCardError: View {
    let providerVoiceID: String
    let onRetry: () -> Void

    public init(providerVoiceID: String, onRetry: @escaping () -> Void) {
        self.providerVoiceID = providerVoiceID
        self.onRetry = onRetry
    }

    public var body: some View {
        HStack(spacing: WSSpacing.sm) {
            Text(L10n.voiceViewLoadError)
                .font(.system(size: 14))
                .foregroundStyle(Color.wsSecondaryText)

            Spacer()

            Button(L10n.voiceViewRetryButton, action: onRetry)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.wsPrimary)
        }
        .padding(WSSpacing.sm)
        .background(Color.wsSurface)
        .overlay(
            RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous)
                .stroke(Color.wsSoftBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
    }
}
