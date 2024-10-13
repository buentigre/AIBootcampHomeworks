//
//  ContentView.swift
//  PetBreeds
//
//  Created by Marcin Kosobudzki on 13.10.24.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
	@StateObject var viewModel: ImageViewModel

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
							Text("Breed: name")
								.padding()
							Text("Accuracy: 0.0%")
								.padding()
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
			// TODO: clear pet breed detection here, and maybe start new detection
		}
	}
}
