//
//  AvailableLanguages.swift
//  TranslateHW
//
//  Created by Marcin Kosobudzki on 04.10.24.
//

import Foundation

struct AvailableLanguage: Identifiable, Hashable, Comparable {

	var id: Self { self }
	let locale: Locale.Language

	func localizedName() -> String {
		let locale = Locale.current
		let shortName = shortName()

		guard let localizedName = locale.localizedString(forLanguageCode: shortName) else {
			return "Unknown"
		}

		return "\(localizedName) (\(shortName))"
	}

	private func shortName() -> String {
		"\(locale.languageCode ?? "")-\(locale.region ?? "")"
	}

	static func <(lhs: AvailableLanguage, rhs: AvailableLanguage) -> Bool {
		return lhs.localizedName() < rhs.localizedName()
	}
}
