//
//  CropRectTests.swift
//  composer
//
//  Created by David Marshall on 9/28/26.
//

import Testing
import CoreGraphics
@testable import composer

struct CropRectTests {
    @Test func widthDrivenByHorizontalDragOnly() {
        let start = CGPoint(x: 0, y: 0)
        let current = CGPoint(x: 100, y: 10)
        let bounds = CGSize(width: 1000, height: 800)
        let rect = cropRect(from: start, to: current, aspectRatio: 2.0, imageBounds: bounds)

        #expect(rect == CGRect(x: 0, y: 0, width: 100, height: 50))
    }
    
    @Test func clampsToImageBoundsWhenDraggingPastEdge() {
        let start = CGPoint(x: 400, y: 0)
        let current = CGPoint(x: 509, y: 10)
        let bounds = CGSize(width: 500, height: 800)
        let rect = cropRect(from: start, to: current, aspectRatio: 2.0, imageBounds: bounds)

        #expect(rect == CGRect(x: 400, y: 0, width: 100, height: 50))
    }
    
    @Test func remainingVerticalConstrainsWidth() {
        let start = CGPoint(x:100, y: 100)
        let current = CGPoint(x:500, y: 100)
        let bounds = CGSize(width:500, height: 200)
        // trying to grow by 400 in width => 200 height but we only have 100 pixels of height left
        // so that is what governs the rect to be (200, 100)
        let rect = cropRect(from: start, to: current, aspectRatio: 2.0, imageBounds: bounds)
        #expect(rect == CGRect(x: start.x, y: start.y, width: 200, height: 100))
    }
    
    @Test func resizesFromTopLeftAnchoredAtOppositeCorner() {
        let anchor = CGPoint(x: 100, y: 50)
        let current = CGPoint(x: 70, y: 10)

        let rect = resizeFromTopLeft(anchor: anchor, current: current, aspectRatio: 2.0)

        #expect(rect == CGRect(x: 70, y: 35, width: 30, height: 15))
    }
    
    @Test func remainingWidthConstrainsGrowthUpwards() {
        let anchor = CGPoint(x: 100, y: 100)
        let current = CGPoint(x: 0, y: 80)

        let rect = resizeFromTopLeft(anchor: anchor, current: current, aspectRatio: 2.0)

        #expect(rect == CGRect(x: 0, y: 50, width: 100, height: 50))
    }
    
    @Test func remainingHeightConstrainsGrowthUpwards() {
        let anchor = CGPoint(x: 100, y: 100)
        let current = CGPoint(x: 0, y: 0)

        let rect = resizeFromTopLeft(anchor: anchor, current: current, aspectRatio: 2.0)

        #expect(rect == CGRect(x: 0, y: 50, width: 100, height: 50))
    }
}
