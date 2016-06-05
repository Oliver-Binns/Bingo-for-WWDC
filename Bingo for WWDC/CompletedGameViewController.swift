//
//  CompletedGameViewController.swift
//  Bingo for WWDC
//
//  Created by Oliver on 21/05/2016.
//  Copyright © 2016 Oliver Binns. All rights reserved.
//

import UIKit

class CompletedGameViewController: UIViewController {
	static var controller: ViewController?
	static var score_id: Int?
	
	var result = -1
	var session = ""
	var screenshot: UIImage?
	
	@IBOutlet var disqualified: UILabel!
	@IBOutlet var youPlacedLabel: UILabel!
	@IBOutlet var completedView: UIView!
	@IBOutlet var loadingSpinner: UIActivityIndicatorView!
	@IBOutlet var positionLabel: UILabel!
	@IBOutlet var shareButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if(CompletedGameViewController.score_id == nil){
			getPosition();
		}else{
			checkPosition();
		}
        // Do any additional setup after loading the view.
    }
	
	func checkPosition(){
		let params = [
			"password":ServerConfigs.PASSWORD,
			"score_id": CompletedGameViewController.score_id!
			] as Dictionary<String, Any>
		makeRequest(params)
	}

	func getPosition(){
		let params = [
			"password":ServerConfigs.PASSWORD,
			"phrase0": CompletedGameViewController.controller?.currentAdjectives[0],
			"phrase1": CompletedGameViewController.controller?.currentAdjectives[1],
			"phrase2": CompletedGameViewController.controller?.currentAdjectives[2],
			"phrase3": CompletedGameViewController.controller?.currentAdjectives[3],
			"phrase4": CompletedGameViewController.controller?.currentAdjectives[4],
			"phrase5": CompletedGameViewController.controller?.currentAdjectives[5]
			] as Dictionary<String, Any>
		makeRequest(params);
	}
	
	@IBAction func shareResult(sender: AnyObject) {
		let hashtag = "#"+self.session.stringByReplacingOccurrencesOfString(" ", withString: "");
		if(self.screenshot == nil){
			self.screenshot = CompletedGameViewController.controller?.screenshot!
		}
		let shareSheet = UIActivityViewController(activityItems: ["I came",result.toPosition(),"playing along at",hashtag,"with Keynote Bingo!", self.screenshot!, NSURL(string: "https://itunes.apple.com/us/app/bingo-for-wwdc/id1114302685")!], applicationActivities: nil)
		presentViewController(shareSheet, animated: true, completion: nil)
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func dismissController(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
		CompletedGameViewController.controller?.refreshAdjectives(self);
	}
	
	func makeRequest(params: Dictionary<String, Any>){
		let request = NSMutableURLRequest(URL: NSURL(string: ServerConfigs.URL + "wwdc_bingo/game_completed.php")!)
		let session = NSURLSession.sharedSession()
		request.HTTPMethod = "POST"
		
		request.setBodyContent(params);
		request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type") //Optional
		
		let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
			do{
				let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! NSDictionary
				let defaults = NSUserDefaults();
				
				if let integer = json["position"] as? Int{
					self.result = integer;
					
					dispatch_async(dispatch_get_main_queue(),{
						self.positionLabel.text = self.result.toPosition();
					})
				}
				
				if let session_name = json["session"] as? String{
					self.session = session_name;
					
					if(CompletedGameViewController.controller?.screenshot != nil){
						let screenshot_data = UIImagePNGRepresentation((CompletedGameViewController.controller?.screenshot)!);
						defaults.setObject(screenshot_data, forKey: session_name)
					}else{
						let screenshot_data = defaults.objectForKey(session_name) as! NSData;
						self.screenshot = UIImage(data: screenshot_data);
					}
					
					if let update_id = json["update_id"] as? Int{
						//Save id..
						var positions = defaults.objectForKey("scores") as? Dictionary<String, Int>
						if(positions == nil){
							positions = Dictionary<String, Int>()
						}
						
						positions?.updateValue(update_id, forKey: session_name)
						defaults.setObject(positions, forKey: "scores")
					}
				}
					
				if let verified = json["verified"] as? Int{
					if(verified != 1){
						dispatch_async(dispatch_get_main_queue(),{
							self.positionLabel.text = ":(";
							self.positionLabel.textColor = UIColor.init(red: 241/255.0, green: 0, blue: 29/255.0, alpha: 1);
							self.youPlacedLabel.text = "You Cheated";
							self.disqualified.text = "Disqualified";
							self.shareButton.hidden = true;
						});
					}
				}
				
				dispatch_async(dispatch_get_main_queue(),{
					self.loadingSpinner.stopAnimating()
					self.completedView.hidden = false;
				})
			}catch let error as NSError{
				print(error.localizedDescription)
				let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
				print("Error could not parse JSON: '\(jsonStr)'")
			}
		})
		task.resume()
	}
}

extension NSMutableURLRequest {
	/// Populate the HTTPBody of `application/x-www-form-urlencoded` request
	///
	/// - parameter parameters:   A dictionary of keys and values to be added to the request
	func setBodyContent(parameters: [String:Any]) {
		let parameterArray = parameters.map { (key, value) -> String in
			if let str = value as? String {
				return "\(key)=\(str.stringByAddingPercentEscapesForQueryValue()!)"
			}else{
				return "\(key)=\(value)"
			}
		}
		HTTPBody = parameterArray.joinWithSeparator("&").dataUsingEncoding(NSUTF8StringEncoding)
	}
}

extension String {
	/// Percent escape value to be added to a URL query value as specified in RFC 3986
	///
	/// This percent-escapes all characters except the alphanumeric character set and "-", ".", "_", and "~".
	///
	/// http://www.ietf.org/rfc/rfc3986.txt
	///
	/// - returns:   Return precent escaped string.
	func stringByAddingPercentEscapesForQueryValue() -> String? {
		let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
		characterSet.addCharactersInString("-._~")
		return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
	}
}

extension Int{
	func toPosition() -> String{
		let string = String(self);
		
		if((self % 100) >= 11 && (self % 100) <= 13){
			return string + "th";
		}else if(self % 10 == 1){
			return string + "st";
		}else if(self % 10 == 2){
			return string + "nd";
		}else if(self % 10 == 3){
			return string + "rd";
		}else{
			return string + "th";
		}
	}
}
