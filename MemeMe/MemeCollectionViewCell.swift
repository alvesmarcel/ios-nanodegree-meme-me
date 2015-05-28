//
//  MemeCollectionViewCell.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 5/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  Custom cell to be used in a Collection View
//  This was created to add the delete label and make it clear that the user is in editing (deleting) mode

import UIKit

class MemeCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var memedImage: UIImageView!
	@IBOutlet weak var deleteLabel: UILabel!
}