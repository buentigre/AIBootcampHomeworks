//
//  ImageViewModel.swift
//  PetBreeds
//
//  Created by Marcin Kosobudzki on 13.10.24.
//

import SwiftUI

class ImageViewModel: ObservableObject {

	@Published var photoPickerViewModel: PhotoPickerViewModel
	@Published var errorMessage: String?
	@Published var classification: String?
	@Published var confidence: String?
	@Published var elapsedTime: String?
	@Published var lowConfidenceWarning: Bool = false

	// Init with full model, model can be changed later via changeModel routine.
	private let classifier = ImageClassifier(modelType: .full)

	init(photoPickerViewModel: PhotoPickerViewModel) {
		self.photoPickerViewModel = photoPickerViewModel
	}

	@MainActor
	func changeModel(to model: ModelType) {
		classifier.changeModel(modelType: model)
	}

	@MainActor
	func resetDetectionImage() {
		self.errorMessage = nil
		self.classification = nil
		self.confidence = nil
		self.elapsedTime = nil
		self.photoPickerViewModel.selectedPhoto = nil
	}

	@MainActor
	func classifyImage() {
		guard let image = photoPickerViewModel.selectedPhoto?.image else {
			DispatchQueue.main.async {
				self.errorMessage = "No image available"
				self.classification = ""
				self.confidence = ""
				self.lowConfidenceWarning = false
			}
			return
		}

		let resizedImage = resizeImage(image)
		DispatchQueue.global(qos: .userInteractive).async {
			self.classifier.classify(image: resizedImage ?? image) { [weak self] classification, confidence, time in
				DispatchQueue.main.async { [weak self] in
					self?.classification = classification
					self?.confidence = String(format: "%.0f%%", (confidence ?? 0) * 100.0)
					if let time = time {
						self?.elapsedTime = String(format: "%.2f", time)
					}
					self?.lowConfidenceWarning = (confidence ?? 0) < 0.75 ? true : false
				}
			}
		}
	}

	private func resizeImage(_ image: UIImage) -> UIImage? {
		let imageSize: CGFloat = 300.0
		UIGraphicsBeginImageContext(CGSize(width: imageSize, height: imageSize))
		image.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return resizedImage
	}
}
