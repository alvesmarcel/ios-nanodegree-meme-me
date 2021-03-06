//
//  MemesCollectionViewController.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 5/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This View Controller is responsible for the collection exibition of the sent (shared) memes. This class:
//  - Displays the memes in a collection
//  - Performs a push transition to MemeDetailViewController if an item is selected
//  - Deletes the meme from the collection and from the model

import UIKit
import CoreData

class MemesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
	
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance.managedObjectContext
	}
	
	// MARK: Outlets
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	// MARK: Class variables
	
	var memes: [Meme]! // memes that will be shown in the collection
	var collectionViewIsEditing: Bool! // indicates if the view is in "editing mode" (collectionViewIsEditing == true)
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Sent Memes"
		
		// Remove title from tabBar item
		let tabItems = self.tabBarController!.tabBar.items! as [UITabBarItem]
		let tabItem = tabItems[1] as UITabBarItem
		tabItem.title = ""
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// Load the memes from the AppDelegate
		let object = UIApplication.sharedApplication().delegate
		let appDelegate = object as! AppDelegate
		memes = appDelegate.memes
		
		// collectionView configuration and reloading - needed to update the items
		collectionView.backgroundColor = UIColor.whiteColor()
		collectionViewIsEditing = false // editing mode is always disabled when the view appears
		collectionView.reloadData()
	}
	
	// MARK: UICollectionViewDataSource methods
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let sectionInfo = self.fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
		let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Meme
		
		// Set name and image
		cell.hidden = false
		cell.memedImage.image = meme.memedImage
		cell.deleteLabel.hidden = !collectionViewIsEditing
		
		return cell
	}
	
	// MARK: UICollectionViewDelegate methods
	
	// Performs different actions depending on the collectionViewIsEditing
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		// If it is in editing mode, this method should delete the meme; otherwise, it should push the MemeDetailVC
		if (collectionViewIsEditing == true) {
			deleteMeme(indexPath.item)
		} else {
			let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
			detailController.meme = memes[indexPath.item]
			detailController.memeIndex = indexPath.item
			self.navigationController!.pushViewController(detailController, animated: true)
		}
	}
	
	// MARK: IBActions
	
	// Enables editing mode when the Edit button is tapped
	@IBAction func enableEdit(sender: AnyObject) {
		collectionViewIsEditing = !collectionViewIsEditing
		collectionView.reloadData()
	}
	
	// MARK: Auxiliary methods
	
	// Performs the deletion of a meme from the collection view and from the model (AppDelegate's memes array)
	func deleteMeme(index: Int) {
		let object = UIApplication.sharedApplication().delegate
		let appDelegate = object as! AppDelegate
		appDelegate.memes.removeAtIndex(index)
		
		// Resolving view problem (it seems that UICollectionView doesn't handle this automatically)
		memes.removeAtIndex(index)
		collectionView.reloadData()
	}
	
	// MARK: NSFetchedResultsController
	
	lazy var fetchedResultsController: NSFetchedResultsController = {
		
		let fetchRequest = NSFetchRequest(entityName: "Meme")
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "topText", ascending: true)]
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
			managedObjectContext: self.sharedContext,
			sectionNameKeyPath: nil,
			cacheName: nil)
		
		return fetchedResultsController
	}()
	
}
