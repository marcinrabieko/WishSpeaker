import Foundation

class MockWishGenerator {
    static let shared = MockWishGenerator()

    private var variationIndex = 0

    private init() {}

    func generateMockWish(form: WishForm) -> String {
        let templates = [
            generateTemplate1(form: form),
            generateTemplate2(form: form),
            generateTemplate3(form: form)
        ]

        let result = templates[variationIndex % templates.count]
        variationIndex += 1
        return result
    }

    private func generateTemplate1(form: WishForm) -> String {
        var wish = "Dear \(form.recipientName)"

        if !form.age.isEmpty {
            wish += ", on your \(form.age)th \(form.occasion)"
        } else {
            wish += ", on this special \(form.occasion)"
        }

        wish += ", I wish you all the best. "

        if !form.note.isEmpty {
            wish += "Knowing that \(form.note.lowercased()), I hope all your dreams come true. "
        }

        wish += "May this day bring you joy and happiness. "

        if !form.fromPerson.isEmpty {
            wish += "With warm wishes, \(form.fromPerson)"
            if !form.relation.isEmpty {
                wish += " (your \(form.relation.lowercased()))"
            }
        }

        return wish
    }

    private func generateTemplate2(form: WishForm) -> String {
        var wish = "\(form.recipientName)! "

        if form.tone.lowercased().contains("funny") {
            wish += "Another year older, but who's counting? "
        } else {
            wish += "What a wonderful occasion to celebrate! "
        }

        if !form.age.isEmpty {
            wish += "Happy \(form.age)th \(form.occasion)! "
        } else {
            wish += "Happy \(form.occasion)! "
        }

        if !form.note.isEmpty {
            wish += "I know that \(form.note.lowercased()), and I admire that about you. "
        }

        wish += "May all your wishes come true and may this be your best year yet. "

        if !form.fromPerson.isEmpty {
            wish += "Cheers, \(form.fromPerson)"
        }

        return wish
    }

    private func generateTemplate3(form: WishForm) -> String {
        var wish = "To \(form.recipientName), "

        if form.tone.lowercased().contains("elegant") || form.tone.lowercased().contains("formal") {
            wish += "on this memorable occasion, I extend my heartfelt wishes. "
        } else {
            wish += "sending you the warmest wishes on your \(form.occasion.lowercased())! "
        }

        if !form.note.isEmpty {
            wish += "\(form.note) "
        }

        if !form.age.isEmpty {
            wish += "May your \(form.age)th year be filled with success and happiness. "
        } else {
            wish += "May the coming year bring you success and happiness. "
        }

        if !form.fromPerson.isEmpty {
            wish += "With appreciation, \(form.fromPerson)"
            if !form.relation.isEmpty {
                wish += " - your \(form.relation.lowercased())"
            }
        }

        return wish
    }
}
