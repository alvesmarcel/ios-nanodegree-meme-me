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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Sent Memes"
    
    // Remove title from tabBar item
    let tabItems = self.tabBarController!.tabBar.items as! [UITabBarItem]
    let tabItem = tabItems[0] as UITabBarItem
    tabItem.title = ""
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
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return memes.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    // TODO: set new size for image in cell
    let cell = tableView.dequeueReusableCellWithIdentifier("tableCell") as! UITableViewCell
    let meme = self.memes[indexPath.row]
    
    // Set name and image
    cell.textLabel?.text = meme.topText + " " + meme.bottomText
    cell.imageView?.image = meme.memedImage
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailVC") as! MemeDetailVC
    detailController.meme = memes[indexPath.row]
    detailController.memeIndex = indexPath.row
    self.navigationController!.pushViewController(detailController, animated: true)
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == UITableViewCellEditingStyle.Delete {
      memes.removeAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      deleteMeme(indexPath.row)
    }
  }
  
  @IBAction func enableEdit(sender: AnyObject) {
    tableView.editing = !tableView.editing
  }
  
  func deleteMeme(index: Int) {
    let object = UIApplication.sharedApplication().delegate
    let appDelegate = object as! AppDelegate
    appDelegate.memes.removeAtIndex(index)
  }
}


