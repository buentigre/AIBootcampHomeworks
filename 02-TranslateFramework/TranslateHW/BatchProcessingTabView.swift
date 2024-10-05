//
//  BatchTranslationView.swift
//  TranslateHW
//
//  Created by Marcin Kosobudzki on 03.10.24.
//
import SwiftUI
import Translation

struct BatchProcessingTabView: View {

	@Environment(ViewModel.self) private var viewModel: ViewModel

	@State private var shouldPresentConfigurationAlert = false
	@State private var shouldPresentSimulatorAlert = false
	@State private var shouldPresentAddTaskView = false
	@State private var shouldPresentConfigurationView = false
	@State private var configuration: TranslationSession.Configuration?

	static var oneTimeWarningIsAllowed = true

	var body: some View {
		VStack {
			VStack {
				HStack(alignment: .bottom) {
					Text("Batch Processing")
						.font(.footnote)
					Spacer()
					Button {
						shouldPresentAddTaskView.toggle()
					} label: {
						Text("Add new task")
					}
					.buttonStyle(.borderedProminent)
					.tint(.blue)
				}

				HStack {
					Text("Your tasks for today:")
						.font(.largeTitle)
					Spacer()
				}
			}
			.padding()

			List {
				ForEach(viewModel.tasks) { task in
					TaskRowView(title: task.title, description: task.description)
				}
				Section() {
					HStack {
						if viewModel.tasks.count > 0 {
							Button("Delete all tasks") {
								viewModel.crearMockedData()
							}
							.buttonStyle(.plain)
							.foregroundColor(.blue)
						}
						Spacer()
						Button("Reset to default tasks") {
							viewModel.resetMockedData()
						}
						.buttonStyle(.plain)
						.foregroundColor(.blue)
					}
					.listSectionSeparator(.hidden, edges: .bottom)
				}
			}
			.listStyle(.inset)
			.translationTask(configuration) { session in
				Task {
					await viewModel.translateSequence(using: session)
				}
			}

			Spacer()

			VStack {
				HStack {
					Button {
						translateAllTasks()
					} label: {
						Text("Translate your task list")
							.frame(maxWidth: .infinity)
					}
					.buttonStyle(.borderedProminent)
					.tint(.blue)

					Spacer()

					Button {
						shouldPresentConfigurationView.toggle()
					} label: {
						Image(systemName: "gear")
					}
					.buttonStyle(.borderedProminent)
					.tint(.blue)
				}
				if let languageFrom = viewModel.translateFrom, let languageTo = viewModel.translateTo {
					Text("\(languageFrom.displayName()) → \(languageTo.displayName())")
						.foregroundColor(Color(UIColor.lightGray))
				} else{
					Text("Configure translation languages →")
						.foregroundColor(Color(UIColor.lightGray))
				}
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 30)
		}
		.sheet(isPresented: $shouldPresentAddTaskView, content: {
			AddTaskView()
		})
		.sheet(isPresented: $shouldPresentConfigurationView, content: {
			ConfigurationView()
		})
		.alert("Batch processing tab needs a real device. Please run the app on iPhone to see all the features working properly.", isPresented: $shouldPresentSimulatorAlert) {
			Button("OK", role: .cancel) {
				shouldPresentSimulatorAlert = false
			}
		}
		.alert("Please configure translation languages first.", isPresented: $shouldPresentConfigurationAlert) {
			Button("OK", role: .cancel) {
				shouldPresentConfigurationAlert = false
			}
		}
		.onAppear() {
			if Utils.isSimulator() && BatchProcessingTabView.oneTimeWarningIsAllowed {
				shouldPresentSimulatorAlert = true
				BatchProcessingTabView.oneTimeWarningIsAllowed.toggle()
			}
		}
	}
}

extension BatchProcessingTabView {
	private func translateAllTasks() {
		if viewModel.translationLanguagesChangedDetected ?? false {
			viewModel.translationLanguagesChangedDetected = false
			configuration = .init(source: viewModel.translateFrom, target: viewModel.translateTo)
		} else if configuration == nil {
			shouldPresentConfigurationAlert = true
		} else {
			configuration?.invalidate()
		}
	}
}
