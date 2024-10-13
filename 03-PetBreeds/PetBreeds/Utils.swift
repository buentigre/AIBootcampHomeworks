//
//  Utils.swift
//  PetBreeds
//
//  Created by Marcin Kosobudzki on 13.10.24.
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
