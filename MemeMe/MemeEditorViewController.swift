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

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate {
	
	// MARK: Outlets
	
	@IBOutlet weak var imagePickerView: UIImageView!
	@IBOutlet weak var cameraButton: UIBarButtonItem!
	@IBOutlet weak var topTextView: UITextView!
	@IBOutlet weak var bottomTextView: UITextView!
	@IBOutlet weak var shareButton: UIBarButtonItem!
	@IBOutlet weak var bottomToolbar: UIToolbar!
	
	// MARK: Class variables
	
	// Meme is not nil if MemeEditorViewController is called from MemeDetailViewController
	// It is used to edit an already existing meme
	var meme: Meme?
	
	// Control variables used to indicate if the textField should be cleaned or not when edit starts
	var topTextViewEdited = false
	var bottomTextViewEdited = false
	
	// MARK: Shared Context
	
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance.managedObjectContext
	}
	
	// MARK: Lifecycle
	
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

	}
	
	// MARK: IBActions
	
	// Selects and presents view controller to pick an image
	@IBAction func pickAnImage(sender: UIBarButtonItem) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		
		// Identifies the source
		if (sender == cameraButton) {
			imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
		} else {
			imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		}
		
		presentViewController(imagePicker, animated: true, completion: nil)
	}
	
	// Presents an activity view to share the created meme
	@IBAction func shareMeme(sender: AnyObject) {
		dispatch_async(dispatch_get_main_queue()) {
			let memedImage = self.generateMemedImage()
			let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
			self.presentViewController(activityViewController, animated: false, completion: nil)
			activityViewController.completionWithItemsHandler = {
				(activity, success, items, error) in
				if (success) {
					self.saveMeme(memedImage) // The meme is saved only if the activity view operation was succesful
					self.dismissViewControllerAnimated(true, completion: nil)
				}
			}
		}
	}
	
	// Dismiss the view controller
	@IBAction func cancelButtonTouch(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	// MARK: Helper methods
	
	// Stores the meme
	func saveMeme(memedImage: UIImage) {
		let _ = Meme(topText: self.topTextView.text!, bottomText: self.bottomTextView.text!, originalImage: self.imagePickerView.image!, memedImage: memedImage, insertIntoManagedObjectContext: self.sharedContext)
		CoreDataStackManager.sharedInstance.saveContext()
	}
	
	// Generates an image (memedImage) that is the original image with the text fields on top of it
	func generateMemedImage() -> UIImage {

		// Creates a context with the size of imagePickerView to draw the meme
		UIGraphicsBeginImageContextWithOptions(imagePickerView.frame.size, true, 0.0)
		
		// The frame to be drawn should be the size of the self.view to maintain image proportions
		// The origin of the frame has to me translated to take in consideration imagePickerView's origin
		let drawFrame = CGRect(x: -imagePickerView.frame.origin.x, y: -imagePickerView.frame.origin.y, width: view.frame.width, height: view.frame.height)
		
		// Draws the image in the drawFrame
		// The method should be called by self.view because the textViews are in its hierarchy
		view.drawViewHierarchyInRect(drawFrame, afterScreenUpdates: true)
		
		// Gets memed image from context
		let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

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
	
	// MARK: Keyboard helper methods
	
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
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
		return keyboardSize.CGRectValue().height
	}
	
	// MARK: UI configuration
	
	func configureUI() {
		
		// Disables cameraButton if the camera is not avaible
		cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
		
		// imagePickerView initial configuration
		imagePickerView.contentMode = UIViewContentMode.ScaleAspectFit
		imagePickerView.backgroundColor = UIColor.blackColor()
		
		// If meme is nil, then a new meme will be created
		if (meme == nil) {
			topTextView.text = "TOP"
			topTextViewEdited = false
			
			bottomTextView.text = "BOTTOM"
			bottomTextViewEdited = false
		}
		// Meme is not nil, it is editing an existing meme
		else {
			topTextView.text = meme!.topText
			topTextViewEdited = true
			
			bottomTextView.text = meme!.bottomText
			bottomTextViewEdited = true
			
			imagePickerView.image = meme!.originalImage
		}
		
		// If there's no image selected, shareButton is disabled and the text views are hidden
		if (imagePickerView.image == nil) {
			topTextView.hidden = true
			bottomTextView.hidden = true
			shareButton.enabled = false
		} else {
			topTextView.hidden = false
			bottomTextView.hidden = false
			shareButton.enabled = true
		}
	}
}

// MARK: UITextViewDelegate
extension MemeEditorViewController : UITextViewDelegate {
	func textViewShouldBeginEditing(textView: UITextView) -> Bool {
		if textView == topTextView {
			if !topTextViewEdited {
				textView.text = ""
				topTextViewEdited = true
			}
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
		
		if text == "\n" {
			textView.resignFirstResponder()
		}
		
		return true
	}
}

// MARK: UIImagePickerControllerDelegate
extension MemeEditorViewController : UIImagePickerControllerDelegate {
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
}