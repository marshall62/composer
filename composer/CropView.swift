//
//  CropView.swift
//  composer
//
//  Created by David Marshall on 9/29/26.
//
import SwiftUI

struct CropView: View {
    let uiImage: UIImage
    let canvasWidth: Double
    let canvasHeight: Double
    let gridType: GridType
    let onChooseNewPhoto: () -> Void

    @State private var currentCanvasWidth: Double
    @State private var currentCanvasHeight: Double

    @State private var proposedRect: CGRect?
    @State private var creatingNewRect = false
    @State private var resizeAnchor: CGPoint?
    @State private var rectAtDragStart: CGRect?
    @State private var croppedUIImage: UIImage?
    @State private var showDimensionsEditor = false
    @State private var editWidth: Double?
    @State private var editHeight: Double?

    private var aspectRatio: CGFloat { CGFloat(currentCanvasWidth / currentCanvasHeight) }
    private var image: Image { Image(uiImage: uiImage) }
    private var imageSize: CGSize { uiImage.size }

    init(uiImage: UIImage, canvasWidth: Double, canvasHeight: Double, gridType: GridType, onChooseNewPhoto: @escaping () -> Void) {
        self.uiImage = uiImage
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.gridType = gridType
        self.onChooseNewPhoto = onChooseNewPhoto
        _currentCanvasWidth = State(initialValue: canvasWidth)
        _currentCanvasHeight = State(initialValue: canvasHeight)
    }

    private func resetCropInProgress() {
        proposedRect = nil
        creatingNewRect = false
        resizeAnchor = nil
        rectAtDragStart = nil
    }

    var body: some View {
        if let cropped = croppedUIImage {
            GriddedCropView(uiImage: cropped, canvasWidth: currentCanvasWidth, canvasHeight: currentCanvasHeight, gridType: gridType, onChooseNewPhoto: onChooseNewPhoto)
        } else {
            GeometryReader { geo in
                let containerSize = geo.size
                let scale = min(containerSize.width / imageSize.width, containerSize.height / imageSize.height)
                let displaySize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
                let offset = CGPoint(
                    x: (containerSize.width - displaySize.width) / 2,
                    y: (containerSize.height - displaySize.height) / 2
                )

                ZStack(alignment: .topLeading) {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: containerSize.width, height: containerSize.height)
                        // The initial cropping gesture
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let start = CGPoint(x: value.startLocation.x - offset.x, y: value.startLocation.y - offset.y)
                                    let current = CGPoint(x: value.location.x - offset.x, y: value.location.y - offset.y)
                                    if proposedRect == nil { creatingNewRect = true }
                                    if creatingNewRect {
                                        proposedRect = cropRect(from: start, to: current, aspectRatio: aspectRatio, imageBounds: displaySize)
                                    }
                                }
                                .onEnded { _ in
                                            creatingNewRect = false
                                        }
                        )

                    if let rect = proposedRect {
                        let screenRect = CGRect(x: rect.minX + offset.x, y: rect.minY + offset.y, width: rect.width, height: rect.height)

                        Rectangle()
                            .stroke(Color.yellow, lineWidth: 2)
                            .frame(width: screenRect.width, height: screenRect.height)
                            .position(x: screenRect.midX, y: screenRect.midY)
                            .contentShape(Rectangle())
                            // The translate gesture
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if rectAtDragStart == nil { rectAtDragStart = rect }
                                        if let base = rectAtDragStart {
                                            proposedRect = translateRect(base, by: value.translation, imageBounds: displaySize)
                                        }
                                    }
                                    .onEnded { _ in
                                        rectAtDragStart = nil
                                        creatingNewRect = false
                                    }
                            )

                        ZStack {
                            Color.clear.frame(width: 44, height: 44).contentShape(Rectangle())
                            Circle().fill(Color.yellow).frame(width: 25, height: 25)
                        }
                        .position(x: screenRect.maxX, y: screenRect.maxY)
                        // resize gestures
                        // from bottom right first
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if resizeAnchor == nil { resizeAnchor = rect.origin }
                                    if let anchor = resizeAnchor {
                                        let current = CGPoint(x: value.location.x - offset.x, y: value.location.y - offset.y)
                                        proposedRect = cropRect(from: anchor, to: current, aspectRatio: aspectRatio, imageBounds: displaySize)
                                    }
                                }
                                .onEnded { _ in
                                    resizeAnchor = nil
                                    creatingNewRect = false
                                }
                        )

                        ZStack {
                            Color.clear.frame(width: 44, height: 44).contentShape(Rectangle())
                            Circle().fill(Color.yellow).frame(width: 25, height: 25)
                        }
                        .position(x: screenRect.minX, y: screenRect.minY)
                        // from top left resize
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if resizeAnchor == nil { resizeAnchor = CGPoint(x: rect.maxX, y: rect.maxY) }
                                    if let anchor = resizeAnchor {
                                        let current = CGPoint(x: value.location.x - offset.x, y: value.location.y - offset.y)
                                        proposedRect = resizeFromTopLeft(anchor: anchor, current: current, aspectRatio: aspectRatio)
                                    }
                                }
                                .onEnded { _ in
                                    resizeAnchor = nil
                                    creatingNewRect = false
                                }
                        )

                        if !creatingNewRect {
                            Button("Accept") {
                                let pixelRect = convertToImagePixels(rect, scale: scale)
                                croppedUIImage = croppedImage(uiImage, to: pixelRect)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .position(x: screenRect.midX, y: screenRect.maxY - 20)
                        }
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Menu {
                        Button("Swap Canvas Dimensions") {
                            swap(&currentCanvasWidth, &currentCanvasHeight)
                            resetCropInProgress()
                        }
                        Button("Choose Different Photo") {
                            onChooseNewPhoto()
                        }
                        Button("Change Canvas Dimensions") {
                            editWidth = currentCanvasWidth
                            editHeight = currentCanvasHeight
                            showDimensionsEditor = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title2)
                            .padding()
                    }
                }
            }.padding(.top, 24)
                .sheet(isPresented: $showDimensionsEditor) {
                    NavigationStack {
                        Form {
                            TextField("Width", value: $editWidth, format: .number)
                                .keyboardType(.decimalPad)
                            TextField("Height", value: $editHeight, format: .number)
                                .keyboardType(.decimalPad)

                            let errors = blockingErrors(for: CanvasSettings(width: editWidth ?? 0, height: editHeight ?? 0, gridType: gridType))
                            if !errors.isEmpty {
                                Text(errors.joined(separator: "\n"))
                                    .foregroundStyle(.red)
                            }

                            Button("Apply") {
                                currentCanvasWidth = editWidth ?? currentCanvasWidth
                                currentCanvasHeight = editHeight ?? currentCanvasHeight
                                resetCropInProgress()
                                showDimensionsEditor = false
                            }
                            .disabled(!errors.isEmpty)
                        }
                        .navigationTitle("Canvas Dimensions")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { showDimensionsEditor = false }
                            }
                        }
                    }
                    .presentationDetents([.medium])
                }
        }
    }
}
