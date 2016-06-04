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
	
	var startTime: NSDate?;
	@IBOutlet var daysLabel: UILabel!
	@IBOutlet var hoursLabel: UILabel!
	@IBOutlet var minutesLabel: UILabel!
	@IBOutlet var secondsLabel: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let request = NSMutableURLRequest(URL: NSURL(string: ServerConfigs.URL + "wwdc_bingo/next_event.php")!)
		let session = NSURLSession.sharedSession()
		request.HTTPMethod = "GET"
		
		let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
			do{
				let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! NSDictionary
				print(json);
				if let timestamp = json["startTime"] as? Int{
					self.startTime = NSDate.init(timeIntervalSince1970: NSTimeInterval(timestamp))
					
					dispatch_async(dispatch_get_main_queue(),{
						self.updateTimer();
						_ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
						self.loadingSpinner.stopAnimating()
						self.countdownView.hidden = false;
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
