import SwiftUI

@Observable final class OccasionSelectionViewModel {
	let occasions: [Occasion] = [
		Occasion(iconName: "birthday.cake", title: "Urodziny", subtitle: "Dla solenizanta lub solenizantki"),
		Occasion(iconName: "heart.circle", title: "Rocznica", subtitle: "Dla par, małżonków, związku"),
		Occasion(iconName: "gift.fill", title: "Imieniny", subtitle: "Klasyczne imieninowe życzenia"),
		Occasion(iconName: "heart.fill", title: "Ślub", subtitle: "Dla nowożeńców i zakochanych"),
		Occasion(iconName: "camera.macro", title: "Dzień Matki", subtitle: "Pokaż, jak bardzo cenisz"),
		Occasion(iconName: "mustache", title: "Dzień Ojca", subtitle: "Podziękuj swojemu tacie"),
		Occasion(iconName: "leaf.fill", title: "Dzień Kobiet", subtitle: "Dla wyjątkowej kobiety"),
		Occasion(iconName: "trophy.fill", title: "Gratulacje", subtitle: "Na nową pracę, sukces, awans"),
		Occasion(iconName: "hand.raised.fill", title: "Przeprosiny", subtitle: "Powiedz to w dobry sposób"),
		Occasion(iconName: "hands.clap.fill", title: "Podziękowania", subtitle: "Za pomoc, wsparcie lub obecność"),
		Occasion(iconName: "sparkles", title: "Inna okazja", subtitle: "Stwórz własne życzenia")
	]
}
