//
//  ImageViewModel.swift
//  FannyFaces
//
//  Created by Marcin Kosobudzki on 28.09.24.
//

import SwiftUI
import Vision

struct VisionFace {
	var faceRectangle: CGRect = .zero
	var leftEye: [CGPoint] = []
	var rightEye: [CGPoint] = []
	var leftPupil: [CGPoint] = []
	var rightPupil: [CGPoint] = []
	var leftEyebrow: [CGPoint] = []
	var rightEyebrow: [CGPoint] = []
	var innerLips: [CGPoint] = []
	var outerLips: [CGPoint] = []
	var faceContour: [CGPoint] = []
	var nose: [CGPoint] = []
}

class ImageViewModel: ObservableObject {
	@Published var visionFaces: [VisionFace] = []
	@Published var currentFaceIndex: Int = 0
	@Published var errorMessage: String? = nil
	@Published var photoPickerViewModel: PhotoPickerViewModel

	init(photoPickerViewModel: PhotoPickerViewModel) {
		self.photoPickerViewModel = photoPickerViewModel
	}

	@MainActor
	func clearFaceDetection() {
		DispatchQueue.main.async { [weak self] in
			self?.visionFaces = []
		}
	}

	@MainActor
	func detectFaces() {
		currentFaceIndex = 0
		guard let image = photoPickerViewModel.selectedPhoto?.image else {
			DispatchQueue.main.async {
				self.errorMessage = "No image available"
			}
			return
		}

		guard let cgImage = image.cgImage else {
			DispatchQueue.main.async {
				self.errorMessage = "Failed to convert UIImage to CGImage"
			}
			return
		}

		let faceDetectionRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
			if let error = error {
				DispatchQueue.main.async {
					self?.errorMessage = "Face detection error: \(error.localizedDescription)"
				}
				return
			}

			let faces: [VisionFace] = request.results?.compactMap {
				guard let observation = $0 as? VNFaceObservation else { return nil }

				var face = VisionFace()
				face.faceRectangle = observation.boundingBox
				face.leftEye = observation.landmarks?.leftEye?.normalizedPoints ?? []
				face.rightEye = observation.landmarks?.rightEye?.normalizedPoints ?? []
				face.leftPupil = observation.landmarks?.leftPupil?.normalizedPoints ?? []
				face.rightPupil = observation.landmarks?.rightPupil?.normalizedPoints ?? []
				face.leftEyebrow = observation.landmarks?.leftEyebrow?.normalizedPoints ?? []
				face.rightEyebrow = observation.landmarks?.rightEyebrow?.normalizedPoints ?? []
				face.innerLips = observation.landmarks?.innerLips?.normalizedPoints ?? []
				face.outerLips = observation.landmarks?.outerLips?.normalizedPoints ?? []
				face.faceContour = observation.landmarks?.faceContour?.normalizedPoints ?? []
				face.nose = observation.landmarks?.nose?.normalizedPoints ?? []
				return face
			} ?? []

			DispatchQueue.main.async {
				self?.visionFaces = faces
				self?.errorMessage = faces.isEmpty ? "No faces detected" : nil
			}
		}

#if targetEnvironment(simulator)
		faceDetectionRequest.usesCPUOnly = true
#endif

		let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

		do {
			try handler.perform([faceDetectionRequest])
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = "Failed to perform detection: \(error.localizedDescription)"
			}
		}
	}

	@MainActor
	func nextFace() {
		if visionFaces.isEmpty { return }
		currentFaceIndex = (currentFaceIndex + 1) % visionFaces.count
	}

	@MainActor
	func previousFace() {
		if visionFaces.isEmpty { return }
		currentFaceIndex = (currentFaceIndex - 1 + visionFaces.count) % visionFaces.count
	}

	@MainActor
	var currentFace: VisionFace? {
		guard !visionFaces.isEmpty else { return nil }
		return visionFaces[currentFaceIndex]
	}

}
