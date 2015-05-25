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
      // TODO: Create a better solution to delete the item cell
      
      collectionView.cellForItemAtIndexPath(indexPath)?.hidden = true // A bad temporary solution - it will be here till I find a better one
      // collectionView.deleteItemsAtIndexPaths([indexPath]) - Crashes the app
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
  }
}
