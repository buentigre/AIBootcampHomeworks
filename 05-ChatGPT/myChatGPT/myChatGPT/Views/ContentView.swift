//
//  ContentView.swift
//  myChatGPT
//
//  Created by Marcin Kosobudzki on 26.10.24.
//

import SwiftUI

struct ChatMessage: Identifiable {
	let id = UUID()
	let message: GPTMessage
}

struct ContentView: View {

	var client = GPTClient(
		model: .gpt35Turbo,
		context: .makeContext(
			"Your name is Cario Helpino, and you act as a support staff for any car problems or car improvements.",
			"Only answers questions if they pertain to a car problems or car improvements. If they don't, say you can't help and propose website links to other helpful resources or services related to the question.",
			"You can answer questions about changing the conversation language, and if your wants to talk in a different language, you can do that.",
			"Also, you can talk about your name, about who you are, and whether you are a human or AI robot."
		)
	)

	@State var chatMessages: [ChatMessage] = [
		ChatMessage(message:
			GPTMessage(role: .assistant, content: "Hi, my name is Cario Helpino. I am your personal car assistant, and I can help you with any car issue or car improvements. What can I do for you today?")
		)
	]
	@State var inputText: String = ""
	@State var isLoading = false
	@State var errorMessage: String?
	@State var isNetworAvailable: Bool = false
	@FocusState private var textFieldIsFocused: Bool

	var body: some View {
		NavigationView {
			VStack {
				messagesScrollView
				errorMessagesView
				inputMessageView
			}
			.navigationTitle("🚙 Car Assistance 🛠️")
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarItems(trailing:
				Button("New") {
					chatMessages = chatMessages.count > 0 ? [chatMessages[0]] : []
				}
				.disabled(chatMessages.count < 2)
			)
		}
		.onAppear() {
			Utils.startMonitoringNetworkConnection()
		}
		.onDisappear() {
			Utils.stopMonitoringNetworkConnection()
		}
		.onReceive(NotificationCenter.default.publisher(for: Notification.Name.netConnPositiveNotification)) {_ in
			isNetworAvailable = true
		}
		.onReceive(NotificationCenter.default.publisher(for: Notification.Name.netConnNegativeNotification)) {_ in
			isNetworAvailable = false
		}
	}

	var messagesScrollView: some View {
		ScrollView {
			VStack(spacing: 10) {
				ForEach(chatMessages) { chatMessage in
					if (chatMessage.message.role == .user) {
						Text(chatMessage.message.content)
							.padding()
							.background(Color.blue.opacity(0.9))
							.foregroundColor(.white)
							.cornerRadius(10)
							.frame(maxWidth: .infinity, alignment: .trailing)
							.contextMenu(ContextMenu(menuItems: {
								Button("Copy", action: {
									UIPasteboard.general.string = chatMessage.message.content
								})
							}))
					} else {
						Text(chatMessage.message.content.toSmartAttributedString())
							.padding()
							.background(Color.green.opacity(0.2))
							.cornerRadius(10)
							.frame(maxWidth: .infinity, alignment: .leading)
							.contextMenu(ContextMenu(menuItems: {
								Button("Copy", action: {
									UIPasteboard.general.string = chatMessage.message.content
								})
							}))
					}
				}
			}
			.padding()
		}
		.defaultScrollAnchor(.bottom)
	}

	var buttonBackgroundColor: Color {
		return (inputText.isEmpty || isLoading || !isNetworAvailable) ? .gray : .blue
	}

	var errorMessagesView: some View {
		VStack {
			if !isNetworAvailable {
				Text("🛜 Upss! Looks like network connection is lost 😢\nNetwork connection is required to use this app.")
					.frame(maxWidth: .infinity)
					.foregroundStyle(.red)
					.multilineTextAlignment(.center)
					.font(.caption)
			} else {
				if chatMessages.count > 10 {
					Text("Your current chat seems to be a bit long. Please consider opening a [New] conversations.")
						.frame(maxWidth: .infinity)
						.foregroundStyle(.green)
						.multilineTextAlignment(.center)
						.font(.caption)
				}

				if let errorMessage = errorMessage {
					Text(errorMessage)
						.frame(maxWidth: .infinity)
						.foregroundStyle(.red)
						.multilineTextAlignment(.center)
						.font(.caption2)
				}
			}
		}
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
					.onSubmit {
						if Utils.isSimulator() {
							sendMessage()
						}
					}

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
				.disabled(inputText.isEmpty || isLoading || !isNetworAvailable)
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
			let userMessage = ChatMessage(message: GPTMessage(role: .user, content: inputText))
			chatMessages.append(userMessage)
			let gptMessages = chatMessages.map{GPTMessage(role: $0.message.role, content: $0.message.content)}

			do {
				let response = try await client.sendChats(gptMessages)
				isLoading = false

				guard let reply = response.choices.first?.message else {
					errorMessage = "API error: There weren't any choices despite a successful response."
					return
				}
				errorMessage = nil
				chatMessages.append(ChatMessage(message: reply))
				inputText.removeAll()

			} catch let error as GPTClientError {
				isLoading = false
				errorMessage = "Error: \(error.description)"
			}
		}
	}
}
