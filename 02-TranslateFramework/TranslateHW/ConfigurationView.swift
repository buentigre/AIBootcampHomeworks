//
//  TranslationConfigView.swift
//  TranslateHW
//
//  Created by Marcin Kosobudzki on 04.10.24.
//

import SwiftUI
import Translation

struct ConfigurationView: View {

	@Environment(\.dismiss) private var dismiss
	@Environment(ViewModel.self) var viewModel

	@State private var selectedFrom: Locale.Language?
	@State private var selectedTo: Locale.Language?

	var selectedLanguagePair: SelectedLanguages {
		SelectedLanguages(from: selectedFrom, to: selectedTo)
	}

	var body: some View {
		HStack {
			Button(backButtonTitle()) {
				dismiss()
			}
			Spacer()
		}
		.padding()

		HStack {
			Text("Translation Config")
				.font(.largeTitle)
			Spacer()
		}
		.padding()

		if viewModel.flipTranslationLanguagesPossible() {
			HStack {
				Spacer()
				Button("Flip selected languages ↓↑") {
					flipSelectedLanguages()
				}
				.buttonStyle(.plain)
				.foregroundColor(.blue)
			}
			.padding(.top, 20)
			.padding(.horizontal, 10)
		}

		VStack {
			List {
				Section("Select a source and a target language for translation.") {
					Picker("Source", selection: $selectedFrom) {
						ForEach(viewModel.availableLanguages) { language in
							Text(language.localizedName())
								.tag(Optional(language.locale))
						}
					}
					Picker("Target", selection: $selectedTo) {
						ForEach(viewModel.availableLanguages) { language in
							Text(language.localizedName())
								.tag(Optional(language.locale))
						}
					}

					HStack {
						Spacer()
						if let isSupported = viewModel.isTranslationSupported {
							if Utils.isSimulator() {
								Text("❌")
									.font(.largeTitle)
								Text("Heh, I told you it wouldn't work on the simulator ;)")
							} else {
								Text(isSupported ? "✅" : "❌")
									.font(.largeTitle)
								if !isSupported {
									Text("Translation between same language isn't supported.")
								}
							}
						} else {
							Image(systemName: "questionmark.circle")
								.font(.largeTitle)
						}
						Spacer()
					}
				}
				.listSectionSeparator(.hidden, edges: .bottom)
			}
			.listStyle(.inset)
		}
		.onChange(of: selectedLanguagePair) {
			Task {
				await performCheck()
			}
		}
		.onAppear() {
			if let translateFrom = viewModel.translateFrom, let translateTo = viewModel.translateTo {
				selectedFrom = translateFrom
				selectedTo = translateTo
			}
		}
		.onDisappear() {
			viewModel.reset()
		}
		.padding()
	}

	private func performCheck() async {
		guard let selectedFrom = selectedFrom else { return }
		guard let selectedTo = selectedTo else { return }

		await viewModel.checkLanguageSupport(from: selectedFrom, to: selectedTo)
	}

	private func flipSelectedLanguages() {
		if viewModel.flipTranslationLanguagesPossible() {
			selectedFrom = viewModel.translateTo
			selectedTo = viewModel.translateFrom
		}
	}

	private func backButtonTitle() -> String {
		return (viewModel.isTranslationSupported ?? false) ? "Apply" : "Back" 
	}
}

struct SelectedLanguages: Equatable {
	@State var from: Locale.Language?
	@State var to: Locale.Language?

	static func == (lhs: SelectedLanguages, rhs: SelectedLanguages) -> Bool {
		return lhs.from == rhs.from &&
		lhs.to == rhs.to
	}
}
