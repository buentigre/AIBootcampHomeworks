//
//  ContentView2.swift
//  FannyFaces
//
//  Created by Marcin Kosobudzki on 27.09.24.
//

import SwiftUI
import PhotosUI

class Toggles: ObservableObject {
	@Published var faceBoundary = true
	@Published var leftEye: Bool = true
	@Published var rightEye: Bool = true
	@Published var detectPupils: Bool = true
	@Published var nose: Bool = true
}

struct PhotosViewTab: View {
	@StateObject var viewModel: ImageViewModel
	@StateObject var toggles = Toggles()

	var body: some View {
		VStack {
			if let image = viewModel.photoPickerViewModel.selectedPhoto?.image.drawVisionFace(viewModel.currentFace, toggles: toggles) {
				Spacer()
					.frame(height: 30)

				HStack {
					Spacer()
					Button("Clear face detection") {
						viewModel.clearFaceDetection()
					}
				}

				Image(uiImage: image)
					.resizable()
					.aspectRatio(contentMode: .fit)

				HStack {
					Button("Previous") {
						viewModel.previousFace()
					}
					.padding()

					Button("Detect Faces") {
						viewModel.detectFaces()
					}
					.padding()

					Button("Next") {
						viewModel.nextFace()
					}
					.padding()
				}

				if let errorMessage = viewModel.errorMessage {
					Text(errorMessage)
						.foregroundColor(.red)
						.multilineTextAlignment(.center)
						.padding()
					Spacer()
				} else {
					if !Utils.isSimulator() {
						Spacer()
						HStack {
							Spacer()
							Toggle("Left eye", isOn: $toggles.leftEye)
								.tint(.orange)
								.toggleStyle(.button)
							Spacer()
							Toggle("Nose", isOn: $toggles.nose)
								.tint(.pink)
								.toggleStyle(.button)
							Spacer()
							Toggle("Right eye", isOn: $toggles.rightEye)
								.tint(.orange)
								.toggleStyle(.button)
							Spacer()
						}
						HStack {
							Spacer()
							Toggle("Pupil detection", isOn: $toggles.detectPupils)
								.tint(.mint)
								.toggleStyle(.button)
							Spacer()
							Toggle("Face boundary", isOn: $toggles.faceBoundary)
								.tint(.mint)
								.toggleStyle(.button)
							Spacer()
						}
					} else {
						Text("Only face boundary is supported on simulator. Run the app on a device to see the other options.")
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
		.onReceive(NotificationCenter.default.publisher(for: Notification.Name.photoPickerSelected)) { _ in
			viewModel.clearFaceDetection()
		}
	}
}
