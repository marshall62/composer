//
//  GriddedCropView.swift
//  composer
//
//  Created by David Marshall on 10/2/26.
//

import SwiftUI

struct GriddedCropView: View {
    let uiImage: UIImage
    let canvasWidth: Double
    let canvasHeight: Double
    let onChooseNewPhoto: () -> Void

    @State private var currentGridType: GridType
    @State private var gridColor: Color = .white
    @State private var showGrid = true
    @State private var showColorPicker = false

    @State private var isPosterized = false
    @State private var posterizeLevels: Double = 6
    @State private var showPosterizeSettings = false
    @State private var isBlackAndWhite = false

    @State private var processedImage: UIImage

    init(uiImage: UIImage, canvasWidth: Double, canvasHeight: Double, gridType: GridType, onChooseNewPhoto: @escaping () -> Void) {
        self.uiImage = uiImage
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.onChooseNewPhoto = onChooseNewPhoto
        _currentGridType = State(initialValue: gridType)
        _processedImage = State(initialValue: uiImage)
    }

    private func updateProcessedImage() {
        var result = uiImage
        if isBlackAndWhite { result = desaturated(result) }
        if isPosterized { result = posterized(result, levels: posterizeLevels) }
        processedImage = result
    }

    var body: some View {
        GriddedImageView(
            uiImage: processedImage,
            canvasWidth: canvasWidth,
            canvasHeight: canvasHeight,
            gridType: currentGridType,
            gridColor: gridColor,
            showGrid: showGrid
        )
        .overlay(alignment: .topTrailing) {
            Menu {
                Menu("Grid") {
                    Toggle("Show Grid", isOn: $showGrid)
                    Button("Change Grid Color") { showColorPicker = true }
                    if currentGridType != .eightByEight {
                        Button("Switch to 8x8 Grid") { currentGridType = .eightByEight }
                    }
                    if currentGridType != .fourByFour {
                        Button("Switch to 4x4 Grid") { currentGridType = .fourByFour }
                    }
                }
                Menu("Effects") {
                    Button("Posterize Settings") { showPosterizeSettings = true }
                    Toggle("Black & White", isOn: $isBlackAndWhite)
                }
                Button("Choose New Photo") { onChooseNewPhoto() }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.title2)
                    .padding()
            }
        }
        .onChange(of: isPosterized) { updateProcessedImage() }
        .onChange(of: isBlackAndWhite) { updateProcessedImage() }
        .onChange(of: posterizeLevels) { updateProcessedImage() }
        .sheet(isPresented: $showColorPicker) {
            NavigationStack {
                ColorPicker("Grid Color", selection: $gridColor)
                    .padding()
                    .navigationTitle("Grid Color")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showColorPicker = false }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showPosterizeSettings) {
            NavigationStack {
                Form {
                    Toggle("Posterize", isOn: $isPosterized)
                    if isPosterized {
                        VStack(alignment: .leading) {
                            Text("Levels: \(Int(posterizeLevels))")
                            Slider(value: $posterizeLevels, in: 2...10, step: 1)
                        }
                    }
                }
                .navigationTitle("Posterize")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showPosterizeSettings = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}
