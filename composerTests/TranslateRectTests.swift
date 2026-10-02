//
//  TranslateRectTests.swift
//  composer
//
//  Created by David Marshall on 9/28/26.
//

import Testing
import CoreGraphics
@testable import composer

struct TranslateRectTests {
    @Test func movesWithinBoundsUnclamped() {
        let rect = CGRect(x: 10, y: 10, width: 50, height: 50)
        let result = translateRect(rect, by: CGSize(width: 5, height: 5), imageBounds: CGSize(width: 100, height: 100))

        #expect(result == CGRect(x: 15, y: 15, width: 50, height: 50))
    }
    
    @Test func movesBackWithinBoundsUnclamped() {
        let rect = CGRect(x: 10, y: 10, width: 50, height: 50)
        let result = translateRect(rect, by: CGSize(width: -5, height: -5), imageBounds: CGSize(width: 100, height: 100))

        #expect(result == CGRect(x: 5, y: 5, width: 50, height: 50))
    }
    
    @Test func movesLeftAndUpWithinBoundsClamped() {
        let rect = CGRect(x: 10, y: 10, width: 50, height: 50)
        let result = translateRect(rect, by: CGSize(width: -20, height: -15), imageBounds: CGSize(width: 100, height: 100))

        #expect(result == CGRect(x: 0, y: 0, width: 50, height: 50))
    }
    
    @Test func movesRightAndDownWithinBoundsClamped() {
        let rect = CGRect(x: 10, y: 10, width: 50, height: 50)
        let result = translateRect(rect, by: CGSize(width: 60, height: 70), imageBounds: CGSize(width: 100, height: 100))

        #expect(result == CGRect(x: 50, y: 50, width: 50, height: 50))
    }
}
