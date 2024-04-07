//
//  GLVideoCompressionPreference.swift
//  Compression
//
//  Created by Gokul on 20/01/20.
//  Copyright © 2020 GLabs. All rights reserved.
//

import UIKit
import AVFoundation

public class GLVideoCompressionPreference: NSObject {
    public static var shared = GLVideoCompressionPreference()
    
    //MARK: For AVAssetReader & AVAssetWriter
    /// A key to access the average bit rate—as bits per second—used in compressing video.
    public var BITRATE:NSNumber = NSNumber(value:1024 * 750)
    /// - Max video resolution in **Width x Height**
    /// - Output file resolution will be less than or equal to this value
    /// - Default value will be 848x480 || 480x848 for portrait videos.
    public var MAX_VIDEO_RESOLUTION: CGSize {
        get {
            return MAX_VIDEO_RESOLUTION_LANDSCAPE
        }
        set {
            MAX_VIDEO_RESOLUTION_LANDSCAPE = CGSize(width: newValue.width, height: newValue.height)
            MAX_VIDEO_RESOLUTION_PORTRAIT = CGSize(width: newValue.height, height: newValue.width)
        }
        
    }
    internal var MAX_VIDEO_RESOLUTION_LANDSCAPE = CGSize(width: 848, height: 480)
    internal var MAX_VIDEO_RESOLUTION_PORTRAIT = CGSize(width: 480, height:848 )
    
    
    
    //MARK: For AVAssetExportSession
    /// The type of file written by the session, mov, mp4, m4v etc...
    public var FILE_TYPE: AVFileType = AVFileType.mov
    
    /// Set Low || Medium || High
    /// - AVAssetExportPresetLowQuality
    /// - AVAssetExportPresetMediumQuality
    /// - AVAssetExportPresetHighestQuality
    public var VIDEO_QUALITY = AVAssetExportPresetMediumQuality
    
    /// Setting *true* will print size before and after compression
    public var ENABLE_SIZE_LOG = true
}
