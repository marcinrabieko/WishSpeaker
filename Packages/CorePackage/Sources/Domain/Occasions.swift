import Localizations

public extension Occasion {
    static let all: [Occasion] = [
        Occasion(kind: .birthday, iconName: "birthday.cake", title: L10n.occasionBirthdayTitle, subtitle: L10n.occasionBirthdaySubtitle),
        Occasion(kind: .anniversary, iconName: "heart.circle", title: L10n.occasionAnniversaryTitle, subtitle: L10n.occasionAnniversarySubtitle),
        Occasion(kind: .nameDay, iconName: "gift.fill", title: L10n.occasionNameDayTitle, subtitle: L10n.occasionNameDaySubtitle),
        Occasion(kind: .wedding, iconName: "heart.fill", title: L10n.occasionWeddingTitle, subtitle: L10n.occasionWeddingSubtitle),
        Occasion(kind: .mothersDay, iconName: "camera.macro", title: L10n.occasionMothersDayTitle, subtitle: L10n.occasionMothersDaySubtitle),
        Occasion(kind: .fathersDay, iconName: "mustache", title: L10n.occasionFathersDayTitle, subtitle: L10n.occasionFathersDaySubtitle),
        Occasion(kind: .womensDay, iconName: "leaf.fill", title: L10n.occasionWomensDayTitle, subtitle: L10n.occasionWomensDaySubtitle),
        Occasion(kind: .congratulations, iconName: "trophy.fill", title: L10n.occasionCongratulationsTitle, subtitle: L10n.occasionCongratulationsSubtitle),
        Occasion(kind: .apology, iconName: "hand.raised.fill", title: L10n.occasionApologyTitle, subtitle: L10n.occasionApologySubtitle),
        Occasion(kind: .thanks, iconName: "hands.clap.fill", title: L10n.occasionThanksTitle, subtitle: L10n.occasionThanksSubtitle),
        Occasion(kind: .other, iconName: "sparkles", title: L10n.occasionOtherTitle, subtitle: L10n.occasionOtherSubtitle)
    ]
}
