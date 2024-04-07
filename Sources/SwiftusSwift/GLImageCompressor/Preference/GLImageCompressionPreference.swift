//
//  GLImageCompressionPreference.swift
//  Compression
//
//  Created by Gokul on 20/01/20.
//  Copyright © 2020 GLabs. All rights reserved.
//

import UIKit

public class GLImageCompressionPreference: NSObject {
    static var shared = GLImageCompressionPreference()
    
    /// - Max Image resolution in **Width x Height**
    /// - Output file resolution will be less than or equal to this value
    /// - Default value will be 640x1136.0
    public var MAX_IMAGE_RESOLUTION = CGSize(width: 1920.0, height: 1920.0)
    /// Compression quality from 0.1 to 1, Default value is 0.5
    ///  - Images less than MAX_IMAGE_RESOLUTION will not be compressed. *compressionQuality will be 1.0 for such images*.
    public var compressionQuality:CGFloat = 0.5
    
    internal let QUALITY_HIGH_COMPRESSION:CGFloat = 1.0
    
    /// Setting *true* will print size before and after compression 
    public var ENABLE_SIZE_LOG = true
}
