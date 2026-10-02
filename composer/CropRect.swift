//
//  CropRect.swift
//  composer
//
//  Created by David Marshall on 9/28/26.
//

import CoreGraphics

func cropRect(from start: CGPoint, to current: CGPoint, aspectRatio: CGFloat, imageBounds: CGSize) -> CGRect {
    // used for dragging on the lower right corner and sizing the rectangle strictly by the horizontal movement
    let desiredWidth = max(0, current.x - start.x)

    let maxWidthFromImage = imageBounds.width - start.x
    // only allow width growth in pixels based on how many pixels of growth are available in width or height
    let maxHeightFromImage = imageBounds.height - start.y
    let maxAllowedWidth = max(0, min(maxWidthFromImage, maxHeightFromImage * aspectRatio))
    let width = min(desiredWidth, maxAllowedWidth)
    let height = width / aspectRatio

    return CGRect(x: start.x, y: start.y, width: width, height: height)
}


func resizeFromTopLeft(anchor: CGPoint, current: CGPoint, aspectRatio: CGFloat) -> CGRect {
    // Growth from the upper left hand corner is governed only by horizontal movement
    let widthFromHorizontal = max(0, anchor.x - current.x)
    let desiredWidth = widthFromHorizontal
    let maxAllowedWidth = max(0, min(anchor.x, anchor.y * aspectRatio))
    let width = min(desiredWidth, maxAllowedWidth)
    let height = width / aspectRatio

    let origin = CGPoint(x: anchor.x - width, y: anchor.y - height)
    return CGRect(origin: origin, size: CGSize(width: width, height: height))
}

