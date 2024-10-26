//
//  ContentView.swift
//  myChatGPT
//
//  Created by Marcin Kosobudzki on 26.10.24.
//

import SwiftUI

struct ContentView: View {

	var client = GPTClient(
		model: .gpt35Turbo,
		context: .makeContext(
			"Your name is Cario Helpino, and you act as a support staff for any car problems or car improvements.",
			"Only answers questions if they pertain to a car problems or car improvements. If they don't, say you can't help and propose website links to other helpful resources or services related to the question.",
			"You can answer questions about changing the conversation language.",
			"You can answer questions regarding your name, who you are, and whether you are a human or AI."
		)
	)

	@State var messages: [GPTMessage] = [
		GPTMessage(role: .assistant, content: "Hi, my name is Cario Helpino. I am your personal car assistant, and I can help you with any car issue or car improvements. What can I do for you today?")
	]
	@State var inputText: String = ""
	@State var isLoading = false
	@FocusState private var textFieldIsFocused: Bool

	var body: some View {
		NavigationView {
			VStack {
				messagesScrollView
				inputMessageView
			}
			.navigationTitle("🚙 Car Assistance 🛠️")
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarItems(trailing: Button("New") {
					messages = messages.count > 0 ? [messages[0]] : []
				}
				.disabled(messages.count < 2)
			)
		}
	}

	var messagesScrollView: some View {
		ScrollView {
			VStack(spacing: 10) {
				ForEach(messages, id: \.self) { message in
					if (message.role == .user) {
						Text(message.content)
							.padding()
							.background(Color.blue.opacity(0.9))
							.foregroundColor(.white)
							.cornerRadius(10)
							.frame(maxWidth: .infinity, alignment: .trailing)
					} else {
						Text(message.content.toSmartAttributedString())
							.padding()
							.background(Color.green.opacity(0.2))
							.cornerRadius(10)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
				}
			}
			.padding()
		}
		.defaultScrollAnchor(.bottom)
	}

	var buttonBackgroundColor: Color {
		return (inputText.isEmpty || isLoading) ? .gray : .blue
	}

	var inputMessageView: some View {
		VStack {
			HStack {
				TextField("Type your question here...", text: $inputText, axis: .vertical)
					.padding(7)
					.overlay(
						RoundedRectangle(cornerRadius: 5)
							.stroke(Color.gray)
					)
					.frame(maxWidth: .infinity, alignment: .center)
					.focused($textFieldIsFocused)

				if isLoading {
					ProgressView()
						.padding()
				}
			}

			HStack {
				Button(action: {
					textFieldIsFocused.toggle()
				}) {
					Text(textFieldIsFocused ? "Hide keyboard" : "Show keyboard")
				}
				.foregroundStyle(.blue)
				.buttonStyle(.plain)

				Spacer()

				Button(action: sendMessage) {
					Text("Submit")
				}
				.disabled(inputText.isEmpty || isLoading)
				.foregroundColor(.white)
				.background(buttonBackgroundColor)
				.buttonStyle(.borderedProminent)
				.cornerRadius(5)
			}
		}
		.padding()
	}



	private func sendMessage() {
		isLoading = true

		Task {
			let message = GPTMessage(role: .user, content: inputText)
			messages.append(message)

			do {
				let response = try await client.sendChats(messages)
				isLoading = false

				guard let reply = response.choices.first?.message else {
					print("API error! There weren't any choices despite a successful response")
					return
				}
				messages.append(reply)
				inputText.removeAll()

			} catch {
				isLoading = false
				print("Got an error: \(error)")
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

