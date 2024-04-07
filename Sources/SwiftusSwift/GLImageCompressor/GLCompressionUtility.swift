//
//  GLCompressionUtility.swift
//  Compression
//
//  Created by Gokul on 20/01/20.
//  Copyright © 2020 GLabs. All rights reserved.
//

import UIKit
import AVFoundation

public class GLUtility: NSObject {
    static var shared = GLUtility()
    public var videoPreference = GLVideoCompressionPreference.shared
    public var imagePreference = GLImageCompressionPreference.shared
    
    func getCompressionRatio(actualSize: CGSize, isVideo: Bool, isPortrait:Bool = false, maxResolution: CGSize? = nil) -> CGSize{
        var maxResolution =  maxResolution ?? imagePreference.MAX_IMAGE_RESOLUTION
        if isVideo {
            maxResolution = isPortrait ? videoPreference.MAX_VIDEO_RESOLUTION_PORTRAIT : videoPreference.MAX_VIDEO_RESOLUTION_LANDSCAPE
        }
        var actualHeight: CGFloat = actualSize.height
        var actualWidth: CGFloat = actualSize.width
        let maxHeight =  maxResolution.height
        let maxWidth = maxResolution.width
        var imgRatio: CGFloat = actualWidth/actualHeight
        let maxRatio: CGFloat = maxWidth/maxHeight
        if isVideo && actualHeight == actualWidth {
            // Square videos
            return CGSize(width: actualWidth, height: actualHeight)
        }else if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth      
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
                // No compression for image with preferred height and width.
                imagePreference.compressionQuality = imagePreference.QUALITY_HIGH_COMPRESSION
            }
        }
        return CGSize(width: actualWidth, height: actualHeight)
    }
}

extension AVAssetTrack {
    internal func resolutionForLocalVideo() -> CGSize {
        let size = self.naturalSize.applying(self.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}

extension Data {
    func verboseFileSizeInMB() -> String{
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        let fileSize = bcf.string(fromByteCount: Int64(self.count))
        return fileSize
    }
    
    func verboseFileSizeInKB() -> String{
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        let fileSize = bcf.string(fromByteCount: Int64(self.count))
        return fileSize
    }
}
