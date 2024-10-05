//
//  AddTaskView.swift
//  TranslateHW
//
//  Created by Marcin Kosobudzki on 04.10.24.
//

import SwiftUI

struct AddTaskView: View {

	@Environment(\.dismiss) private var dismiss
	@Environment(ViewModel.self) private var viewModel: ViewModel
	
	@State private var title: String = ""
	@State private var description: String = ""
	@State private var error = ""

	var body: some View {
		NavigationStack {
			HStack {
				Button("Cancel") {
					dismiss()
				}
				Spacer()
				Button("Add") {
					if title.isEmpty || description.isEmpty {
						error = "Both fields are required."
					} else {
						viewModel.addTask(TaskItem(title: title, description: description))
						dismiss()
					}
				}
			}
			.padding()

			HStack {
				Text("New task")
					.font(.largeTitle)
				Spacer()
			}
			.padding()

			if error.isEmpty == false {
				Text(error)
					.foregroundColor(.red)
					.padding()
			}
			Form {
				TextField("Title", text: $title)
					.disableAutocorrection(true)
					.onChange(of: title) {
						error = ""
					}
				TextField("Description", text: $description)
					.disableAutocorrection(true)
					.onChange(of: description) {
						error = ""
					}
			}
			.scrollContentBackground(.hidden)
		}
	}
}
