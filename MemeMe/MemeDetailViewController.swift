//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 5/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This View Controller is responsible for the exibition of the details of a meme. This class:
//  - Displays a meme chosen in the SentMemesTableVC or SentMemesCollectionVC
//  - Calls MemeEditorViewController passing the meme in detail to make edition possible
//  - Deletes the meme from the model

import UIKit

class MemeDetailViewController: UIViewController {
	
	// MARK: Outlets
	
	@IBOutlet weak var imageView: UIImageView!
	
	// MARK: Class variables
	
	var meme: Meme!
	var memeIndex: Int! // meme index reference in the AppDelegate's memes array to make deletion possible
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Meme Detail"
		
		imageView.contentMode = UIViewContentMode.ScaleAspectFit
		
		// Programmatically inclusion of the Edit button (on the top right)
		let rightButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editMeme")
		self.navigationItem.rightBarButtonItem = rightButton
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		imageView.image = meme.memedImage
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.navigationController?.popToRootViewControllerAnimated(true)
	}
	
	// MARK: IBActions
	
	// Deletes the meme from the model (AppDelegate's memes array) and pop the view to the root
	@IBAction func deleteMeme(sender: AnyObject) {
		let object = UIApplication.sharedApplication().delegate
		let appDelegate = object as! AppDelegate
		appDelegate.memes.removeAtIndex(memeIndex)
		self.navigationController?.popToRootViewControllerAnimated(true)
	}
	
	// Calls MemeEditorVC if Edit button is tapped
	func editMeme() {
		let editController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
		editController.meme = meme
		self.presentViewController(editController, animated: true, completion: nil)
	}
}
