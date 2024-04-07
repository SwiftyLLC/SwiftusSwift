//
//  GLImageCompressor.swift
//  Compression
//
//  Created by Gokul on 20/01/20.
//  Copyright © 2020 GLabs. All rights reserved.
//

import UIKit

public class GLImageCompressor: NSObject {
    public static var shared = GLImageCompressor()
    
    /// Can override the predefined preference by using this.
    public var preference = GLImageCompressionPreference.shared
    
    /// To compress image based on *GLImageCompressor.shared.preference* value.
    ///
    /// - Parameter image: Input image
    /// - Returns: Out put Image and Data
    public func compressImage(image: UIImage, size: CGSize? = nil, maxResolution: CGSize? = nil) -> (image: UIImage?,originSize: String, originByte: Int64?, compressedSize: String, compressedByte: Int64?) {
        var originalSize = "0 KB"
        var originalImageData:Data?
        var compressedSize = "0 KB"

//        if preference.ENABLE_SIZE_LOG {
//            originalImageData = image.jpegData(compressionQuality: 1)!
//            originalSize = originalImageData!.verboseFileSizeInKB()
//            print("#Image compression before: \(originalSize)")
//        }
        let compressionSize = size ?? GLUtility.shared.getCompressionRatio(actualSize: CGSize(width: image.size.width, height: image.size.height), isVideo: false, maxResolution: maxResolution)
        let rect = CGRect(x: 0.0, y: 0.0, width: compressionSize.width, height: compressionSize.height)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            return (nil, originalSize, Int64(originalImageData?.count ?? 0), originalSize, Int64(0.0))
        }
        UIGraphicsEndImageContext()
        guard let imageData = img.jpegData(compressionQuality: preference.compressionQuality)else {
            return (nil,originalSize, Int64(0.0), originalSize, Int64(0.0))
        }
//        if preference.ENABLE_SIZE_LOG {
            compressedSize = imageData.verboseFileSizeInKB()
            print("#Image compression after: \(compressedSize)")
//        }
        return (UIImage(data: imageData),originalSize, Int64(originalImageData?.count ?? 0), compressedSize, Int64(imageData.count ))
    }
}
