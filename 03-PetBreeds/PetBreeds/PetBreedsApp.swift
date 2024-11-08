//
//  PetBreedsApp.swift
//  PetBreeds
//
//  Created by Marcin Kosobudzki on 13.10.24.
//

import SwiftUI
import PhotosUI

@main
struct PetBreedsApp: App {

	@StateObject private var photoPickerViewModel = PhotoPickerViewModel()

	var body: some Scene {
		WindowGroup {
			NavigationView {
				ContentView(viewModel: PetImageViewModel(photoPickerViewModel: photoPickerViewModel))
					.navigationTitle("Pet Breeds")
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							PhotosPicker(
								selection: $photoPickerViewModel.imageSelection,
								matching: .images,
								photoLibrary: .shared()) {
								Image(systemName: "photo.badge.plus")
									.imageScale(.large)
							}
							.simultaneousGesture(TapGesture()
								.onEnded({
									NotificationCenter.default.post(name: Notification.Name.photoSelected, object: nil)
								})
							)
						}
					}
			}
		}
	}
}

extension Notification.Name {
	static let photoSelected = Notification.Name("PhotoSelected")
}
