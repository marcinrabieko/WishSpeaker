import SwiftUI

@Observable final class OccasionSelectionViewModel {
	let occasions: [Occasion] = [
		Occasion(iconName: "birthday-cake", title: "Urodziny", subtitle: "Dla solenizanta lub solenizantki"),
		Occasion(iconName: "wedding-day", title: "Rocznica", subtitle: "Dla par, małżonków, związku"),
		Occasion(iconName: "gift", title: "Imieniny", subtitle: "Klasyczne imieninowe życzenia"),
		Occasion(iconName: "couple", title: "Ślub", subtitle: "Dla nowożeńców i zakochanych"),
		Occasion(iconName: "heart", title: "Dzień Matki", subtitle: "Pokaż, jak bardzo cenisz"),
		Occasion(iconName: "best-dad", title: "Dzień Ojca", subtitle: "Podziękuj swojemu tacie"),
		Occasion(iconName: "bouquet-flower", title: "Dzień Kobiet", subtitle: "Dla wyjątkowej kobiety"),
		Occasion(iconName: "trophy", title: "Gratulacje", subtitle: "Na nową pracę, sukces, awans"),
		Occasion(iconName: "sorry", title: "Przeprosiny", subtitle: "Powiedz to w dobry sposób"),
		Occasion(iconName: "handshake", title: "Podziękowania", subtitle: "Za pomoc, wsparcie lub obecność"),
		Occasion(iconName: "more", title: "Inna okazja", subtitle: "Stwórz własne życzenia")
	]
}
