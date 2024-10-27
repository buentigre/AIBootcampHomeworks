//
//  GPTModel.swift
//  myChatGPT
//
//  Created by Marcin Kosobudzki on 26.10.24.
//

import Foundation

enum GPTModelVersion: String, Codable {
	case gpt35Turbo = "gpt-3.5-turbo"
	case gpt4o = "gpt-4o"
	case gpt4Turbo = "gpt-4-turbo"
}

struct GPTMessage: Codable, Hashable {
	let role: Role
	let content: String

	enum Role: String, Codable {
		case assistant
		case system
		case user
	}
}

extension Array where Element == GPTMessage {
	static func makeContext(_ contents: String...) -> [GPTMessage] {
		return contents.map { GPTMessage(role: .system, content: $0)}
	}
}

struct GPTChatRequest: Codable {
	let model: GPTModelVersion
	let messages: [GPTMessage]

	init(model: GPTModelVersion,
		 messages: [GPTMessage]) {
		self.model = model
		self.messages = messages
	}
}

struct GPTChatResponse: Codable {
	let id: String
	let created: Date
	let model: String
	let choices: [Choice]

	struct Choice: Codable {
		let message: GPTMessage
	}
}

enum GPTClientError: Error, CustomStringConvertible {
	case errorResponse(statusCode: Int, error: GPTErrorResponse?)
	case networkError(message: String? = nil, error: Error? = nil)

	var description: String {
		switch self {
			case .errorResponse(let statusCode, let error):
				// let extraInfo: String? = error?.error.code
				return "GPTClientError.errorResponse: statusCode: \(statusCode)," +
				"error: \(String(describing: error))"

			case .networkError(let message, let error):
				return "GPTClientError.networkError: message: \(String(describing: message)), " +
				"error: \(String(describing: error))"
		}
	}
}

struct GPTErrorResponse: Codable {
	let error: ErrorDetail

	struct ErrorDetail: Codable {
		let message: String
		let type: String
		let param: String?
		let code: String?
	}
}
