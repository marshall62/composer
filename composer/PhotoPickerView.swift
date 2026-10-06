//
//  PhotoPickerView.swift
//  composer
//
//  Created by David Marshall on 9/22/26.
//
import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    let canvasSettings: CanvasSettings

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    @State private var showPhotoPicker = false


    var body: some View {
        Group {
            if let selectedUIImage {
                CropView(
                    uiImage: selectedUIImage,
                    canvasWidth: canvasSettings.width,
                    canvasHeight: canvasSettings.height,
                    gridType: canvasSettings.gridType,
                    onChooseNewPhoto: { showPhotoPicker = true }
                )
                .id(selectedItem)
            } else {
                Button("Choose a Photo") { showPhotoPicker = true }
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedUIImage = uiImage
                }
            }
        }
    }
}
