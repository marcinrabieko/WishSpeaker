import Localizations

public struct OccasionFormCopy: Sendable {
    public let recipientTitle: String
    public let recipientPlaceholder: String
    public let detailsPlaceholder: String
}

public extension OccasionKind {
    var formCopy: OccasionFormCopy {
        switch self {
        case .birthday:
            OccasionFormCopy(
                recipientTitle: L10n.formOccasionBirthdayRecipientTitle,
                recipientPlaceholder: L10n.formOccasionBirthdayRecipientPlaceholder,
                detailsPlaceholder: L10n.formOccasionBirthdayDetailsPlaceholder
            )

        case .anniversary:
            OccasionFormCopy(
                recipientTitle: L10n.formOccasionAnniversaryRecipientTitle,
                recipientPlaceholder: L10n.formOccasionAnniversaryRecipientPlaceholder,
                detailsPlaceholder: L10n.formOccasionAnniversaryDetailsPlaceholder
            )

        case .nameDay:
            OccasionFormCopy(
                recipientTitle: L10n.formOccasionNameDayRecipientTitle,
                recipientPlaceholder: L10n.formOccasionNameDayRecipientPlaceholder,
                detailsPlaceholder: L10n.formOccasionNameDayDetailsPlaceholder
            )

        case .wedding:
            OccasionFormCopy(
                recipientTitle: L10n.formOccasionWeddingRecipientTitle,
                recipientPlaceholder: L10n.formOccasionWeddingRecipientPlaceholder,
                detailsPlaceholder: L10n.formOccasionWeddingDetailsPlaceholder
            )

        case .mothersDay:
            OccasionFormCopy(
                recipientTitle: L10n.formOccasionMothersDayRecipientTitle,
                recipientPlaceholder: L10n.formOccasionMothersDayRecipientPlaceholder,
                detailsPlaceholder: L10n.formOccasionMothersDayDetailsPlaceholder
            )

        case .fathersDay:
            OccasionFormCopy(
                recipientTitle: L10n.formOccasionFathersDayRecipientTitle,
                recipientPlaceholder: L10n.formOccasionFathersDayRecipientPlaceholder,
                detailsPlaceholder: L10n.formOccasionFathersDayDetailsPlaceholder
            )

        case .womensDay:
            OccasionFormCopy(
                recipientTitle: L10n.formOccasionWomensDayRecipientTitle,
                recipientPlaceholder: L10n.formOccasionWomensDayRecipientPlaceholder,
                detailsPlaceholder: L10n.formOccasionWomensDayDetailsPlaceholder
            )

        case .congratulations:
            OccasionFormCopy(
                recipientTitle: L10n.formOccasionCongratulationsRecipientTitle,
                recipientPlaceholder: L10n.formOccasionCongratulationsRecipientPlaceholder,
                detailsPlaceholder: L10n.formOccasionCongratulationsDetailsPlaceholder
            )

        case .apology:
            OccasionFormCopy(
                recipientTitle: L10n.formOccasionApologyRecipientTitle,
                recipientPlaceholder: L10n.formOccasionApologyRecipientPlaceholder,
                detailsPlaceholder: L10n.formOccasionApologyDetailsPlaceholder
            )

        case .thanks:
            OccasionFormCopy(
                recipientTitle: L10n.formOccasionThanksRecipientTitle,
                recipientPlaceholder: L10n.formOccasionThanksRecipientPlaceholder,
                detailsPlaceholder: L10n.formOccasionThanksDetailsPlaceholder
            )

        case .other:
            OccasionFormCopy(
                recipientTitle: L10n.formOccasionOtherRecipientTitle,
                recipientPlaceholder: L10n.formOccasionOtherRecipientPlaceholder,
                detailsPlaceholder: L10n.formOccasionOtherDetailsPlaceholder
            )
        }
    }
}

public extension Occasion {
    var formCopy: OccasionFormCopy {
        kind.formCopy
    }
}
