//
//  ViewModel.swift
//  TranslateHW
//
//  Created by Marcin Kosobudzki on 03.10.24.
//

import Foundation
import Translation

@Observable
class ViewModel {

	private var mockedData =
		[TaskItem(title: "Shopping", description: "Buy milk, butter, cheese and meat"),
		 TaskItem(title: "School", description: "Prepare your homework for tomorrow"),
		 TaskItem(title: "Blind date", description: "Wash your hair and put on new shoes")]

	var tasks: [TaskItem] = []
	var isTranslationSupported: Bool?
	var translationLanguagesChangedDetected: Bool?
	var availableLanguages: [AvailableLanguage] = []
	var translateFrom: Locale.Language?
	var translateTo: Locale.Language?

	init() {
		tasks = mockedData
		prepareSupportedLanguages()
	}

	func reset() {
		isTranslationSupported = nil
	}

	func prepareSupportedLanguages() {
		Task { @MainActor in
			let supportedLanguages = await LanguageAvailability().supportedLanguages
			availableLanguages = supportedLanguages.map {
				AvailableLanguage(locale: $0)
			}.sorted()
		}
	}

	func addTask(_ taskItem: TaskItem) {
		tasks.append(taskItem)
	}

	func flipTranslationLanguagesPossible() -> Bool {
		return translateFrom != nil && translateTo != nil
	}

	func flipTranslationLanguages() {
		if flipTranslationLanguagesPossible() {
			let temp = translateFrom
			translateFrom = translateTo
			translateTo = temp
		}
	}

	func resetMockedData() {
		tasks =	mockedData
	}

	func crearMockedData() {
		tasks.removeAll()
	}

	func checkLanguageSupport(from source: Locale.Language, to target: Locale.Language) async {
		translateFrom = source
		translateTo = target

		guard let translateFrom = translateFrom else { return }

		let status = await LanguageAvailability().status(from: translateFrom, to: translateTo)

		switch status {
			case .installed, .supported:
				isTranslationSupported = true
				translationLanguagesChangedDetected = true
			case .unsupported:
				isTranslationSupported = false
			@unknown default:
				print("Translation status: unknown")
		}
	}

	func translateSequence(using session: TranslationSession) async {
		let titleMarker = "T"
		let descriptionMarker = "D"
		let titles = tasks.compactMap { $0.title }
		let descriptions = tasks.compactMap { $0.description }

		// For testing purpose:
		print(">>> sent titles: \(titles)")
		print(">>> sent descriptions: \(descriptions)")

		var requests: [TranslationSession.Request] = titles.enumerated().map { (index, string) in
				.init(sourceText: string, clientIdentifier: "\(titleMarker)\(index)")
		}
		let descriptionRequests: [TranslationSession.Request] = descriptions.enumerated().map { (index, string) in
				.init(sourceText: string, clientIdentifier: "\(descriptionMarker)\(index)")
		}
		requests.append(contentsOf: descriptionRequests)

		do {
			for try await response in session.translate(batch: requests) {
				guard var responseIdentifier: String = response.clientIdentifier, !responseIdentifier.isEmpty else { continue
				}
				if responseIdentifier.hasPrefix(titleMarker) {
					responseIdentifier.remove(at: responseIdentifier.startIndex)
					guard let index = Int(responseIdentifier) else { continue }
					tasks[index].title = response.targetText
					print("<<< response title: \(response.targetText)")
				} else if responseIdentifier.hasPrefix(descriptionMarker) {
					responseIdentifier.remove(at: responseIdentifier.startIndex)
					guard let index = Int(responseIdentifier) else { continue }
					tasks[index].description = response.targetText
					print("<<< response description: \(response.targetText)")
				} else {
					continue
				}
			}
		} catch {
			print("Error executing translateSequence: \(error)")
		}
	}
}
