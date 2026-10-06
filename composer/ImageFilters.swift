//
//  ImageFilters.swift
//  composer
//
//  Created by David Marshall on 10/2/26.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

func posterized(_ image: UIImage, levels: Double = 6) -> UIImage {
    guard let ciImage = CIImage(image: image) else { return image }
    let filter = CIFilter.colorPosterize()
    filter.inputImage = ciImage
    filter.levels = Float(levels)

    let context = CIContext()
    guard let output = filter.outputImage,
          let cgImage = context.createCGImage(output, from: output.extent) else {
        return image
    }
    return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
}

func desaturated(_ image: UIImage) -> UIImage {
    guard let ciImage = CIImage(image: image) else { return image }
    let filter = CIFilter.colorControls()
    filter.inputImage = ciImage
    filter.saturation = 0

    let context = CIContext()
    guard let output = filter.outputImage,
          let cgImage = context.createCGImage(output, from: output.extent) else {
        return image
    }
    return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
}


