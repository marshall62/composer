//
//  CroppedImage.swift
//  composer
//
//  Created by David Marshall on 9/30/26.
//

import UIKit

extension UIImage {
    func normalizedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

func croppedImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
    let normalized = image.normalizedOrientation()
    guard let cgImage = normalized.cgImage?.cropping(to: rect) else { return nil }
    return UIImage(cgImage: cgImage, scale: normalized.scale, orientation: .up)
}
