import Foundation

/// Three curated demo wishes shown on the Example Wishes screen, each demonstrating a
/// different occasion/variant/voice combination. English and Polish text is authored
/// natively per language, not translated — only the audio file names differ, and both
/// currently point at recordings that don't exist yet (see VoiceAsset+AudioURL), so the
/// player gracefully shows a disabled state until real samples are bundled.
public enum ExampleData {
    public static var exampleWishes: [Wish] {
        Locale.current.language.languageCode?.identifier == "pl" ? polishWishes : englishWishes
    }

    private static let englishWishes: [Wish] = [
        Wish(
            occasionKind: .birthday,
            occasionTitle: "Birthday",
            recipient: "Gregory",
            variant: .warm,
            text: """
            Gregory, on your birthday I wish you that everything in life aligns as \
            perfectly as the paving stones you lay every day. May your business grow, your \
            projects succeed and your dream of owning a quad finally become reality. All the \
            best from Marcin.
            """,
            voiceAsset: VoiceAsset(
                audioFileReference: "example_gregory_birthday_warm_en.m4a",
                voiceIdentifier: "warm_male_01",
                voiceDisplayName: "James",
                duration: 34.0
            )
        ),
        Wish(
            occasionKind: .wedding,
            occasionTitle: "Wedding",
            recipient: "Alicia & Daniel",
            variant: .natural,
            text: """
            Alicia and Daniel, congratulations on your wedding day. May your marriage be \
            built on the same trust and laughter that brought you here, and may every year \
            together feel as easy as this one. Wishing you a lifetime of happiness.
            """,
            voiceAsset: VoiceAsset(
                audioFileReference: "example_alicia_daniel_wedding_natural_en.m4a",
                voiceIdentifier: "natural_female_01",
                voiceDisplayName: "Sofia",
                duration: 41.0
            )
        ),
        Wish(
            occasionKind: .birthday,
            occasionTitle: "Birthday",
            recipient: "Noah",
            variant: .light,
            text: """
            Noah, happy birthday! Officially aged up, no refunds. Hope today is full of \
            the good stuff — snacks, laughs, and minimal responsibility. Enjoy the extra \
            candle!
            """,
            voiceAsset: VoiceAsset(
                audioFileReference: "example_noah_birthday_light_en.m4a",
                voiceIdentifier: "light_male_01",
                voiceDisplayName: "Leo",
                duration: 22.0
            )
        )
    ]

    private static let polishWishes: [Wish] = [
        Wish(
            occasionKind: .birthday,
            occasionTitle: "Urodziny",
            recipient: "Grzegorz",
            variant: .warm,
            text: """
            Grzegorzu, z okazji urodzin życzę Ci, aby wszystko w życiu układało się tak \
            dobrze, jak kostka brukowa, którą co dzień starannie układasz. Niech Twoja firma \
            się rozwija, projekty kończą sukcesem, a marzenie o własnym quadzie wreszcie się \
            spełni. Wszystkiego najlepszego, Marcin.
            """,
            voiceAsset: VoiceAsset(
                audioFileReference: "example_grzegorz_urodziny_warm_pl.m4a",
                voiceIdentifier: "warm_male_01",
                voiceDisplayName: "Jakub",
                duration: 35.0
            )
        ),
        Wish(
            occasionKind: .wedding,
            occasionTitle: "Ślub",
            recipient: "Alicja i Daniel",
            variant: .natural,
            text: """
            Alicjo i Danielu, gratulacje z okazji ślubu. Niech wasze małżeństwo opiera się \
            na tym samym zaufaniu i śmiechu, które doprowadziły was do tego dnia, a każdy \
            kolejny rok niech będzie równie lekki jak ten. Życzymy wam szczęścia na całe życie.
            """,
            voiceAsset: VoiceAsset(
                audioFileReference: "example_alicja_daniel_slub_natural_pl.m4a",
                voiceIdentifier: "natural_female_01",
                voiceDisplayName: "Zofia",
                duration: 43.0
            )
        ),
        Wish(
            occasionKind: .birthday,
            occasionTitle: "Urodziny",
            recipient: "Antoni",
            variant: .light,
            text: """
            Antek, sto lat! Oficjalnie starszy, bez zwrotów. Mam nadzieję, że dziś będzie \
            tylko to, co najlepsze — przekąski, śmiech i zero obowiązków. Ciesz się dodatkową \
            świeczką!
            """,
            voiceAsset: VoiceAsset(
                audioFileReference: "example_antoni_urodziny_light_pl.m4a",
                voiceIdentifier: "light_male_01",
                voiceDisplayName: "Leon",
                duration: 21.0
            )
        )
    ]
}
