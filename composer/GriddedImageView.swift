//
//  GriddedImageView.swift
//  composer
//
//  Created by David Marshall on 10/2/26.
//
import SwiftUI

struct GriddedImageView: View {
    let uiImage: UIImage
    let canvasWidth: Double
    let canvasHeight: Double
    let gridType: GridType
    let gridColor: Color
    let showGrid: Bool

    var body: some View {
        GeometryReader { geo in
            let containerSize = geo.size
            let imageSize = uiImage.size
            let scale = min(containerSize.width / imageSize.width, containerSize.height / imageSize.height)
            let displaySize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
            let offset = CGPoint(
                x: (containerSize.width - displaySize.width) / 2,
                y: (containerSize.height - displaySize.height) / 2
            )
            let displayRect = CGRect(origin: .zero, size: displaySize)

            let lines: [LineSegment] = {
                switch gridType {
                case .fourByFour:
                    return evenGridLines(for: displayRect, columns: 4, rows: 4)
                case .eightByEight:
                    return evenGridLines(for: displayRect, columns: 8, rows: 8)
                case .customSquare(let size):
                    return squareGridLines(for: displayRect, canvasWidth: canvasWidth, canvasHeight: canvasHeight, squareSize: size)
                }
            }()

            ZStack(alignment: .topLeading) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: displaySize.width, height: displaySize.height)
                    .position(x: offset.x + displaySize.width / 2, y: offset.y + displaySize.height / 2)

                if showGrid {
                    Canvas { context, _ in
                        for line in lines {
                            var path = Path()
                            path.move(to: line.start)
                            path.addLine(to: line.end)
                            context.stroke(path, with: .color(gridColor), lineWidth: 2)
                        }
                    }
                    .frame(width: displaySize.width, height: displaySize.height)
                    .position(x: offset.x + displaySize.width / 2, y: offset.y + displaySize.height / 2)
                }
            }
        }
    }
}
