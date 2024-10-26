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
			"any helpful context here"
		)
	)

	@State var messages: [GPTMessage] = [
		GPTMessage(role: .assistant, content: "Hi, how can I help you?")
	]
	@State var inputText: String = ""
	@State var isLoading = false
	@State var textEditorHeight: CGFloat = 36

	var body: some View {
		NavigationView {
			VStack {
				messagesScrollView
				inputMessageView
			}
			.navigationTitle("Car Assistance")
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarItems(trailing: Button("New") {
				messages = messages.count > 0 ? [messages[0]] : []
			}.disabled(messages.count < 2))
		}
	}

	var messagesScrollView: some View {
		ScrollView {
			VStack(spacing: 10) {
				ForEach(messages, id: \.self) { message in
					if (message.role == .user) {
						Text(message.content)
							.padding()
							.background(Color.blue)
							.foregroundColor(.white)
							.cornerRadius(10)
							.frame(maxWidth: .infinity, alignment: .trailing)
					} else {
						Text(message.content)
							.padding()
							.background(Color.gray.opacity(0.1))
							.cornerRadius(10)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
				}
			}
			.padding()
		}
	}

	var inputMessageView: some View {
		HStack {
			TextField("Type your message...", text: $inputText, axis: .vertical)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding()

			if isLoading {
				ProgressView()
					.padding()
			}

			Button(action: sendMessage) {
				Text("Submit")
			}
			.disabled(inputText.isEmpty || isLoading)
			.padding()
		}
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

