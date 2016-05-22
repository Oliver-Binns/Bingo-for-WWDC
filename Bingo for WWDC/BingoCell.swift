//
//  BingoCell.swift
//  Bingo for WWDC
//
//  Created by Oliver on 19/05/2016.
//  Copyright © 2016 Oliver Binns. All rights reserved.
//

import UIKit

class BingoCell: UICollectionViewCell {
	@IBOutlet var label: UILabel!
	
	func animateLabel() -> Bool{
		if let match = self.label.text!.rangeOfString("(?<=\\().*(?=\\))", options: .RegularExpressionSearch) {
			let numberValue = self.label.text?.substringWithRange(Range(match.startIndex.successor() ..< match.endIndex))
			var intNumberValue = Int(numberValue!)!
			intNumberValue -= 1
			
			
			UIView.animateWithDuration(0.25, animations: {
				self.label.transform = CGAffineTransformScale(self.label.transform, 1.5, 1.5)
				}, completion: {
					finished in
					if(intNumberValue <= 1){
						//Remove Number completely
						self.label.text = self.label.text?.substringToIndex(match.startIndex.predecessor().predecessor())
					}else{
						self.label.text = (self.label.text?.substringToIndex(match.startIndex.successor()))! + String(intNumberValue) + ")"
					}
					UIView.animateWithDuration(0.15, animations: {
						self.label.transform = CGAffineTransformIdentity
					})
			})
			return false
		}else{
			UIView.animateWithDuration(0.25, animations: {
				self.label.transform = CGAffineTransformScale(self.label.transform, 0.01, 0.01)
				}, completion: {
					finished in
					self.label.text = "✓"
					self.label.font = UIFont.boldSystemFontOfSize(self.label.font.pointSize * 3)
					UIView.animateWithDuration(0.15, animations: {
						self.label.transform = CGAffineTransformIdentity
					})
			})
			return true
		}
	}
}
