//
//  Meme.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 5/23/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This is the Meme model
//  - The struct is composed by two Strings (topText, bottomText) and two UIImages (originalImage, memedImage)
//  - Struct was chosen instead of class as suggested by the Swift-style-guide on Github

import Foundation
import UIKit

struct Meme {
	var topText: String!
	var bottomText: String!
	var originalImage: UIImage!
	var memedImage: UIImage!
}

