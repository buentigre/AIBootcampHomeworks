//
//  TaskRowView.swift
//  TranslateHW
//
//  Created by Marcin Kosobudzki on 04.10.24.
//

import SwiftUI

struct TaskRowView: View {

	@State var taskIsDoneToggle = false

	let title: String
	let description: String

	var body: some View {
		HStack {
			Image(systemName: taskIsDoneToggle ? "checkmark.circle" : "circle")
				.font(.title)
				.foregroundColor(.gray)
				.onTapGesture {
					taskIsDoneToggle.toggle()
				}

			VStack(alignment: .leading) {
				Text(title)
					.font(.headline)
				Text(description)
					.font(.subheadline)
			}
		}
	}
}
