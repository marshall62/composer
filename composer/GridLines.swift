//
//  GridLines.swift
//  composer
//
//  Created by David Marshall on 9/30/26.
//

import CoreGraphics

struct LineSegment: Equatable {
    let start: CGPoint
    let end: CGPoint
}

func evenGridLines(for rect: CGRect, columns: Int, rows: Int) -> [LineSegment] {
    var lines: [LineSegment] = []

    for i in 1..<columns {
        let x = rect.minX + rect.width * CGFloat(i) / CGFloat(columns)
        lines.append(LineSegment(start: CGPoint(x: x, y: rect.minY), end: CGPoint(x: x, y: rect.maxY)))
    }

    for i in 1..<rows {
        let y = rect.minY + rect.height * CGFloat(i) / CGFloat(rows)
        lines.append(LineSegment(start: CGPoint(x: rect.minX, y: y), end: CGPoint(x: rect.maxX, y: y)))
    }

    return lines
}


func squareGridLines(for rect: CGRect, canvasWidth: Double, canvasHeight: Double, squareSize: Double) -> [LineSegment] {
    let columns = Int(canvasWidth / squareSize)
    let rows = Int(canvasHeight / squareSize)

    let pixelsPerUnit = rect.width / CGFloat(canvasWidth)
    let cellSize = CGFloat(squareSize) * pixelsPerUnit

    var lines: [LineSegment] = []

    for i in 1...columns {
        let x = rect.minX + CGFloat(i) * cellSize
        lines.append(LineSegment(start: CGPoint(x: x, y: rect.minY), end: CGPoint(x: x, y: rect.maxY)))
    }

    for i in 1...rows {
        let y = rect.minY + CGFloat(i) * cellSize
        lines.append(LineSegment(start: CGPoint(x: rect.minX, y: y), end: CGPoint(x: rect.maxX, y: y)))
    }

    return lines
}
