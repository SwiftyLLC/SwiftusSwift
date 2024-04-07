
import UIKit
import Photos

public class CustomPhotoAlbum: NSObject {
    static let albumName = "Video Photo Compress"
    static let sharedInstance = CustomPhotoAlbum()
    
    var assetCollection: PHAssetCollection?
    
    override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
                if status == PHAuthorizationStatus.authorized {
                    if let assetCollection = self.fetchAssetCollectionForAlbum() {
                        self.assetCollection = assetCollection
                    }else{
                        self.createAlbum()
                    }
                }
                
            })
        }
    }
    
    func createAlbum() {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)   // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                } else {
                    //                SBLog("error \(error)")
                }
            }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage) {
        if assetCollection == nil {
            return
        }
        
        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                guard let asset = self.assetCollection else {
                    return
                }
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: asset)
                let enumeration: NSArray = [assetPlaceHolder!]
                albumChangeRequest!.addAssets(enumeration)
            }
        } catch {
        }
    }
    func saveImage(image: UIImage,completionHandler: @escaping (Int?) ->()) {
        if assetCollection == nil {
            return
        }
        
        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                guard let asset = self.assetCollection else {
                    return
                }
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: asset)
                let enumeration: NSArray = [assetPlaceHolder!]
                albumChangeRequest!.addAssets(enumeration)
                completionHandler(200)
            }
        } catch {
            completionHandler(400)
        }
 
    }
    
    func save(videoFilePath: String) -> Bool {
        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                guard let asset = self.assetCollection else {
                    return
                }
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: videoFilePath))
                let assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: asset)
                let enumeration: NSArray = [assetPlaceHolder!]
                albumChangeRequest!.addAssets(enumeration)            }
            return true
        } catch {
            print("Error in saving photo")
            return false
        }
    }
}
