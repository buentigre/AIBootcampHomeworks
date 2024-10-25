//
//  ContentView.swift
//  PetBreeds
//
//  Created by Marcin Kosobudzki on 13.10.24.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
	@StateObject var viewModel: PetImageViewModel

	var body: some View {
		VStack {
			if let image = viewModel.photoPickerViewModel.selectedPhoto?.image {
				Spacer()
					.frame(height: 10)
				Image(uiImage: image)
					.resizable()
					.aspectRatio(contentMode: .fit)

				if let errorMessage = viewModel.errorMessage {
					Spacer()
					Text(errorMessage)
						.foregroundColor(.red)
						.multilineTextAlignment(.center)
						.padding()
					Spacer()
				} else {
					if !Utils.isSimulator() {
						VStack {
							Spacer()
							if let breed = viewModel.breedName, let conficence = viewModel.confidence {
								if viewModel.lowConfidenceWarning {
									Text("It'm not sure what kind of pet it is, maybe a \(breed)?")
										.font(.title2)
										.multilineTextAlignment(.center)
									Text("I'm just \(conficence) sure :(")
										.font(.caption)
								} else {
									Text("It's a \(breed)!")
										.font(.largeTitle)
									Text("I'm \(conficence) sure.")
										.font(.caption)
								}
							} else {
								Button("Start pet breed detection") {
									viewModel.classifyImage()
								}
								.buttonStyle(.bordered)
								.tint(.green)
							}
							Spacer()
							Text("Select a new photo to see another pet breed detection.")
								.foregroundColor(.gray)
								.multilineTextAlignment(.center)
								.padding()
							Spacer()
						}
					} else {
						Spacer()
						Text("You need a real iPhone device to see pet breeds detection.")
							.foregroundColor(.gray)
							.multilineTextAlignment(.center)
							.padding()
						Spacer()
					}
				}
			} else {
				Text("Select an image")
					.font(.title)
			}
		}
		.padding()
		.onReceive(NotificationCenter.default.publisher(for: Notification.Name.photoSelected)) { _ in
			viewModel.resetDetectionImage()
		}
	}
}
