//
//  TranslateHWApp.swift
//  TranslateHW
//
//  Created by Marcin Kosobudzki on 03.10.24.
//

import SwiftUI

@main
struct ApplicationMain: App {

	@State private var viewModel = ViewModel()

	init() {
		let titleColor = UIColor.lightGray
		UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: titleColor]
		UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: titleColor]
	}

    var body: some Scene {
        WindowGroup {
			NavigationView {
				TabView {
					OverlayPresentationTabView()
						.tabItem {
							Label("Overlay Presentation", systemImage: "arrow.up.page.on.clipboard")
						}
					BatchProcessingTabView().environment(viewModel)
						.tabItem {
							Label("Batch Processing", systemImage: "chart.bar.horizontal.page")
						}
				}
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("Translation Framework Homework")
			}
        }
    }
}
