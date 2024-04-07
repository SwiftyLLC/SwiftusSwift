//
//  GLVideoCompressor.swift
//  Compression
//
//  Created by Gokul on 20/01/20.
//  Copyright © 2020 GLabs. All rights reserved.
//

import UIKit
import AVFoundation

public class GLVideoCompressor: NSObject {
    
    public static let shared = GLVideoCompressor()
    
    private var assetWriter:AVAssetWriter?
    private var assetReader:AVAssetReader?

    /// Can override the predefined preference by using this.
    public var preference = GLVideoCompressionPreference.shared
    
    public typealias compressionCompleted =  (_ output: URL, _ originalSize: String, _ compressedSize: String) -> Void
    
    /// Uses AVAssetReader & AVAssetWriter to rewrite the video with prefereed Video and audio settings
    ///
    /// - Parameters:
    ///   - urlToCompress: Input || Local URL of video to be compressed
    ///   - outputURL: Output URL of compressed video. This can be from temp folder, After processing the output it can be deleted.
    ///   - completion: Returns the same *outputURL* that has been given as input.
    public func compressFile(urlToCompress: URL, outputURL: URL, completion: @escaping compressionCompleted) {
        var originalSize = "0 MB"
        var compressedSize = "0 MB"
        //video file to make the asset
        if preference.ENABLE_SIZE_LOG {
            if let data = try? Data(contentsOf: urlToCompress){
                originalSize = data.verboseFileSizeInMB()
                print("#Video compression before \(originalSize)")
            }
        }
        var audioFinished = false
        var videoFinished = false
        
        let asset = AVAsset(url: urlToCompress);
        
        //create asset reader
        do{
            assetReader = try AVAssetReader(asset: asset)
        } catch{
            assetReader = nil
        }
        
        guard let reader = assetReader else{
            fatalError("Could not initalize asset reader probably failed its try catch")
        }
        
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
        var audioTrack:AVAssetTrack?
        var isAudioAvailable = false
        if let track = asset.tracks(withMediaType: AVMediaType.audio).first {
            audioTrack = track
            isAudioAvailable = true
        }
        
        let videoReaderSettings: [String:Any] =  [(kCVPixelBufferPixelFormatTypeKey as String?)!:kCVPixelFormatType_32ARGB ]
        
        // ADJUST BIT RATE OF VIDEO HERE
        let originalResolution = videoTrack.resolutionForLocalVideo()
        let isPortraitBySize = originalResolution.height > originalResolution.width
        let compressionSize = GLUtility.shared.getCompressionRatio(actualSize: CGSize(width: originalResolution.width, height: originalResolution.height), isVideo: true, isPortrait: isPortraitBySize)
        
        var isPortraitByTransform = true;
        
        let transforms = videoTrack.preferredTransform
        if (transforms.a == 0.0 && transforms.b == 1.0 && transforms.c == -1.0 && transforms.d == 0)
            || (transforms.a == 0.0 && transforms.b == -1.0 && transforms.c == 1.0 && transforms.d == 0) {
            isPortraitByTransform = false;
        }
        let videoSettings:[String:Any] = [
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey:preference.BITRATE],
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoHeightKey: (isPortraitBySize && !isPortraitByTransform) ? compressionSize.width : compressionSize.height,
            AVVideoWidthKey: (isPortraitBySize && !isPortraitByTransform) ? compressionSize.height : compressionSize.width
        ]
        
        let assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        var assetReaderAudioOutput:AVAssetReaderTrackOutput?
        if isAudioAvailable {
            assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack!, outputSettings: nil)
        }
        
        if reader.canAdd(assetReaderVideoOutput){
            reader.add(assetReaderVideoOutput)
        }else{
            fatalError("Couldn't add video output reader")
        }
        
        if isAudioAvailable {
            if reader.canAdd( assetReaderAudioOutput!){
                reader.add( assetReaderAudioOutput!)
            }else{
                fatalError("Couldn't add audio output reader")
            }
        }
        let audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
        let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        videoInput.transform = videoTrack.preferredTransform
        //we need to add samples to the video input
        
        let videoInputQueue = DispatchQueue(label: "videoQueue")
        let audioInputQueue = DispatchQueue(label: "audioQueue")
        
        do{
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mov)
        }catch{
            assetWriter = nil
        }
        guard let writer = assetWriter else{
            fatalError("assetWriter was nil")
        }
        
        writer.shouldOptimizeForNetworkUse = true
        writer.add(videoInput)
        if isAudioAvailable {
            writer.add(audioInput)
        }
        
        writer.startWriting()
        reader.startReading()
        writer.startSession(atSourceTime: CMTime.zero)
        
        let closeWriter:()->Void = {
            if (audioFinished && videoFinished) || !isAudioAvailable && videoFinished {
                self.assetWriter?.finishWriting(completionHandler: {
                    if let writter = self.assetWriter, self.preference.ENABLE_SIZE_LOG {
                        
                        if let data = try? Data(contentsOf: writter.outputURL){
                            compressedSize = data.verboseFileSizeInMB()
                            print("#Video compression after \(compressedSize)")
                        }
                        completion(writter.outputURL, originalSize, compressedSize)
                    }
                })
                
                self.assetReader?.cancelReading()
                
            }
        }
        // no need to compress audio of Video, without audio file.
        if isAudioAvailable {
            audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
                while(audioInput.isReadyForMoreMediaData){
                    let sample = assetReaderAudioOutput!.copyNextSampleBuffer()
                    if (sample != nil){
                        audioInput.append(sample!)
                    }else{
                        audioInput.markAsFinished()
                        DispatchQueue.main.async {
                            audioFinished = true
                            closeWriter()
                        }
                        break;
                    }
                }
            }
        }
        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
            while(videoInput.isReadyForMoreMediaData){
                let sample = assetReaderVideoOutput.copyNextSampleBuffer()
                if (sample != nil){
                    videoInput.append(sample!)
                }else{
                    videoInput.markAsFinished()
                    DispatchQueue.main.async {
                        videoFinished = true
                        closeWriter()
                    }
                    break;
                }
            }
        }
    }
    
    /// Uses AVAssetExportSession to compress video,
    /// If compression failed input url will be given as output, Check debuger consol for logs
    ///
    /// - Parameters:
    ///   - inputURL: Input || Local URL of video to be compressed
    ///   - outputURL: Output URL of compressed video. This can be from temp folder, After processing the output it can be deleted.
    ///   - handler: Returns the same **outputURL** that has been given as input.
    public func compressVideoUsingExportSession(inputURL: URL, outputURL: URL, handler:@escaping compressionCompleted) {
        
        var originalSize = "0 MB"
        var compressedSize = "0 MB"
        
        if preference.ENABLE_SIZE_LOG {
            if let data = try? Data(contentsOf: inputURL){
                originalSize = data.verboseFileSizeInMB()
                print("#Video compression before \(originalSize)")
            }
        }
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            if preference.ENABLE_SIZE_LOG { print("#Video compression failed") }
            handler(inputURL, originalSize, originalSize)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = preference.FILE_TYPE
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            if self.preference.ENABLE_SIZE_LOG {
                if let data = try? Data(contentsOf: outputURL){
                    compressedSize = data.verboseFileSizeInMB()
                    print("#Video compression after \(compressedSize)")
                }
            }
            handler(inputURL, originalSize, compressedSize)
        }
    }
    
}
