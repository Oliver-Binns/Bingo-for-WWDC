//
//  CompletedGameViewController.swift
//  Bingo for WWDC
//
//  Created by Oliver on 21/05/2016.
//  Copyright © 2016 Oliver Binns. All rights reserved.
//

import UIKit

class CompletedGameViewController: UIViewController {
	static var previousScreenshot: UIImage? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

	
	@IBAction func shareResult(sender: AnyObject) {
		//let url = NSURL(string: "https://itunes.apple.com/us/app/sunscreen-helper/id1107339753")
		let shareSheet = UIActivityViewController(activityItems: ["I came ** playing along at #WWDC16 with Keynote Bingo!", CompletedGameViewController.previousScreenshot!], applicationActivities: nil)
		presentViewController(shareSheet, animated: true, completion: nil)
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func dismissController(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
}
