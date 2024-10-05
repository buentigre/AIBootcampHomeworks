//
//  Utils.swift
//  FannyFaces
//
//  Created by Marcin Kosobudzki on 29.09.24.
//

class Utils {

	class func isSimulator() -> Bool {
#if targetEnvironment(simulator)
		return true
#else
		return false
#endif
	}
}
