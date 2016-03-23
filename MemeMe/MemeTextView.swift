//
//  MemeTextView.swift
//  MemeMe
//
//  Created by Marcel Oliveira Alves on 3/23/16.
//  Copyright © 2016 Marcel Oliveira Alves. All rights reserved.
//

import UIKit

class MemeTextView : UITextView {
	
	override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
		if action == "paste:" {
			return false
		}
		return super.canPerformAction(action, withSender: sender)
	}
}
