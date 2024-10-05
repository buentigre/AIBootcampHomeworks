//
//  MocksFactory.swift
//  FannyFaces
//
//  Created by Marcin Kosobudzki on 29.09.24.
//

import UIKit

class MockFactory {

	class func mockedFace() -> VisionFace {
		var face = VisionFace()
		face.faceRectangle = faceRectangle
		face.leftEye = leftEye
		face.rightEye = rightEye
		face.leftPupil = leftPupil
		face.rightPupil = rightPupil
		face.nose = nose
		return face
	}

	static let faceRectangle = CGRect(x: 0.19415320456027985,
									  y: 0.19279347360134125,
									  width: 0.61358964443206787,
									  height: 0.61358964443206787)

	static let leftEye = [
		CGPoint	(x: 0.24166476726531982, y: 0.71826177835464478),
		CGPoint	(x: 0.28504341840744019, y: 0.74983322620391846),
		CGPoint	(x: 0.35434660315513611, y: 0.74367296695709229),
		CGPoint	(x: 0.39515849947929382, y: 0.70773798227310181),
		CGPoint	(x: 0.34844300150871277, y: 0.69952428340911865),
		CGPoint	(x: 0.28504341840744019, y: 0.69824087619781494)]


	static let rightEye = [
		CGPoint	(x: 0.76015526056289673, y: 0.71569502353668213),
		CGPoint	(x: 0.71651995182037354, y: 0.74777978658676147),
		CGPoint	(x: 0.64567667245864868, y: 0.74213290214538574),
		CGPoint	(x: 0.6040947437286377, y: 0.70696794986724854),
		CGPoint	(x: 0.65183693170547485, y: 0.69849753379821777),
		CGPoint	(x: 0.7160065770149231, y: 0.69644409418106079)]


	static let leftPupil = [CGPoint(x: 0.31250801682472229, y: 0.72852891683578491)]
	static let rightPupil = [CGPoint(x: 0.68777191638946533, y: 0.72673219442367554)]

	static let nose = [
		CGPoint	(x: 0.4968031644821167, y: 0.67667990922927856),
		CGPoint	(x: 0.40722239017486572, y: 0.55835109949111938),
		CGPoint	(x: 0.4069657027721405, y: 0.46569019556045532),
		CGPoint	(x: 0.4529111385345459, y: 0.46877032518386841),
		CGPoint	(x: 0.49731650948524475, y: 0.46261003613471985),
		CGPoint	(x: 0.54300528764724731, y: 0.46825698018074036),
		CGPoint	(x: 0.58920741081237793, y: 0.46363675594329834),
		CGPoint	(x: 0.58920741081237793, y: 0.55655437707901001)]

}

