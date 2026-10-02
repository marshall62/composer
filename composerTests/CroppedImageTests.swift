//
//  CroppedImageTests.swift
//  composer
//
//  Created by David Marshall on 9/30/26.
//

import Testing
import UIKit
@testable import composer

struct CroppedImageTests {
    @Test func croppedImageHasExpectedSize() {
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        UIColor.red.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let rect = CGRect(x: 10, y: 10, width: 40, height: 30)
        let result = croppedImage(image, to: rect)

        #expect(result?.size == CGSize(width: 40, height: 30))
    }
}
