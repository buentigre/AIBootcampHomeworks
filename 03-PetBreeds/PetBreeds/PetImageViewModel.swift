//
//  ImageViewModel.swift
//  PetBreeds
//
//  Created by Marcin Kosobudzki on 13.10.24.
//

import SwiftUI

class PetImageViewModel: ObservableObject {

	@Published var photoPickerViewModel: PhotoPickerViewModel
	@Published var errorMessage: String?
	@Published var breedName: String?
	@Published var confidence: String?
	@Published var lowConfidenceWarning: Bool = false

	private let classifier = PetBreedClassifier()

	init(photoPickerViewModel: PhotoPickerViewModel) {
		self.photoPickerViewModel = photoPickerViewModel
	}

	@MainActor
	func resetDetectionImage() {
		self.errorMessage = nil
		self.breedName = nil
		self.confidence = nil
		self.photoPickerViewModel.selectedPhoto = nil
	}

	@MainActor
	func classifyImage() {
		guard let image = photoPickerViewModel.selectedPhoto?.image else {
			DispatchQueue.main.async {
				self.errorMessage = "No image available"
				self.breedName = ""
				self.confidence = ""
				self.lowConfidenceWarning = false
			}
			return
		}

		let resizedImage = resizeImage(image)
		DispatchQueue.global(qos: .userInteractive).async {
			self.classifier.classify(image: resizedImage ?? image) { [weak self] breedName, confidence in
				DispatchQueue.main.async { [weak self] in
					self?.breedName = breedName
					self?.confidence = String(format: "%.0f%%", (confidence ?? 0) * 100.0)
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
