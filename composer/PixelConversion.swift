//
//  PixelConversion.swift
//  composer
//
//  Created by David Marshall on 9/30/26.
//

import CoreGraphics

func convertToImagePixels(_ rect: CGRect, scale: CGFloat) -> CGRect {
    CGRect(x: rect.origin.x / scale, y: rect.origin.y / scale, width: rect.width / scale, height: rect.height / scale)
}
