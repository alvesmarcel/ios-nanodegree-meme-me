//
//  MemeDetailVC.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 5/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import UIKit

class MemeDetailVC: UIViewController {
  
  var meme: Meme!
  var memeIndex: Int!
  @IBOutlet weak var imageView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Meme Detail"
    
    imageView.contentMode = UIViewContentMode.ScaleAspectFit
    
    let rightButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editMeme")
    self.navigationItem.rightBarButtonItem = rightButton
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    imageView.image = meme.memedImage
  }
  
  func editMeme() {
    
  }
  
  @IBAction func deleteMeme(sender: AnyObject) {
    let object = UIApplication.sharedApplication().delegate
    let appDelegate = object as! AppDelegate
    appDelegate.memes.removeAtIndex(memeIndex)
    self.navigationController?.popToRootViewControllerAnimated(true)
  }
}
