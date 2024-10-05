//
//  ContentView.swift
//  TranslateHW
//
//  Created by Marcin Kosobudzki on 03.10.24.
//

import SwiftUI
import Translation

struct OverlayPresentationTabView: View {

	@FocusState private var textFieldIsFocused: Bool

	@State private var textInput = ""
	@State private var emptyTextFieldToggle = false
	@State private var showTranslationToggle = false

    var body: some View {
        VStack {
			HStack {
				Text("Overlay Presentation")
					.font(.footnote)
				Spacer()
			}

			HStack {
				Text("Built-in Translation UI")
					.font(.largeTitle)
				Spacer()
			}

			Spacer()
				.frame(height: 50)

			TextField("Enter text in any language..", text: $textInput)
				.focused($textFieldIsFocused)
				.onChange(of: textInput) {
					emptyTextFieldToggle = false
				}
				.padding(10)
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(Color.blue, lineWidth: 2)
				)
				.padding(20)

			if emptyTextFieldToggle {
				Text("Enter text first :)")
					.foregroundColor(.red)
					.padding()
			}

			Button("Translate", action: {
				textFieldIsFocused = false
				if textInput.isEmpty {
					emptyTextFieldToggle = true
					return
				}

				showTranslationToggle.toggle()
			})
			.buttonStyle(.borderedProminent)

			Spacer()
        }
        .padding()
		.translationPresentation(isPresented: $showTranslationToggle, text: textInput, replacementAction: { translatedText in
			textInput = translatedText
		})
    }
}
