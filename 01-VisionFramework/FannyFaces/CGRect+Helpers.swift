//
//  CGRect+Helpers.swift
//  FannyFaces
//
//  Created by Marcin Kosobudzki on 29.09.24.
//

import UIKit

extension CGRect {	
	init?(points: [CGPoint]) {
		let xArray = points.map(\.x)
		let yArray = points.map(\.y)
		if  let minX = xArray.min(),
			let maxX = xArray.max(),
			let minY = yArray.min(),
			let maxY = yArray.max() {

			self.init(x: minX, y: minY, width: maxX - minX, height: maxY - minY)

		} else {
			return nil
		}
	}
}
