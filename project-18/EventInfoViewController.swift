//
//  EventInfoViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/18/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit

class EventInfoViewController: UIViewController {
    
    private var eventID:String? //will null check before pulling
    private var event:Event! //guarenteed non-null from pull

    //Event name and join button (reference and action func)
    @IBOutlet var eventNameLabel: UILabel!
    @IBOutlet var joinButton: UIButton!
    @IBAction func joinClick(sender: AnyObject) {
    }
    
    //Event info labels
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var lengthPreLabel: UILabel!
    @IBOutlet var lengthLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var creatorImageView: UIImageView!
    @IBOutlet var creatorNameLabel: UILabel!
    
    //Joined view and invite button
    @IBOutlet var joinedLabel: UILabel!
    @IBAction func inviteClick(sender: AnyObject) {
    }
    @IBOutlet var joinedView: UIView!
    
    
    //Photo and comment views and buttons
    @IBAction func viewPhotoClick(sender: AnyObject) {
    }
    @IBOutlet var uploadImageView: UIImageView!
    @IBOutlet var commentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pullAndShowEvent();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Gets the event from the passed in eventID and updates view with event info
    func pullAndShowEvent() {
        if (eventID != nil) {
            Globals.fb.child("Events").child(self.eventID!).observeSingleEventOfType(.Value, withBlock: {
                snapshot in
                self.event = Event.init(eventDict: snapshot.value as! NSDictionary);
                
                //update the view with event info
                //name
                self.eventNameLabel.text = self.event.getName();
                
                //start date
                let date = NSDate(timeIntervalSince1970: NSTimeInterval(self.event.getStartTime())/1000);
                let formatter = NSDateFormatter();
                formatter.dateFormat = "MMM dd HH:mm a";
                let startTimeString = formatter.stringFromDate(date);
                //substringing to add "at"
                self.startTimeLabel.text = startTimeString.substringToIndex(startTimeString.startIndex.advancedBy(6)) + " at" + (startTimeString.substringFromIndex(startTimeString.startIndex.advancedBy(6)));
                
                
                //TODO: time logic for duration/end time and location
                //self.lengthLabel.text = self.event.getEndTime();
                //location
                //self.locationLabel.text = self.event.getLocation();
                
                
                //description with auto-resize to fit text
                self.descriptionLabel.text = self.event.getDescription();
                self.descriptionLabel.sizeToFit();
                
                //creator name with another fb pull, non-null guarentee
                Globals.fb.child("Users").child(self.event.getCreatorID()).child("name").observeSingleEventOfType(.Value, withBlock: {
                    snapshot in
                    self.creatorNameLabel.text = String(snapshot.value!);
                });
                self.creatorNameLabel.sizeToFit();
                
                //creator image with URL request
                let width = "250";
                let urlString = "https://graph.facebook.com/" + self.event.getCreatorID()
                    + "/picture?width=" + width;
                let url = NSURL(string: urlString);
                print(url!.absoluteURL);
                //send request to get image
                let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
                    (data, response, error) in
                    //update image if data isn't null in main thread
                    print("grabbed");
                    if (data != nil) {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.creatorImageView.image = UIImage(data: data!)?.rounded;
                        });
                    }
                };
                task.resume();
                //btw this is the one-line grab for small url data
//                self.creatorImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: urlString)!)!);
                
            });
        }
        else {
            print("eventID is null WHY IS IT NULL");
        }
    }
    
    
    
    func setEventID(eventID: String) {
        self.eventID = eventID;
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

//some nigga is a g and did this for lols, two methods to round or circle images
extension UIImage {
    var rounded: UIImage? {
        let imageView = UIImageView(image: self)
        imageView.layer.cornerRadius = min(size.height/4, size.width/4)
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.renderInContext(context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    var circle: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .ScaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.renderInContext(context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}