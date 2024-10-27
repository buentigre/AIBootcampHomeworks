//
//  Utils.swift
//  myChatGPT
//
//  Created by Marcin Kosobudzki on 27.10.24.
//

import Network
import SwiftUI

class Utils {

	static var isNetworkMonitoringInProgress: Bool = false
	static let networkMonitor = NWPathMonitor()

	class func startMonitoringNetworkConnection() {
		guard !isNetworkMonitoringInProgress else {
			return
		}

		networkMonitor.pathUpdateHandler = { path in
			DispatchQueue.main.async {
				if path.status == .satisfied {
					NotificationCenter.default.post(name: Notification.Name.netConnPositiveNotification, object: nil)
				} else {
					NotificationCenter.default.post(name: Notification.Name.netConnNegativeNotification, object: nil)
				}
			}
		}

		let queue = DispatchQueue(label: "ChatGPTNetworkMonitor")
		networkMonitor.start(queue: queue)
		isNetworkMonitoringInProgress = true
	}

	class func stopMonitoringNetworkConnection() {
		networkMonitor.cancel()
		isNetworkMonitoringInProgress = false
	}


	class func isSimulator() -> Bool {
#if targetEnvironment(simulator)
		return true
#else
		return false
#endif
	}
}

extension Notification.Name {
	static let netConnPositiveNotification = Notification.Name("NetworkConnectionPositiveNotification")
	static let netConnNegativeNotification = Notification.Name("NetworkConnectionNegativeNotification")
}
