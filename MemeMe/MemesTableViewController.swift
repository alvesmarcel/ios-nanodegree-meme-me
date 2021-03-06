//
//  MemesTableViewController.swift
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

class MemesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
	
	// MARK: Outlets
	
	@IBOutlet weak var tableView: UITableView!

	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		configureUI()
		
		// Fetching stories to populate the table
		do {
			try fetchedResultsController.performFetch()
		} catch let error as NSError {
			print("Error performing fetch \(error.localizedDescription)")
		}
		
		fetchedResultsController.delegate = self
	}
	
	// MARK: UITableViewDataSource methods
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = self.fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("memeTableViewCell")! as UITableViewCell
		configureCell(cell, atIndexPath: indexPath)
		return cell
	}
	
	// MARK: UITableViewDelegate methods
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
		
		// TODO: GET MEME AND PASS TO CONTROLLER
		
		self.navigationController!.pushViewController(controller, animated: true)
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if (editingStyle == .Delete) {
			let context = fetchedResultsController.managedObjectContext
			let object = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
			dispatch_async(dispatch_get_main_queue()) {
				context.deleteObject(object)
				CoreDataStackManager.sharedInstance.saveContext()
			}
		}
	}
	
	// MARK: IBActions
	
	// Enables editing (deleting) memes in the table
	@IBAction func editTable() {
		tableView.setEditing(!tableView.editing, animated: true)
	}

	
	// MARK: NSFetchedResultsController
	
	lazy var fetchedResultsController: NSFetchedResultsController = {
		let fetchRequest = NSFetchRequest(entityName: "Meme")
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "topText", ascending: true)]
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
			managedObjectContext: CoreDataStackManager.sharedInstance.managedObjectContext,
			sectionNameKeyPath: nil,
			cacheName: nil)
		
		return fetchedResultsController
	}()
	
	// MARK: NSFetchedResultsControllerDelegate methods
	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		self.tableView.beginUpdates()
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		self.tableView.endUpdates()
	}
	
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		switch type {
		case .Insert:
			tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
		case .Delete:
			tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
		case .Update:
			self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
		case .Move:
			tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
			tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
		}
	}
	
	// MARK: Helper methods
	
	func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
		// Sets name and image
		let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Meme
		cell.textLabel?.text = meme.topText + " " + meme.bottomText
		cell.imageView?.image = meme.memedImage
	}
	
	func configureUI() {
		self.title = "Memes List"
		let tabItems = self.tabBarController!.tabBar.items! as [UITabBarItem]
		let tabItem = tabItems[0] as UITabBarItem
		tabItem.title = ""
	}
}


