//
//  SelectionViewModel.swift
//  Travelogue
//
//  Created by Sayantan Chakraborty on 12/01/21.
//

import Foundation
import Photos
import UIKit

struct PhotosModel: Identifiable, Equatable {
    var id: String
    let image: UIImage
    let asset: PHAsset
    let isVideo: Bool
    let locations: [CLPlacemark]?
    let duration: Double?
    let creationDate: Date?
}
