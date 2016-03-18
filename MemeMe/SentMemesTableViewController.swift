//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 5/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This ViewController is responsible for the table exibition of the sent (shared) memes. This class:
//  - Displays the memes in a table
//  - Performs a push transition to MemeDetailVC if a row is selected
//  - Deletes the meme from the table and from the model (AppDelegate's memes array)

import UIKit
import CoreData

class SentMemesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
	
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance.managedObjectContext
	}
	
	// MARK: Outlets
	
	@IBOutlet weak var tableView: UITableView!
	
	// MARK: Class variables
	
	var memes: [Meme]! // memes that will be shown in the table
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Sent Memes"
		
		// Removes title from tabBar item
		let tabItems = self.tabBarController!.tabBar.items! as [UITabBarItem]
		let tabItem = tabItems[0] as UITabBarItem
		tabItem.title = ""
		
		
		// Fetching stories to populate the table
		do {
			try fetchedResultsController.performFetch()
		} catch {}
		
		fetchedResultsController.delegate = self
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// Load the memes from the AppDelegate
		let object = UIApplication.sharedApplication().delegate
		let appDelegate = object as! AppDelegate
		memes = appDelegate.memes
		
		// tableView configuration and reloading - needed to update the items
		tableView.editing = false
		tableView.reloadData()
	}
	
	// MARK: UITableViewDataSource methods
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = self.fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("tableCell")! as UITableViewCell
		let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Meme
		
		// Sets name and image
		cell.textLabel?.text = meme.topText + " " + meme.bottomText
		cell.imageView?.image = meme.memedImage
		
		return cell
	}
	
	// Verify editing style to make possible deleting rows (and their respective memes)
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete {
			memes.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
			deleteMeme(indexPath.row)
		}
	}
	
	// MARK: UITableViewDelegate methods
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
		detailController.meme = memes[indexPath.row]
		detailController.memeIndex = indexPath.row
		self.navigationController!.pushViewController(detailController, animated: true)
	}
	
	// MARK: IBActions
	
	// Enables editing (deleting) memes in the table
	@IBAction func enableEdit(sender: AnyObject) {
		tableView.editing = !tableView.editing
	}
	
	// MARK: Helper methods
	
	// Deletes a specific meme from the AppDelegate's memes array
	func deleteMeme(index: Int) {
		let object = UIApplication.sharedApplication().delegate
		let appDelegate = object as! AppDelegate
		appDelegate.memes.removeAtIndex(index)
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
	
	// MARK: NSFetchedResultsControllerDelegate methods
	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		tableView.beginUpdates()
	}
}


