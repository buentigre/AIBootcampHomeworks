//
//  UIImage+Helpers.swift
//  FannyFaces
//
//  Created by Marcin Kosobudzki on 28.09.24.
//

import UIKit
import Vision

enum EyePosition {
	case left
	case right
}

enum PupilPosition {
	case detected
	case center
	case random // not implemented
}

extension UIImage {

	func drawVisionFace(_ visionFace: VisionFace?, toggles: Toggles) -> UIImage? {
		print("Original UIImage orientation: \(self.imageOrientation.rawValue)")

		// Ensure the image's CGImage representation is available.
		guard let cgImage = self.cgImage else {
			return nil
		}

		// If visionFace is not provided, return the original image.
		guard let visionFace = visionFace else {
			return self
		}

		// Prepare the context size based on the image dimensions.
		let imageSize = CGSize(width: cgImage.width, height: cgImage.height)

		// Begin a new image context with the correct size and scale.
		UIGraphicsBeginImageContextWithOptions(imageSize, false, self.scale)
		guard let context = UIGraphicsGetCurrentContext() else {
			return nil
		}

		// Draw the original image in the context.
		context.draw(cgImage, in: CGRect(origin: .zero, size: imageSize))

		//-------------------- Drawing face landmarks --------------------

		// Testing only:
		// let faceLandmarks = Utils.isSimulator() ? MockFactory.mockedFace() : visionFace
		let faceLandmarks = visionFace

		let correctedFaceRect = denormalizedFaceBounds(faceLandmarks.faceRectangle, imageSize: imageSize)
		if toggles.faceBoundary {
			drawFaceRect(rect: correctedFaceRect, imageSize: imageSize, color: .blue, lineWidth: 2.0, filled: true)
		}

		if !Utils.isSimulator() {
			if toggles.nose {
				drawFaceLine(context: context, faceBounds: correctedFaceRect, points: faceLandmarks.nose, color: .red)
			}

			if toggles.leftEye {
				drawFaceEye(context: context, faceBounds: correctedFaceRect, visionFace: faceLandmarks, eyePosition: .left, pupilPosition: toggles.detectPupils ? .detected : .center)
			}
			if toggles.rightEye {
				drawFaceEye(context: context, faceBounds: correctedFaceRect, visionFace: faceLandmarks, eyePosition: .right, pupilPosition: toggles.detectPupils ? .detected : .center)
			}
		}

		//-------------------- Finalizing drawing --------------------

		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		guard let finalCgImage = newImage?.cgImage else {
			return nil
		}

		let correctlyOrientedImage = UIImage(
			cgImage: finalCgImage,
			scale: self.scale,
			orientation: self.adjustOrientation()
		)
		print("Final image orientation: \(correctlyOrientedImage.imageOrientation.rawValue)")
		return correctlyOrientedImage
	}
}

private extension UIImage {

	private func denormalizedFaceBounds(_ normalizedFaceBounds: CGRect, imageSize: CGSize) -> CGRect {
		return VNImageRectForNormalizedRect(normalizedFaceBounds, Int(imageSize.width), Int(imageSize.height))
	}

	private func drawFaceRect(rect: CGRect, imageSize: CGSize, color: UIColor, lineWidth: CGFloat, filled: Bool) {
		color.withAlphaComponent(0.2).setFill()
		let rectPath = UIBezierPath(rect: rect)
		if filled {
			rectPath.fill()
		}
		color.setStroke()
		rectPath.lineWidth = lineWidth
		rectPath.stroke()
	}

	private func drawFaceEye(context: CGContext, faceBounds: CGRect, visionFace: VisionFace, eyePosition: EyePosition, pupilPosition: PupilPosition) {
		var eyePoints: [CGPoint] = []
		var pupilPoints: [CGPoint] = []
		switch eyePosition {
			case .left:
				eyePoints = visionFace.leftEye
				pupilPoints = visionFace.leftPupil
			case .right:
				eyePoints = visionFace.rightEye
				pupilPoints = visionFace.rightPupil
		}

		let correctedEyePoints = toFacePoints(from: eyePoints, to: faceBounds)
		let correctedPupilPoints = toFacePoints(from: pupilPoints, to: faceBounds)
		let eyeRect = drawEyeOval(context: context, points: correctedEyePoints, oversizeFactor: 2.0, color: .white)
		drawPupilOval(context: context, points: correctedPupilPoints, parentEyeRect: eyeRect, pupilPosition: pupilPosition, color: .black)
	}

	private func drawEyeOval(context: CGContext, points: [CGPoint], oversizeFactor: CGFloat, color: UIColor) -> CGRect {
		guard let rect = CGRect(points: points) else {
			return .zero
		}

		let proportionsFactor: CGFloat = 0.75
		let oversizedWidth = rect.width * oversizeFactor
		var oversizedHeight = rect.height * oversizeFactor
		let minOversizedHeight = oversizedWidth * proportionsFactor
		if oversizedHeight < minOversizedHeight {
			oversizedHeight = minOversizedHeight
		}
		let orgCenter = CGPoint(x: rect.minX + rect.width / 2, y: rect.minY + rect.height / 2)
		let oversizedRect = CGRect(origin: CGPoint(x: orgCenter.x - oversizedWidth / 2, y: orgCenter.y - oversizedHeight / 2), size: CGSize(width: oversizedWidth, height: oversizedHeight))

		let ovalPath = UIBezierPath(ovalIn: oversizedRect)
		color.setFill()
		ovalPath.fill()

		return oversizedRect
	}

	private func drawPupilOval(context: CGContext, points: [CGPoint], parentEyeRect: CGRect, pupilPosition: PupilPosition, color: UIColor) {

		let pupilScaleFactor: CGFloat = 0.6
		let parenEyeCenter = CGPoint(x: parentEyeRect.minX + parentEyeRect.width / 2, y: parentEyeRect.minY + parentEyeRect.height / 2)
		let parentEyeMaxInnerOvalSize = min(parentEyeRect.width, parentEyeRect.height) * pupilScaleFactor

		var pupilRect: CGRect = .zero
		switch pupilPosition {
			case .detected:
				let minX = points.min(by: { $0.x < $1.x })?.x ?? 0
				let maxX = points.max(by: { $0.x > $1.x })?.x ?? 0
				let minY = points.min(by: { $0.y < $1.y })?.y ?? 0
				let maxY = points.max(by: { $0.y > $1.y })?.y ?? 0
				let avgPoint = CGPoint(x: (minX + maxX) / 2, y: (minY + maxY) / 2)
				pupilRect = CGRect(origin: CGPoint(x: avgPoint.x - parentEyeMaxInnerOvalSize / 2, y: avgPoint.y - parentEyeMaxInnerOvalSize / 2), size: CGSize(width: parentEyeMaxInnerOvalSize, height: parentEyeMaxInnerOvalSize))

			case .center:
				pupilRect = CGRect(origin: CGPoint(x: parenEyeCenter.x - parentEyeMaxInnerOvalSize / 2, y: parenEyeCenter.y - parentEyeMaxInnerOvalSize / 2), size: CGSize(width: parentEyeMaxInnerOvalSize, height: parentEyeMaxInnerOvalSize))
			default:
				// not implemented
				break
		}

		let ovalPath = UIBezierPath(ovalIn: pupilRect)
		color.setFill()
		ovalPath.fill()
	}

	private func drawFaceLine(context: CGContext, faceBounds: CGRect, points: [CGPoint], color: UIColor) {
		let correctedPoints = toFacePoints(from: points, to: faceBounds)

		color.setStroke()
		context.setLineWidth(10)
		context.addLines(between: correctedPoints)
		context.closePath()
		context.strokePath()
	}

	private func toFacePoints(from points: [CGPoint], to boundingBoxRect: CGRect) -> [CGPoint] {
		let denormalizedPoints = toDenormalizedPoints(from: points, to: boundingBoxRect)
		return toBoundingPoints(from: denormalizedPoints, to: boundingBoxRect)
	}

	private func toDenormalizedPoints(from points: [CGPoint], to boundingBoxRect: CGRect) -> [CGPoint] {
		return points.compactMap { VNImagePointForNormalizedPoint($0, Int(boundingBoxRect.size.width), Int(boundingBoxRect.size.height)) }
	}

	private func toBoundingPoints(from points: [CGPoint], to boundingBoxRect: CGRect) -> [CGPoint] {
		return points.compactMap { CGPoint(x: $0.x + boundingBoxRect.origin.x, y: $0.y + boundingBoxRect.origin.y) }
	}

	private func adjustOrientation() -> UIImage.Orientation {
		switch self.imageOrientation {
			case .up:
				return .downMirrored
			case .upMirrored:
				return .up
			case .down:
				return .upMirrored
			case .downMirrored:
				return .down
			case .left:
				return .rightMirrored
			case .rightMirrored:
				return .left
			case .right:
				return .leftMirrored
			case .leftMirrored:
				return .right
			@unknown default:
				return self.imageOrientation
		}
	}
}

