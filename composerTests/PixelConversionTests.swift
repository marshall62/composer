//
//  PixelConversionTests.swift
//  composer
//
//  Created by David Marshall on 9/30/26.
//

import Testing
import CoreGraphics
@testable import composer

struct PixelConversionTests {
    @Test func convertsDisplayRectToImagePixels() {
        let displayRect = CGRect(x: 30, y: 20, width: 100, height: 50)
        let pixelRect = convertToImagePixels(displayRect, scale: 0.5)

        #expect(pixelRect == CGRect(x: 60, y: 40, width: 200, height: 100))
    }
}
