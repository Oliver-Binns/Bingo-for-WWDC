//
//  ViewController.swift
//  Bingo for WWDC
//
//  Created by Oliver on 14/05/2016.
//  Copyright © 2016 Oliver Binns. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

	@IBOutlet var collectionView: UICollectionView!
	var adjectives: [String] = [];
	var currentAdjectives: [String] = [];
	var colors: [UIColor] = [];
	var currentColors: [UIColor] = [];
	
	override func viewDidLoad() {
		self.automaticallyAdjustsScrollViewInsets = false
		super.viewDidLoad()
		readFromJson()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	@IBAction func refreshAdjectives(sender: AnyObject) {
		if((self.adjectives.count - self.currentAdjectives.count) < self.collectionView.numberOfItemsInSection(0)){
			self.currentAdjectives = []
		}
		self.currentColors = []
		self.collectionView.reloadData()
	}
	
	func readFromJson(){
		if let path = NSBundle.mainBundle().pathForResource("adjectives", ofType: "json") {
			do {
				let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
				do {
					let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
					if let parsed_adjectives : [String] = jsonResult["adjectives"] as? [String] {
						self.adjectives = parsed_adjectives
					}
					if let parsed_colors: [[String: Int]] = jsonResult["colors"] as? [[String: Int]]{
						self.colors = []
						for color in parsed_colors{
							let color = UIColor(red: CGFloat(color["red"]!) / 255.0, green: CGFloat(color["green"]!) / 255.0, blue: CGFloat(color["blue"]!) / 255.0, alpha: 1.0)
							self.colors.append(color)
						}
					}
				} catch {}
			} catch {}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 6;
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("bingoCell", forIndexPath: indexPath) as! BingoCell
		let maxIndex = self.adjectives.count
		var randomIndex = Int(arc4random_uniform(UInt32(maxIndex)))
		
		while(self.currentAdjectives.contains(self.adjectives[randomIndex])){
			randomIndex = Int(arc4random_uniform(UInt32(maxIndex)))
		}
		self.currentAdjectives.append(self.adjectives[randomIndex])
		cell.label.text = self.adjectives[randomIndex]
		
		randomIndex = Int(arc4random_uniform(UInt32(self.colors.count)))
		while(self.currentColors.contains(self.colors[randomIndex])){
			randomIndex = Int(arc4random_uniform(UInt32(self.colors.count)))
		}
		cell.backgroundColor = self.colors[randomIndex]
		self.currentColors.append(self.colors[randomIndex])
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		let width = ((self.collectionView.frame.width - 10) / 2);
		let height = (self.collectionView.frame.height - 20) / 3;
		
		return CGSize(width: width, height: height);
	}
	
	override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
		self.collectionView.collectionViewLayout.invalidateLayout()
	}
}

