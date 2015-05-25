//
//  SentMemesCollectionVC.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 5/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import UIKit

class SentMemesCollectionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var memes: [Meme]!
  var collectionViewIsEditing: Bool!
  @IBOutlet weak var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Sent Memes"
    
    // Remove title from tabBar item
    let tabItems = self.tabBarController!.tabBar.items as! [UITabBarItem]
    let tabItem = tabItems[1] as UITabBarItem
    tabItem.title = ""
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Load the memes from the AppDelegate
    let object = UIApplication.sharedApplication().delegate
    let appDelegate = object as! AppDelegate
    memes = appDelegate.memes
    
    // collectionView configuration and reloading - needed to update the items
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionViewIsEditing = false
    collectionView.reloadData()
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return memes.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
    let meme = self.memes[indexPath.item]
    
    // Set name and image
    cell.hidden = false
    cell.memedImage.image = meme.memedImage
    cell.deleteLabel.hidden = !collectionViewIsEditing
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if (collectionViewIsEditing == true) {
      deleteMeme(indexPath.item)
    } else {
      let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailVC") as! MemeDetailVC
      detailController.meme = memes[indexPath.item]
      detailController.memeIndex = indexPath.item
      self.navigationController!.pushViewController(detailController, animated: true)
    }
  }
  
  @IBAction func enableEdit(sender: AnyObject) {
    collectionViewIsEditing = !collectionViewIsEditing
    collectionView.reloadData()
  }
  
  func deleteMeme(index: Int) {
    let object = UIApplication.sharedApplication().delegate
    let appDelegate = object as! AppDelegate
    appDelegate.memes.removeAtIndex(index)
    
    // Resolving view problem
    memes.removeAtIndex(index)
    collectionView.reloadData()
  }
}
