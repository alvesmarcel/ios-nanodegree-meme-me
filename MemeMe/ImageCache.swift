//
//  ImageCache.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 3/18/16.
//  Copyright © 2016 Marcel Oliveira Alves. All rights reserved.
//

import UIKit

class ImageCache {
	
	static let sharedInstance = ImageCache()
	
	private var inMemoryCache = NSCache()
	
	// MARK: - Retreiving images
	
	func imageWithIdentifier(identifier: String?) -> UIImage? {
		
		// If the identifier is nil, or empty, return nil
		if identifier == nil || identifier! == "" {
			return nil
		}
		
		let path = pathForIdentifier(identifier!)
		
		// First try the memory cache
		if let image = inMemoryCache.objectForKey(path) as? UIImage {
			return image
		}
		
		// Next Try the hard drive
		if let data = NSData(contentsOfFile: path) {
			return UIImage(data: data)
		}
		
		return nil
	}
	
	// MARK: - Saving images
	
	func storeImage(image: UIImage?, withIdentifier identifier: String) {
		let path = pathForIdentifier(identifier)
		
		// If the image is nil, remove images from the cache
		if image == nil {
			inMemoryCache.removeObjectForKey(path)
			
			do {
				try NSFileManager.defaultManager().removeItemAtPath(path)
			} catch let error as NSError {
				print("Error removing item \(error.localizedDescription)")
			}
			
			return
		}
		
		// Otherwise, keep the image in memory
		inMemoryCache.setObject(image!, forKey: path)
		
		// And in documents directory
		let data = UIImagePNGRepresentation(image!)!
		data.writeToFile(path, atomically: true)
	}
	
	// MARK: Deleting images
	
	func deleteImage(imageIdentifier: String) {
		storeImage(nil, withIdentifier: imageIdentifier)
	}
	
	// MARK: - Helper
	
	func pathForIdentifier(identifier: String) -> String {
		let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
		let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
		
		return fullURL.path!
	}
}