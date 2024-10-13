//
//  ImageViewModel.swift
//  PetBreeds
//
//  Created by Marcin Kosobudzki on 13.10.24.
//

import SwiftUI

class ImageViewModel: ObservableObject {
	@Published var errorMessage: String? = nil
	@Published var photoPickerViewModel: PhotoPickerViewModel

	init(photoPickerViewModel: PhotoPickerViewModel) {
		self.photoPickerViewModel = photoPickerViewModel
	}	
}
