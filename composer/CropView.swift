//
//  CropView.swift
//  composer
//
//  Created by David Marshall on 9/29/26.
//
import SwiftUI

struct CropView: View {
    let uiImage: UIImage
    let aspectRatio: CGFloat
    let canvasWidth: Double
    let canvasHeight: Double
    let gridType: GridType
    let onChooseNewPhoto: () -> Void

    private var image: Image { Image(uiImage: uiImage) }
    private var imageSize: CGSize { uiImage.size }

    @State private var proposedRect: CGRect?
    @State private var creatingNewRect = false
    @State private var hasReleasedInitialDrag = false
    @State private var resizeAnchor: CGPoint?
    @State private var rectAtDragStart: CGRect?
    @State private var croppedUIImage: UIImage?

    var body: some View {
        if let cropped = croppedUIImage {
            GriddedCropView(uiImage: cropped, canvasWidth: canvasWidth, canvasHeight: canvasHeight, gridType: gridType, onChooseNewPhoto: onChooseNewPhoto)

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
                                    hasReleasedInitialDrag = true
                                }
                        )

                    if let rect = proposedRect {
                        let screenRect = CGRect(x: rect.minX + offset.x, y: rect.minY + offset.y, width: rect.width, height: rect.height)

                        Rectangle()
                            .stroke(Color.yellow, lineWidth: 2)
                            .frame(width: screenRect.width, height: screenRect.height)
                            .position(x: screenRect.midX, y: screenRect.midY)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if rectAtDragStart == nil { rectAtDragStart = rect }
                                        if let base = rectAtDragStart {
                                            proposedRect = translateRect(base, by: value.translation, imageBounds: displaySize)
                                        }
                                    }
                                    .onEnded { _ in rectAtDragStart = nil }
                            )

                        ZStack {
                            Color.clear.frame(width: 44, height: 44).contentShape(Rectangle())
                            Circle().fill(Color.yellow).frame(width: 25, height: 25)
                        }
                        .position(x: screenRect.maxX, y: screenRect.maxY)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if resizeAnchor == nil { resizeAnchor = rect.origin }
                                    if let anchor = resizeAnchor {
                                        let current = CGPoint(x: value.location.x - offset.x, y: value.location.y - offset.y)
                                        proposedRect = cropRect(from: anchor, to: current, aspectRatio: aspectRatio, imageBounds: displaySize)
                                    }
                                }
                                .onEnded { _ in resizeAnchor = nil }
                        )

                        ZStack {
                            Color.clear.frame(width: 44, height: 44).contentShape(Rectangle())
                            Circle().fill(Color.yellow).frame(width: 25, height: 25)
                        }
                        .position(x: screenRect.minX, y: screenRect.minY)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if resizeAnchor == nil { resizeAnchor = CGPoint(x: rect.maxX, y: rect.maxY) }
                                    if let anchor = resizeAnchor {
                                        let current = CGPoint(x: value.location.x - offset.x, y: value.location.y - offset.y)
                                        proposedRect = resizeFromTopLeft(anchor: anchor, current: current, aspectRatio: aspectRatio)
                                    }
                                }
                                .onEnded { _ in resizeAnchor = nil }
                        )

                        if hasReleasedInitialDrag {
                            Button("Confirm Crop") {
                                let pixelRect = convertToImagePixels(rect, scale: scale)
                                croppedUIImage = croppedImage(uiImage, to: pixelRect)
                            }
                            .buttonStyle(.borderedProminent)
                            .position(x: screenRect.midX, y: min(screenRect.maxY + 30, containerSize.height - 20))
                        }
                    }
                }
            }
        }
    }
}
