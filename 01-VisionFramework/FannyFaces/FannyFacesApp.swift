//
//  FannyFacesApp.swift
//  FannyFaces
//
//  Created by Marcin Kosobudzki on 27.09.24.
//

import SwiftUI
import PhotosUI

@main
struct FannyFacesApp: App {

	@StateObject private var photoPickerViewModel = PhotoPickerViewModel()

	var body: some Scene {
		WindowGroup {
			NavigationView {
				PhotosViewTab(viewModel: ImageViewModel(photoPickerViewModel: photoPickerViewModel))
				.navigationTitle("Funny faces")
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						PhotosPicker(
							selection: $photoPickerViewModel.imageSelection,
							matching: .images,
							photoLibrary: .shared()
						) {
							Image(systemName: "photo.badge.plus")
								.imageScale(.large)
						}
						.simultaneousGesture(TapGesture()
							.onEnded({
								NotificationCenter.default.post(name: Notification.Name.photoPickerSelected, object: nil)
							})
						)
					}
				}
			}
		}
    }
}

extension Notification.Name {
	static let photoPickerSelected = Notification.Name("PhotoPickerSelected")
}
