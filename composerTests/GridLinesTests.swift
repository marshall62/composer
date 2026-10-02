//
//  GridLinesTests.swift
//  composer
//
//  Created by David Marshall on 9/30/26.
//

import Testing
import CoreGraphics
@testable import composer

struct GridLinesTests {
    @Test func evenGridProduces3VerticalAnd3HorizontalLinesFor4x4() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 200)
        let lines = evenGridLines(for: rect, columns: 4, rows: 4)

        #expect(lines.count == 6)
        #expect(lines.contains(LineSegment(start: CGPoint(x: 25, y: 0), end: CGPoint(x: 25, y: 200))))
        #expect(lines.contains(LineSegment(start: CGPoint(x: 0, y: 50), end: CGPoint(x: 100, y: 50))))
    }
    
    @Test func evenGridProduces7VerticalAnd7HorizontalLinesFor8x8() {
        let h : CGFloat = 400
        let w: CGFloat = 800
        let rect = CGRect(x: 0, y: 0, width: w, height: h)
        let lines = evenGridLines(for: rect, columns: 8, rows: 8)

        #expect(lines.count == 14)
        for i in stride(from: 100, through: w-100, by: 100) {
            #expect(lines.contains(LineSegment(start: CGPoint(x: i, y: 0), end: CGPoint(x: i, y: h))))
        }
        for i in stride(from: 50, through: h-50, by: 50) {
            #expect(lines.contains(LineSegment(start: CGPoint(x: 0, y: i), end: CGPoint(x: w, y: i))))
        }

    }
    
    @Test func squareGridLeavesLeftoverStripWhenNotEvenlyDivisible() {
        let rect = CGRect(x: 0, y: 0, width: 1200, height: 1600)
        let lines = squareGridLines(for: rect, canvasWidth: 12, canvasHeight: 16, squareSize: 3)

        // width: 12/3 = 4 exactly, so the last vertical line lands right on the rect's edge
        #expect(lines.contains(LineSegment(start: CGPoint(x: 1200, y: 0), end: CGPoint(x: 1200, y: 1600))))

        // height: 16/3 = 5 remainder 1, so squares stop short of the bottom edge
        #expect(lines.contains(LineSegment(start: CGPoint(x: 0, y: 1500), end: CGPoint(x: 1200, y: 1500))))
        #expect(!lines.contains(LineSegment(start: CGPoint(x: 0, y: 1600), end: CGPoint(x: 1200, y: 1600))))
    }
}
