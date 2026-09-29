import Foundation

public final class MockWishGenerator: @unchecked Sendable {
    public static let shared = MockWishGenerator()

    private init() {}

    public func generateWish(request: WishGenerationRequest, variant: WishVariant, avoiding previousText: String?) -> String {
        let candidates = templates(occasion: request.occasionKind, variant: variant, form: request.form)

        guard let previousText else {
            return candidates[0]
        }

        return candidates.first { $0 != previousText } ?? candidates[candidates.count > 1 ? 1 : 0]
    }

    private func templates(occasion: OccasionKind, variant: WishVariant, form: WishForm) -> [String] {
        let recipient = form.recipientName.isEmpty ? form.relation : form.recipientName
        let name = recipient.isEmpty ? "you" : recipient
        let context = form.note.trimmingCharacters(in: .whitespacesAndNewlines)

        switch variant {
        case .warm:
            return warmTemplates(occasion: occasion, name: name, context: context)

        case .natural:
            return naturalTemplates(occasion: occasion, name: name, context: context)

        case .light:
            return lightTemplates(occasion: occasion, name: name, context: context)
        }
    }

    private func warmTemplates(occasion: OccasionKind, name: String, context: String) -> [String] {
        if occasion == .apology {
            let contextLine = context.isEmpty ? "" : " Knowing that \(context.lowercased()), it makes this moment feel even more meaningful."

            return [
                """
                \(name), I've been thinking about what happened, and I need you to know how sorry I am. \
                I didn't mean to hurt you, and I understand if it takes time to feel okay again.\(contextLine) \
                You mean a lot to me, and I don't want this to stand between us. \
                I hope you can find it in your heart to forgive me, in your own time. \
                I'm here, and I care about you more than words can really say.
                """,
                """
                \(name), I keep coming back to what happened, and I owe you a real apology, not just words. \
                I'm sorry for the hurt I caused you.\(contextLine) \
                I don't want to rush you or make excuses — I just want you to know it weighs on me too. \
                Take whatever time you need. I'll still be here, hoping we can find our way back to each other.
                """
            ]
        }

        let contextLine = context.isEmpty ? "" : " Knowing that \(context.lowercased()), it makes this moment feel even more meaningful."

        return [
            """
            Dear \(name), from the bottom of my heart, I want you to know how much you mean to me.\(contextLine) \
            Every moment we've shared has stayed with me, and today I just want to celebrate you. \
            You bring so much warmth into the lives around you, more than you probably realize. \
            I hope this day reminds you just how loved and appreciated you are. \
            Wishing you all the joy and tenderness that you so freely give to others.
            """,
            """
            \(name), some people leave a mark on your heart, and you're one of them for me.\(contextLine) \
            Today feels like the right moment to finally say it out loud. \
            Thank you for being exactly who you are, without ever needing to try. \
            I hope you feel, even just for today, how deeply you're cared for. \
            Sending you all my warmth, today and always.
            """
        ]
    }

    private func naturalTemplates(occasion: OccasionKind, name: String, context: String) -> [String] {
        if occasion == .apology {
            let contextLine = context.isEmpty ? "" : " I know that \(context.lowercased()), and that's part of what makes you, you."

            return [
                """
                \(name), I want to say this plainly: I was wrong, and I'm sorry. \
                What happened wasn't fair to you, and I take responsibility for it.\(contextLine) \
                I'd like the chance to make things right between us. \
                Whatever you decide, I respect it, and I appreciate you hearing me out.
                """,
                """
                \(name), I don't want to overthink this — I made a mistake, and I'm genuinely sorry. \
                You didn't deserve to be treated that way.\(contextLine) \
                I'd like to talk when you're ready, but there's no pressure. \
                Just know that this matters to me, and so do you.
                """
            ]
        }

        let contextLine = context.isEmpty ? "" : " I know that \(context.lowercased()), and that's part of what makes you, you."

        return [
            """
            \(name), I wanted to take a moment to send you my sincere wishes today.\(contextLine) \
            It's easy to get caught up in everyday life, so I wanted to pause and let you know I'm thinking of you. \
            I hope this moment brings you a sense of ease and genuine happiness. \
            Here's to good things ahead, simple and true. \
            Take care, and enjoy today.
            """,
            """
            \(name), wishing you a genuinely good day today, without needing it to be perfect.\(contextLine) \
            Hope things go smoothly, and if not, that people around you are patient and kind. \
            You deserve some ease and a bit of extra happiness right now. \
            Take today at your own pace.
            """
        ]
    }

    private func lightTemplates(occasion: OccasionKind, name: String, context: String) -> [String] {
        if occasion == .apology {
            let contextLine = context.isEmpty ? "" : " Also, \(context.lowercased()) — noted, and appreciated."

            return [
                """
                Hey \(name), okay, I clearly messed up, and I just want to clear the air. \
                No excuses — I'm sorry, plain and simple.\(contextLine) \
                Let's not let something silly get in the way of us being okay. \
                I owe you one, whenever you're ready.
                """,
                """
                \(name), consider this my official "I was wrong, my bad" message. \
                I'm sorry, for real.\(contextLine) \
                Let's not make this bigger than it needs to be — I just want things to feel normal again. \
                Coffee's on me next time.
                """
            ]
        }

        if occasion == .birthday {
            let contextLine = context.isEmpty ? "" : " Also, \(context.lowercased()) — never change."

            return [
                """
                Happy birthday, \(name)! Another year, another excuse for cake, so let's take it. \
                Hope your day is full of good food, good laughs, and zero adulting responsibilities.\(contextLine) \
                Go enjoy yourself — you've earned it. \
                Here's to another year of chaos and good times!
                """,
                """
                \(name), happy birthday! Officially aged up, no refunds. \
                Hope today is full of the good stuff — snacks, laughs, and minimal responsibility.\(contextLine) \
                Go do something that makes you happy today. \
                Enjoy the extra candle!
                """
            ]
        }

        let contextLine = context.isEmpty ? "" : " Also, \(context.lowercased()) — never change."

        return [
            """
            Hey \(name)! Just popping in to say this day deserves a little extra smile.\(contextLine) \
            No big speech here — just good vibes coming your way. \
            Hope it's easy, fun, and totally stress-free. \
            Enjoy it!
            """,
            """
            \(name), sending you a quick, no-frills reminder that today's a good day to feel good.\(contextLine) \
            Nothing fancy — just genuinely hoping it's a smooth, happy one for you. \
            Go treat yourself to something small today.
            """
        ]
    }
}
