//
//  SelectionViewModel.swift
//  Travelogue
//
//  Created by Sayantan Chakraborty on 12/01/21.
//

import Foundation
import Photos
import UIKit

class SelectionViewModel: ObservableObject {
    @Published private(set) var assets = [PhotosModel]()
    @Published private(set) var currentImageModel : PhotosModel?
    @Published private(set) var selectedImageModels = [PhotosModel]()
    private(set) var selectedImage = UIImage(named: "Darjeeling")!
    private(set) var selectedAVPlayer : AVPlayer?
    private var imageModel = [PhotosModel]()
    
    init() {}
    
    // MARK: - Intents
    func fetchAllPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeAssetSourceTypes = .typeUserLibrary
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d || (mediaType = %d && duration < %f)", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue, 30)
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        let allPhotos = PHAsset.fetchAssets(with: fetchOptions)
        allPhotos.enumerateObjects { (asset, count, stop) in
            print(asset.mediaType.rawValue)
            if asset.mediaType ==  .image {
                self.addUIImage(asset: asset) { model in
                    self.imageModel.append(model)
                    if self.imageModel.count == allPhotos.count {
                        DispatchQueue.main.async {
                            let sortedModels = self.imageModel.sorted{ $0.creationDate! > $1.creationDate!}
                            self.assets = sortedModels
                        }
                    }
                    print("Total:\(allPhotos.count) Processed:\(self.imageModel.count)")
                }
            } else if asset.mediaType == .video {
                self.addVideo(asset: asset){ model in
                    self.imageModel.append(model)
                    if self.imageModel.count == allPhotos.count {
                        DispatchQueue.main.async {
                            let sortedModels = self.imageModel.sorted{ $0.creationDate! > $1.creationDate!}
                            self.assets = sortedModels
                        }
                    }
                    print("Total:\(allPhotos.count) Processed:\(self.imageModel.count)")
                }
                
            }
        }
    }
    
    func addUIImage(asset: PHAsset, completion: @escaping (_ model: PhotosModel) -> Void) {
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        // this one is key
        requestOptions.isSynchronous = true
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions) { (image, meta) in
            if let img = image {
                if let location = asset.location {
                    CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                        completion(PhotosModel(id: asset.localIdentifier, image: img, asset: asset, isVideo: false, locations: placemarks, duration: nil, creationDate: asset.creationDate))
                    }
                } else {
                    completion(PhotosModel(id: asset.localIdentifier, image: img, asset: asset, isVideo: false, locations: nil, duration: nil, creationDate: asset.creationDate))
                }
            }
            
        }
    }
    
    func addVideo(asset: PHAsset, completion: @escaping (_ model: PhotosModel) -> Void) {
        PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (avasset, mix, dict) in
            let duration = avasset?.duration.seconds
            if let avast = avasset, let img = self.createThumbnailOfVideoFromFileURL(asset: avast) {
                if let location = asset.location {
                    CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                        completion(PhotosModel(id: asset.localIdentifier, image: img, asset: asset, isVideo: false, locations: placemarks, duration: nil, creationDate: asset.creationDate))
                    }
                } else {
                    completion(PhotosModel(id: asset.localIdentifier, image: img, asset: asset, isVideo: true, locations: nil, duration: duration, creationDate: asset.creationDate))

                }
            }
        }
    }
    
    func createThumbnailOfVideoFromFileURL(asset: AVAsset) -> UIImage? {
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            return nil
        }
    }
    
    func getAssets() -> [PhotosModel] {
        assets
    }
    
    func getSelectedVideo() -> AVPlayer? {
        selectedAVPlayer
    }
    
    func getSelectedImage() -> UIImage {
        selectedImage
    }
    
    func getImageFromAsset(phAsset: PHAsset, model: PhotosModel) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        // this one is key
        requestOptions.isSynchronous = false
        PHImageManager.default().requestImage(for: phAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { (image, meta) in
            if let img = image {
                self.selectedImage = img
                self.currentImageModel = model
            }
            
        }
    }
    
    func getVideoFromAsset(asset: PHAsset, model: PhotosModel) {
        PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (avasset, mix, dict) in
            if let aAsset = avasset {
                DispatchQueue.main.async {
                    self.selectedAVPlayer = AVPlayer(playerItem: AVPlayerItem(asset: aAsset))
                    self.currentImageModel = model

                }
            }
        }
    }
    
    // Add into selected image models
    func addSelectedModel(model: PhotosModel) {
        selectedImageModels.append(model)
    }
    
    // Remove image model from selected models
    func removeModel(mod: PhotosModel) {
        if let idx = selectedImageModels.firstIndex(where: { $0.id == mod.id }) {
            selectedImageModels.remove(at: idx)
        }
    }
    
    func removeAllModels() {
        selectedImageModels.removeAll()
    }
}

extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.zeroFormattingBehavior = .pad
    formatter.allowedUnits = [ .minute, .second]
    formatter.unitsStyle = style
    guard let formattedString = formatter.string(from: self) else { return "" }
    return formattedString
  }
}
