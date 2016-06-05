//
//  CountdownViewController.swift
//  Bingo for WWDC
//
//  Created by Oliver on 04/06/2016.
//  Copyright © 2016 Oliver Binns. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {

	@IBOutlet var loadingSpinner: UIActivityIndicatorView!
	@IBOutlet var countdownView: UIView!
	
	static var session = "";
	var startTime: NSDate?;
	@IBOutlet var daysLabel: UILabel!
	@IBOutlet var hoursLabel: UILabel!
	@IBOutlet var minutesLabel: UILabel!
	@IBOutlet var secondsLabel: UILabel!
	
	@IBOutlet var shareButton: UIButton!
	@IBOutlet var beginLabel: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let request = NSMutableURLRequest(URL: NSURL(string: ServerConfigs.URL + "wwdc_bingo/next_event.php")!)
		let session = NSURLSession.sharedSession()
		request.HTTPMethod = "GET"
		
		let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
			do{
				let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! NSDictionary
				if let session_name = json["session"] as? String{
					CountdownViewController.session = session_name;
					let defaults = NSUserDefaults()
					let scores = defaults.objectForKey("scores") as? Dictionary<String, Int>
					if scores != nil{
						if scores![session_name] != nil{
							CompletedGameViewController.score_id = scores![session_name]
							dispatch_async(dispatch_get_main_queue(),{
								self.dismissViewControllerAnimated(true, completion: {
									void in
									UIApplication.sharedApplication().keyWindow?.rootViewController?.performSegueWithIdentifier("gameCompleted", sender: nil)
									return;
								})
								
							})
						}
					}
				}
				
				if let timestamp = json["endTime"] as? Int{
					let endTime = NSDate.init(timeIntervalSince1970: NSTimeInterval(timestamp))
					if(NSDate().compare(endTime) == .OrderedDescending) {
						dispatch_async(dispatch_get_main_queue(),{
							self.beginLabel.text = "Keynote Bingo has finished.";
							self.daysLabel.text = "Join";
							self.hoursLabel.text = "Us";
							self.minutesLabel.text = "Next";
							self.secondsLabel.text = "Time";
							self.loadingSpinner.stopAnimating()
							self.countdownView.hidden = false;
						})
						return;
					}
				}
				if let timestamp = json["startTime"] as? Int{
					self.startTime = NSDate.init(timeIntervalSince1970: NSTimeInterval(timestamp))
					dispatch_async(dispatch_get_main_queue(),{
						self.updateTimer();
						_ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
						self.loadingSpinner.stopAnimating()
						self.countdownView.hidden = false;
						self.shareButton.hidden = false;
					})
				}
			}catch let error as NSError{
				print(error.localizedDescription)
				let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
				print("Error could not parse JSON: '\(jsonStr)'")
			}
		})
		task.resume()
        // Do any additional setup after loading the view.
    }
	
	func updateTimer(){
		let currentDate = NSDate();
		if(currentDate.compare(self.startTime!) == .OrderedAscending) {
			let diffDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: currentDate, toDate: self.startTime!, options: NSCalendarOptions.init(rawValue: 0))
			self.daysLabel.text = String(diffDateComponents.day) + " days";
			self.hoursLabel.text = String(diffDateComponents.hour) + " hours";
			self.minutesLabel.text = String(diffDateComponents.minute) + " minutes";
			self.secondsLabel.text = String(diffDateComponents.second) + " seconds";
		}else{
			//Perhaps some cool animation here--welcome to WWDC?
			self.dismissViewControllerAnimated(true, completion: nil)
		}
	}

	@IBAction func shareApp(sender: AnyObject) {
		let diffDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: NSDate(), toDate: self.startTime!, options: NSCalendarOptions.init(rawValue: 0))
		
		var countdown = ""
		let attributes = ["day", "hour", "minute", "second"]
		for attribute in attributes{
			if(attribute == "second"){
				countdown += " and ";
			}else if(countdown != ""){
				countdown += ", ";
			}
			let componentValue = diffDateComponents.valueForKey(attribute) as! Int
			if(componentValue > 0){
				countdown += String(diffDateComponents.valueForKey(attribute)!) + " " + attribute;
				if(componentValue > 1){
					countdown += "s";
				}
			}
		}
		
		let hashtag = "#" + (CountdownViewController.session.stringByReplacingOccurrencesOfString(" ", withString: ""));
		let shareSheet = UIActivityViewController(activityItems: [hashtag, "is in",countdown + ". Join me for a game of Keynote Bingo!", NSURL(string: "https://itunes.apple.com/us/app/bingo-for-wwdc/id1114302685")!], applicationActivities: nil)
		presentViewController(shareSheet, animated: true, completion: nil)
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
