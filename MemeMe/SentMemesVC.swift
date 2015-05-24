//
//  SentMemesVC.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 5/23/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import Foundation
import UIKit

class SentMemesVC: UIViewController {

  var memes: [Meme]!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    let object = UIApplication.sharedApplication().delegate
    let appDelegate = object as! AppDelegate
    memes = appDelegate.memes
  }
}