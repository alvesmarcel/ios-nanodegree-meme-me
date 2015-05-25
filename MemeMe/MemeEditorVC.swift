//
//  MemeEditorVC.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 5/23/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This ViewController is responsible for the meme edition. It is possible to:
//  - Choose a picture from camera or from the photo album
//  -- If the editor is called from the MemeDetail, the picture will already be chosen (it will be the one in the MemeDetailView)
//  - Change the topText (initially set as "TOP") and the bottomText (initially set as "BOTTOM")
//  -- If the editor is called from the MemeDetail, the texts will already be chosen (it will be the ones in the MemeDetailView)
//  - Share the created meme using the share button (top left)
//  
//  After the meme is shared, it will be stored in the memes array of AppDelegate and the view is dismissed

import UIKit

class MemeEditorVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

  @IBOutlet weak var imagePickerView: UIImageView!
  @IBOutlet weak var cameraButton: UIBarButtonItem!
  @IBOutlet weak var topTextField: UITextField!
  @IBOutlet weak var bottomTextField: UITextField!
  @IBOutlet weak var shareButton: UIBarButtonItem!
  @IBOutlet weak var topToolbar: UIToolbar!
  @IBOutlet weak var bottomToolbar: UIToolbar!
  
  // If MemeEditorVC is called from MemeDetailVC, this meme is initialized; otherwise, it will be nil
  // It is used to edit an already existing meme
  var meme: Meme!

  // Controls variables used to indicate if the textField should be cleaned or not when edit starts
  var topTextFieldEdited: Bool!
  var bottomTextFieldEdited: Bool!
  
  // Dictionary of meme text attributes
  let memeTextAttributes = [
    NSStrokeColorAttributeName : UIColor.blackColor(),
    NSForegroundColorAttributeName : UIColor.whiteColor(),
    NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    NSStrokeWidthAttributeName : -4.0
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Disables cameraButton if the camera is not avaible
    cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    
    // Sets delegates
    topTextField.delegate = self
    bottomTextField.delegate = self
    
    // Sets attributes of text fields
    setTextAttributes(topTextField)
    setTextAttributes(bottomTextField)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // imagePickerView initial configuration
    imagePickerView.contentMode = UIViewContentMode.ScaleAspectFit
    imagePickerView.backgroundColor = UIColor.darkGrayColor()
    
    // Checks if meme is nil (MemeEditorVC was called from a Sent Memes VC) or not (MemeEditorVC was called from MemeDetailVC)
    if (meme == nil) {
      topTextField.text = "TOP"
      topTextFieldEdited = false
      
      bottomTextField.text = "BOTTOM"
      bottomTextFieldEdited = false
    } else {
      topTextField.text = meme.topText
      topTextFieldEdited = true
      
      bottomTextField.text = meme.bottomText
      bottomTextFieldEdited = true
      
      imagePickerView.image = meme.originalImage
    }
    
    // If there's no image selected, shareButton is disabled and the text fields are hidden
    if (imagePickerView.image == nil) {
      topTextField.hidden = true
      bottomTextField.hidden = true
      shareButton.enabled = false
    } else {
      topTextField.hidden = false
      bottomTextField.hidden = false
      shareButton.enabled = true
    }
    
  }
  
  // Sets attributes of a UITextField and align the text
  func setTextAttributes(textField: UITextField) {
    textField.defaultTextAttributes = memeTextAttributes
    textField.textAlignment = .Center
  }
  
  // Performs some treatment (clean text field) when the user edits the text field for the first time
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    setTextAttributes(textField) // Avoid bug from commit 440310157272601e563c4e116218223778cb16fb
    if (textField.tag == 3) {
      if (!topTextFieldEdited) {
        textField.text = ""
        topTextFieldEdited = true
      }
    } else if (textField.tag == 4) {
      subscribeToKeyboardNotifications() // only the bottomTextField should activate the listening of notification messages
      if (!bottomTextFieldEdited) {
        textField.text = ""
        bottomTextFieldEdited = true
      }
    }
    return true
  }
  
  // Hides the keyboard
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    // When the keyboard is gone, it is useful to deactivate listening notifications because it can cause problems with the rest
    // of the logic (only the bottomTextField editing should move the screen up)
    unsubscribeFromKeyboardNotifications()
    
    return true
  }
  
  // Moves the screen up
  func keyboardWillShow(notification: NSNotification) {
    view.frame.origin.y -= getKeyboardHeight(notification)
  }
  
  // Moves the screen down
  func keyboardWillHide(notification: NSNotification) {
    view.frame.origin.y += getKeyboardHeight(notification)
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
    let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
    self.presentViewController(activityVC, animated: true, completion: nil)
    activityVC.completionWithItemsHandler = {
      (activity, success, items, error) in
      if (success) {
        self.save() // The meme is saved only if the operation was succesful
      }
      self.dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  @IBAction func cancelEdition(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  // UIImagePickerControllerDelegate methods
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      imagePickerView.image = image
      shareButton.enabled = true
    }
    dismissViewControllerAnimated(true, completion: nil)
  }

  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func save() {
    var meme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
    
    let object = UIApplication.sharedApplication().delegate
    let appDelegate = object as! AppDelegate
    appDelegate.memes.append(meme)
  }
  
  func generateMemedImage() -> UIImage {
    // Hide top and bottom toolbars
    topToolbar.hidden = true
    bottomToolbar.hidden = true
    
    // Get the image from screen
    UIGraphicsBeginImageContext(self.view.frame.size)
    self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
    let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    // Show top and bottom toolbars
    topToolbar.hidden = false
    bottomToolbar.hidden = false
    
    return memedImage
  }
}

