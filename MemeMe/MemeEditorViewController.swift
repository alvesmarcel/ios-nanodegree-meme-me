//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 5/23/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This ViewController is responsible for the meme edition. This class:
//  - Chooses a picture from camera or from the photo album
//  -- If the editor is called from the MemeDetail, the picture will already be chosen (it will be the one in the MemeDetailView)
//  - Changes the topText (initially set as "TOP") and the bottomText (initially set as "BOTTOM")
//  -- If the editor is called from the MemeDetail, the texts will already be chosen (it will be the ones in the MemeDetailView)
//  - Shares the created meme using the share button (top left)
//
//  After the meme is shared, it will be stored in the memes array of AppDelegate and the view is dismissed

import UIKit
import CoreData

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
	
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance.managedObjectContext
	}
	
	// MARK: Outlets
	
	@IBOutlet weak var imagePickerView: UIImageView!
	@IBOutlet weak var cameraButton: UIBarButtonItem!
	@IBOutlet weak var topTextView: UITextView!
	@IBOutlet weak var bottomTextView: UITextView!
	@IBOutlet weak var shareButton: UIBarButtonItem!

	// MARK: Class variables
	
	// If MemeEditorVC is called from MemeDetailVC, this meme is initialized; otherwise, it will be nil
	// It is used to edit an already existing meme
	var meme: Meme?
	
	// Controls variables used to indicate if the textField should be cleaned or not when edit starts
	var topTextViewEdited: Bool!
	var bottomTextViewEdited: Bool!
	
	// MARK: View appearing configurations
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Sets delegates
		topTextView.delegate = self
		bottomTextView.delegate = self
		
		// Sets attributes of text fields
		setTextAttributes(topTextView)
		setTextAttributes(bottomTextView)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		configureUI()
		
		topTextViewEdited = false
		bottomTextViewEdited = false
	}
	
	// MARK: UITextViewDelegate methods
	
	func textViewShouldBeginEditing(textView: UITextView) -> Bool {
		if textView == topTextView && !topTextViewEdited {
			textView.text = ""
			topTextViewEdited = true
		} else {
			subscribeToKeyboardNotifications()
			if !bottomTextViewEdited {
				textView.text = ""
				bottomTextViewEdited = true
			}
		}
		return true
	}
	
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		unsubscribeFromKeyboardNotifications()
		return true
	}
	
	
	
	// MARK: UIImagePickerControllerDelegate methods
	
	// Sets the imagePickerView image, enables the shareButton and dismiss the view after media was picked
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
			imagePickerView.image = image
			shareButton.enabled = true
		}
		dismissViewControllerAnimated(true, completion: nil)
	}

	// Dismiss the view if the user cancel the image picking
	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	// MARK: IBActions
	
	// Selects and present view controller to pick an image
	// (the tag identifies if the event comes from the camera button or from the album button)
	@IBAction func pickAnImage(sender: AnyObject) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		
		// Identifies the source
		if (sender.tag == 1) {
			imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
		} else if (sender.tag == 2) {
			imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		}
		
		presentViewController(imagePicker, animated: true, completion: nil)
	}
	
	// Presents an activity view to share the created meme
	@IBAction func shareMeme(sender: AnyObject) {
		let memedImage = self.generateMemedImage()
		
		dispatch_async(dispatch_get_main_queue()) {
			let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
			self.presentViewController(activityVC, animated: false, completion: nil)
			activityVC.completionWithItemsHandler = {
				(activity, success, items, error) in
				if (success) {
					self.save() // The meme is saved only if the activity view operation was succesful
					self.dismissViewControllerAnimated(true, completion: nil)
				}
			}
		}
	}
	
	// Dismiss the view if the user cancel the edition
	@IBAction func cancelEdition(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	// MARK: Helper methods
	
	// Stores the meme in the AppDelegate's memes array
	func save() {
		dispatch_async(dispatch_get_main_queue()) {
			let _ = Meme(topText: self.topTextView.text!, bottomText: self.bottomTextView.text!, originalImage: self.imagePickerView.image!, memedImage: self.generateMemedImage(), insertIntoManagedObjectContext: self.sharedContext)
			CoreDataStackManager.sharedInstance.saveContext()
		}
	}
	
	// Generates an image (memedImage) that is the original image with the text fields on top of it
	func generateMemedImage() -> UIImage {
		// Hide top and bottom toolbars
		//topToolbar.hidden = true
		//bottomToolbar.hidden = true
		
		// Get the image from screen
		UIGraphicsBeginImageContext(self.view.frame.size)
		self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
		let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		// Show top and bottom toolbars
		//topToolbar.hidden = false
		//bottomToolbar.hidden = false
		
		return memedImage
	}
	
	// Sets attributes of a UITextField and align the text
	func setTextAttributes(textView: UITextView) {
		
		// Dictionary of meme text attributes
		let memeTextAttributes = [
			NSStrokeColorAttributeName : UIColor.blackColor(),
			NSForegroundColorAttributeName : UIColor.whiteColor(),
			NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
			NSStrokeWidthAttributeName : -4.0,
		]
		
		// Initial text
		textView.attributedText = NSAttributedString(string: textView == topTextView ? "TOP" : "BOTTOM", attributes: memeTextAttributes)
		
		textView.typingAttributes = memeTextAttributes
		textView.textAlignment = .Center
	}
	
	// Moves the screen up
	func keyboardWillShow(notification: NSNotification) {
		view.frame.origin.y -= getKeyboardHeight(notification)
	}
	
	// Moves the screen down
	func keyboardWillHide(notification: NSNotification) {
		view.frame.origin.y = 0
	}
	
	// Adds observers to notification center (listens to UIKeyboardWillShowNotification and UIKeyboardWillHideNotification)
	func subscribeToKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
	}
	
	// Removes observers from notification center (listens to UIKeyboardWillShowNotification and UIKeyboardWillHideNotification)
	func unsubscribeFromKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().removeObserver(self, name:
			UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}
	
	// Find out the keyboard height
	func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.CGRectValue().height
	}
	
	func configureUI() {
		
		// Disables cameraButton if the camera is not avaible
		cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
		
		// imagePickerView initial configuration
		imagePickerView.contentMode = UIViewContentMode.ScaleAspectFit
		imagePickerView.backgroundColor = UIColor.blackColor()
		
		// Checks if meme is nil (MemeEditorVC was called from a Sent Memes VC) or not (MemeEditorVC was called from MemeDetailVC)
//		if (meme == nil) {
//			topTextField.text = "TOP"
//			topTextFieldEdited = false
//			
//			bottomTextField.text = "BOTTOM"
//			bottomTextFieldEdited = false
//		} else {
//			topTextField.text = meme!.topText
//			topTextFieldEdited = true
//			
//			bottomTextField.text = meme!.bottomText
//			bottomTextFieldEdited = true
//			
//			imagePickerView.image = meme!.originalImage
//		}
//		
//		// If there's no image selected, shareButton is disabled and the text fields are hidden
//		if (imagePickerView.image == nil) {
//			topTextField.hidden = true
//			bottomTextField.hidden = true
//			shareButton.enabled = false
//		} else {
//			topTextField.hidden = false
//			bottomTextField.hidden = false
//			shareButton.enabled = true
//		}
	}
}

