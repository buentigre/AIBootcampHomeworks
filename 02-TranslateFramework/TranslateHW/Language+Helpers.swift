//
//  Language+Helpers.swift
//  TranslateHW
//
//  Created by Marcin Kosobudzki on 04.10.24.
//

import Foundation

extension Locale.Language {
	
	func displayName() -> String {
		let currentLocale = Locale.current
		let shortName = "\(self.languageCode ?? "")-\(self.region ?? "")"
		guard let localizedName = currentLocale.localizedString(forLanguageCode: shortName) else {
			return "Unknown"
		}
		return localizedName
	}
}
