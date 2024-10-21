//
//  Untitled.swift
//  PetBreeds
//
//  Created by Marcin Kosobudzki on 13.10.24.
//

import Vision
import CoreML
import SwiftUI

enum ModelType {
	case full
	case quantified
}

class ImageClassifier {
	private var model: VNCoreMLModel
	private var startTime: DispatchTime?
	private var endTime: DispatchTime?

	init(modelType: ModelType) {
		guard let mlModel = ImageClassifier.getMLModel(modelType: modelType) else {
			fatalError("Failed to load model")
		}
		self.model = try! VNCoreMLModel(for: mlModel)
	}

	class func getMLModel(modelType: ModelType) -> MLModel? {
		let configuration = MLModelConfiguration()
		var mlModel: MLModel?
		switch modelType {
			case .full:
				mlModel = try? yolov8x_cls_full_300(configuration: configuration).model
			case .quantified:
				mlModel = try? yolov8x_cls_int8_300(configuration: configuration).model
		}
		guard let mlModel = mlModel else {
			fatalError("Failed to load model")
		}
		return mlModel
	}

	func changeModel(modelType: ModelType) {
		if let mlModel = ImageClassifier.getMLModel(modelType: modelType) {
			self.model = try! VNCoreMLModel(for: mlModel)
		}
	}

	func classify(image: UIImage, completion: @escaping (String?, Float?, Double?) -> Void) {
		guard let ciImage = CIImage(image: image) else {
			completion(nil, nil, nil)
			return
		}

		let request = VNCoreMLRequest(model: model) { request, error in
			self.endTime = DispatchTime.now()

			var elapsedTimeInSeconds: Double?
			if let start = self.startTime, let end = self.endTime {
				let elapsedNanoseconds = end.uptimeNanoseconds - start.uptimeNanoseconds
				elapsedTimeInSeconds = Double(elapsedNanoseconds) * 1e-9
			}

			if let error = error {
				print("Error during classification: \(error.localizedDescription)")
				completion(nil, nil, elapsedTimeInSeconds)
				return
			}

			guard let results = request.results as? [VNClassificationObservation] else {
				print("No results found")
				completion(nil, nil, elapsedTimeInSeconds)
				return
			}

			let topResult = results.max(by: { a, b in a.confidence < b.confidence })
			guard let bestResult = topResult else {
				print("No top result found")
				completion(nil, nil, elapsedTimeInSeconds)
				return
			}

			completion(bestResult.identifier, bestResult.confidence, elapsedTimeInSeconds)
		}

		let handler = VNImageRequestHandler(ciImage: ciImage)
		DispatchQueue.global(qos: .userInteractive).async {
			do {
				self.startTime = DispatchTime.now()
				self.endTime = nil
				try handler.perform([request])
			} catch {
				var elapsedTimeInSeconds: Double?
				if let start = self.startTime, let end = self.endTime {
					let elapsedNanoseconds = end.uptimeNanoseconds - start.uptimeNanoseconds
					elapsedTimeInSeconds = Double(elapsedNanoseconds) * 1e-9
				}

				print("Failed to perform classification: \(error.localizedDescription)")
				completion(nil, nil, elapsedTimeInSeconds)
			}
		}
	}
}
