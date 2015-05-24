//
//  ViewController.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 5/23/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import UIKit

class MemeEditorVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

  @IBOutlet weak var imagePickerView: UIImageView!
  @IBOutlet weak var cameraButton: UIBarButtonItem!
  @IBOutlet weak var pickButton: UIBarButtonItem!
  @IBOutlet weak var topTextField: UITextField!
  @IBOutlet weak var bottomTextField: UITextField!
  @IBOutlet weak var shareButton: UIBarButtonItem!
  @IBOutlet weak var topToolbar: UIToolbar!
  @IBOutlet weak var bottomToolbar: UIToolbar!

  var topTextFieldEdited: Bool!
  var bottomTextFieldEdited: Bool!
  
  let memeTextAttributes = [
    NSStrokeColorAttributeName : UIColor.blackColor(),
    NSForegroundColorAttributeName : UIColor.whiteColor(),
    NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    NSStrokeWidthAttributeName : -3.0
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    
    imagePickerView.contentMode = UIViewContentMode.ScaleAspectFill
    
    topTextField.text = "TOP"
    topTextField.defaultTextAttributes = memeTextAttributes
    topTextField.textAlignment = .Center
    topTextFieldEdited = false
    topTextField.delegate = self
    
    bottomTextField.text = "BOTTOM"
    bottomTextField.delegate = self
    bottomTextField.defaultTextAttributes = memeTextAttributes
    bottomTextField.textAlignment = .Center
    bottomTextFieldEdited = false
    
    shareButton.enabled = false
  }
  
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if (textField.tag == 3) {
      if (!topTextFieldEdited) {
        textField.text = ""
        topTextFieldEdited = true
      }
    } else if (textField.tag == 4) {
      subscribeToKeyboardNotifications()
      if (!bottomTextFieldEdited) {
        textField.text = ""
        bottomTextFieldEdited = true
      }
    }
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    unsubscribeFromKeyboardNotifications()
    return true
  }
  
  func keyboardWillShow(notification: NSNotification) {
    self.view.frame.origin.y -= getKeyboardHeight(notification)
  }
  
  func keyboardWillHide(notification: NSNotification) {
    self.view.frame.origin.y += getKeyboardHeight(notification)
  }
  
  func subscribeToKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
  }
  
  func unsubscribeFromKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name:
      UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }
  
  func getKeyboardHeight(notification: NSNotification) -> CGFloat {
    let userInfo = notification.userInfo
    let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
    return keyboardSize.CGRectValue().height
  }

  @IBAction func pickAnImage(sender: AnyObject) {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    
    // Identifies the source
    if (sender.tag == 1) {
      imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
    } else if (sender.tag == 2) {
      imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    }
    
    self.presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  @IBAction func shareMeme(sender: AnyObject) {
    let memedImage = self.generateMemedImage()
    let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
    self.presentViewController(activityVC, animated: true, completion: nil)
    activityVC.completionWithItemsHandler = {
      (activity, success, items, error) in
      self.save()
      self.dismissViewControllerAnimated(true, completion: nil)
    }
  }

  // UIImagePickerControllerDelegate methods
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      imagePickerView.image = image
      shareButton.enabled = true
    }
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(true, completion: nil)
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

