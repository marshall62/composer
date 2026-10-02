//
//  TranslateRect.swift
//  composer
//
//  Created by David Marshall on 9/28/26.
//

import CoreGraphics

import CoreGraphics

func translateRect(_ rect: CGRect, by translation: CGSize, imageBounds: CGSize) -> CGRect {
    let newX = rect.origin.x + translation.width
    let newY = rect.origin.y + translation.height

    let clampedX = min(max(0, newX), imageBounds.width - rect.width)
    let clampedY = min(max(0, newY), imageBounds.height - rect.height)

    return CGRect(x: clampedX, y: clampedY, width: rect.width, height: rect.height)
}
