//
//  StarEvent+CoreDataClass.swift
//  StarEvents
//
//  Created by Liam Butler-Lawrence on 11/15/16.
//  Copyright © 2016 Liam Butler-Lawrence. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class StarEvent: NSManagedObject {
    
    static private let imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 10
        return cache
    }()
    
    private var imageCacheID: NSString { return String(describing: id) as NSString }
    
    var image: UIImage? {
        get {
            if let cachedImage = StarEvent.imageCache.object(forKey: imageCacheID) {
                return cachedImage
            }
            
            guard
                let imageData = try? Data(contentsOf: imageURL),
                let image = UIImage(data: imageData)
                else { return nil }
            
            StarEvent.imageCache.setObject(image, forKey: imageCacheID)
            return image
        } set {
            guard
                let newImage = newValue,
                let imageData = UIImagePNGRepresentation(newImage)
                else { try? FileManager.default.removeItem(at: imageURL); return }
            
            do {
                try imageData.write(to: imageURL)
                imageLastUpdated = Date()
                StarEvent.imageCache.setObject(newImage, forKey: imageCacheID)
            } catch {
                print("Image for event with ID \(id) could not be saved")
            }
        }
    }
    
    private var imageURL: URL {
        guard let documentsDirectoryURL = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else { fatalError("Could not create URL for documents directory") }
        
        let imageName = "event_image_\(id)"
        let imageExtension = "png"
        let imageFileURL = documentsDirectoryURL
            .appendingPathComponent(imageName)
            .appendingPathExtension(imageExtension)
        
        return imageFileURL
    }
}
