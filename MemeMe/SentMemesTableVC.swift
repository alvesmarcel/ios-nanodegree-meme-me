//
//  SentMemesTableVC.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 5/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import UIKit

class SentMemesTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  var memes: [Meme]!
  @IBOutlet weak var tableView: UITableView!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Load the memes from the AppDelegate
    let object = UIApplication.sharedApplication().delegate
    let appDelegate = object as! AppDelegate
    memes = appDelegate.memes
    
    // Update table when the view appears
    tableView.reloadData()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.memes.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    // TODO: set new size for image in cell
    let cell = tableView.dequeueReusableCellWithIdentifier("tableCell") as! UITableViewCell
    let meme = self.memes[indexPath.row]
    println(meme.topText)
    
    // Set name and image
    cell.textLabel?.text = meme.topText
    cell.imageView?.image = meme.memedImage
    
    return cell
  }
  
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    
  }
}


