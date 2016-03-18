//
//  Meme.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 5/23/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This is the Meme struct
//  - Composed by two Strings (topText, bottomText) and two UIImages (originalImage, memedImage)

import UIKit
import CoreData

private let ENTITY_NAME = "Meme"

class Meme : NSManagedObject {
	@NSManaged var topText: String
	@NSManaged var bottomText: String
	@NSManaged var originalImageIdentifier: String
	@NSManaged var memedImageIdentifier: String
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		let entity = NSEntityDescription.entityForName(ENTITY_NAME, inManagedObjectContext: context!)!
		super.init(entity: entity,insertIntoManagedObjectContext: context)
		
		self.topText = topText
		self.bottomText = bottomText
		self.originalImageIdentifier = self.generateImageIdentifier(false)
		self.memedImageIdentifier = self.generateImageIdentifier(true)
		self.originalImage = originalImage
		self.memedImage = memedImage
	}
	
	override func prepareForDeletion() {
		ImageCache.sharedInstance.deleteImage(originalImageIdentifier)
		ImageCache.sharedInstance.deleteImage(memedImageIdentifier)
	}
	
	var originalImage: UIImage? {
		get {
			return ImageCache.sharedInstance.imageWithIdentifier(originalImageIdentifier)
		}
		set {
			ImageCache.sharedInstance.storeImage(newValue, withIdentifier: originalImageIdentifier)
		}
	}
	
	var memedImage: UIImage? {
		get {
			return ImageCache.sharedInstance.imageWithIdentifier(memedImageIdentifier)
		}
		
		set {
			ImageCache.sharedInstance.storeImage(newValue, withIdentifier: memedImageIdentifier)
		}
	}
	
	func generateImageIdentifier(isMemedImage: Bool) -> String {
		var identifier = ""
		
		if isMemedImage {
			identifier.appendContentsOf("meme-")
		} else {
			identifier.appendContentsOf("original-")
		}
		
		let formatter = NSDateFormatter()
		formatter.dateFormat = "ddMMyyyy-HHmmss"
		let date = formatter.stringFromDate(NSDate())
		identifier.appendContentsOf(date)
		return identifier
	}
}

