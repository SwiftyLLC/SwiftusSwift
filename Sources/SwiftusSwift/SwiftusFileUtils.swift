//
//  SwiftusFileUtils.swift
//
//
//  Created by SwiftusSwift on 07/04/2024.
//

import Foundation
import UIKit
import Combine
import Photos

public class SwiftusFileUtils: NSObject {
    
    public class func documentURL() -> URL? {
        let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return  directoryURLs.first
    }
    
    public class func tempURL() -> URL {
        return  FileManager.default.temporaryDirectory
    }
    
    /// Load data from local file name, use JSONDecoder covert to model T
    public class func loadModelFrom<T: Decodable>(_ filename: String) -> T {
        let data: Data

        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }

        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }

    
    
    /// Current not support Mode and Progress
    public class func downloadFileFrom(url: String, toFolder: SaveFolderType, progress: ((Progress) -> Void)? = nil) -> AnyPublisher<URL?, Error> {
        print("downloadFileFrom ---> \(url)")
        return Future { promise in
            guard let url = URL(string: url) else {
                promise(.failure(SwiftusErrors.urlNotAvailable))
                return
            }

            let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
                if error != nil {
                    promise(.failure(error!))
                } else {
                    promise(.success(url))
                }
            }
            task.resume()
        }.eraseToAnyPublisher()
    }
    
    public class func copyFileToTempFrom(url: URL, name: String? = nil) -> AnyPublisher<URL, Error> {
        return Future { promise in
            var tempURL = self.tempURL().appendingPathComponent(url.lastPathComponent)
            if let __name = name {
                //Rename file
                tempURL = self.tempURL().appendingPathComponent(__name)
            }
            do {
                try? FileManager.default.removeItem(at: tempURL)
                try FileManager.default.copyItem(at: url, to: tempURL)
                debugPrint("Copy item to ---> \(tempURL.absoluteString)")
                promise(.success(tempURL))
            } catch {
                debugPrint("Error ---->")
                debugPrint(error)
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    
    /// Save image to Temp / Document folder with format and max Size
    public class func saveImage(image: UIImage, toFolder: SaveFolderType, withFomat: SwiftusImageFormat,  maxResolution: CGSize? = nil) -> AnyPublisher<URL, Error> {
        return Future { promise in
            let fileName = withFomat == .PNG ? "\(UUID().uuidString).png" : "\(UUID().uuidString).jpg"
            var tempURL = self.tempURL().appendingPathComponent(fileName)
            
            if toFolder == .Document {
                guard let url = self.documentURL() else {
                    promise(.failure(SwiftusErrors.urlNotAvailable))
                    return
                }
                tempURL = url.appendingPathComponent(fileName)
            }
            //Debug help:
            //let tempURL = self.documentURL()!.appendingPathComponent("\(UUID().uuidString).jpg")
            do {
                
                //1, Resize image
                let result = GLImageCompressor().compressImage(image: image, maxResolution: maxResolution)
                
                if let data = (withFomat == .PNG
                    ? ((result.image ?? image).pngData())
                    : ((result.image ?? image).jpegData(compressionQuality: 1.0))
                ) {
                    try data.write(to: tempURL)
                    #if DEBUG
                        print("----> savedImage size")
                        print("\(Int64(data.count).verboseFileSizeInKB())")
                        print(result.image?.size ?? .zero)
                    #endif
                }
                debugPrint("Write image to ---> \(tempURL.absoluteString)")
                promise(.success(tempURL))
            } catch {
                debugPrint("Error ---->")
                debugPrint(error)
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    /*
    class func saveImageToTemp(image: UIImage, maxResolution: CGSize? = nil) -> AnyPublisher<URL, Error> {
        return Future { promise in
            let tempURL = self.tempURL().appendingPathComponent("\(UUID().uuidString).jpg")
            //Debug help:
            //let tempURL = self.documentURL()!.appendingPathComponent("\(UUID().uuidString).jpg")
            do {
                
                //1, Resize image
                let result = GLImageCompressor().compressImage(image: image, maxResolution: maxResolution)
                
                if let data = (result.image ?? image).jpegData(compressionQuality: 1.0) {
                    try data.write(to: tempURL)
                    #if DEBUG
                        print("saveImageToTemp image.jpegData size")
                        print("\(Int64(data.count).verboseFileSizeInKB())")
                        print(result.image?.size ?? .zero)
                    #endif
                }
                debugPrint("Write image to ---> \(tempURL.absoluteString)")
                promise(.success(tempURL))
            } catch {
                debugPrint("Error ---->")
                debugPrint(error)
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    class func saveImagePngToTemp(image: UIImage, maxResolution: CGSize? = nil) -> AnyPublisher<URL, Error> {
        return Future { promise in
            let tempURL = self.tempURL().appendingPathComponent("\(UUID().uuidString).png")
            do {
                //1, Resize image
                var resultImage: UIImage? = image
                if maxResolution != nil {
                    let result = GLImageCompressor().compressImage(image: image, maxResolution: maxResolution)
                    resultImage = result.image
                }
                
                if let data = resultImage?.pngData() {
                    try data.write(to: tempURL)
                }
                debugPrint("Write image to ---> \(tempURL.absoluteString)")
                promise(.success(tempURL))
            } catch {
                debugPrint("Error ---->")
                debugPrint(error)
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    class func savePngImageToDocument(image: UIImage, maxResolution: CGSize? = nil) -> AnyPublisher<URL, Error> {
        return Future { promise in
            let tempURL = self.documentURL()!.appendingPathComponent("\(UUID().uuidString).png")
            //Debug help:
            //let tempURL = self.documentURL()!.appendingPathComponent("\(UUID().uuidString).jpg")
            do {
                
                //1, Resize image
                var resultImage: UIImage? = image
                if maxResolution != nil {
                    let result = GLImageCompressor().compressImage(image: image, maxResolution: maxResolution)
                    resultImage = result.image
                }
                
                if let data = resultImage?.pngData() {
                    try data.write(to: tempURL)
                }
                debugPrint("Write image to ---> \(tempURL.absoluteString)")
                promise(.success(tempURL))
            } catch {
                debugPrint("Error ---->")
                debugPrint(error)
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
     */
    
    public class func findQualityUnder2Mb(image: UIImage) -> CGFloat {
        let bytes : Int64 = Int64((image.jpegData(compressionQuality: 1.0))?.count ?? 0)
        print(bytes.verboseFileSizeInMB())
        print(bytes.verboseFileSizeInKB())
        if bytes < 1000000 { // 2MB
            return 1.0
        }
        
        return 1000000.0 / CGFloat(bytes)
    }
    
    public class func saveToLibrary(fileURL: URL, complete: (( _ success: Bool, _ error: Error?) -> Void)? = nil ){
        //self.dialogState = .none
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = true
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .video, fileURL: fileURL, options: options)
                }) { (success, error) in
                    if let action = complete {
                        DispatchQueue.main.async {
                            action(success, error)
                        }
                    }
                    //                    do {
                    //                        try  FileManager.default.removeItem(at: fileURL)
                    //                    } catch {
                    //
                    //                    }
                }
            default:
                print("PhotoLibrary not authorized")
                if let action = complete {
                    DispatchQueue.main.async {
                        action(false, nil)
                    }
                }
                break
            }
        }
    }

}

public extension Int64 {
    func verboseFileSizeInMB() -> String{
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        let fileSize = bcf.string(fromByteCount: self)
        return fileSize
    }
    
    func verboseFileSizeInKB() -> String{
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        let fileSize = bcf.string(fromByteCount: self)
        return fileSize
    }

}
