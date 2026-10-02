//
//  CanvasSettings.swift
//  composer
//
//  Created by David Marshall on 9/15/26.
//

import Foundation

enum GridType: Equatable {
    case fourByFour
    case eightByEight
    case customSquare(size: Double)
}

struct CanvasSettings {
    let width: Double
    let height: Double
    let gridType: GridType
}


func blockingErrors(for settings: CanvasSettings) -> [String] {
    var errors: [String] = []

    if settings.width <= 0 {
        errors.append("Width must be greater than zero.")
    }
    if settings.height <= 0 {
        errors.append("Height must be greater than zero.")
    }

    if case .customSquare(let size) = settings.gridType {
        if size <= 0 {
            errors.append("Square size must be greater than zero.")
        } else if size >= settings.width || size >= settings.height {
            errors.append("Square size must be smaller than both canvas dimensions.")
        }
    }

    return errors
}

func warnings(for settings: CanvasSettings) -> [String] {
    var warnings: [String] = []
    if case .customSquare(let size) = settings.gridType {
        if !evenlyDivides(size,into:settings.height) {
            warnings.append("Square size does not evenly divide the height")
        }
        if !evenlyDivides(size, into:settings.width) {
            warnings.append("Square size does not evenly divide the width")
        }
    }
    return warnings
}

func evenlyDivides(_ size: Double, into total: Double, tolerance: Double = 0.0001) -> Bool {
    let remainder = total.truncatingRemainder(dividingBy: size)
    return remainder < tolerance || (size - remainder) < tolerance
}
 
