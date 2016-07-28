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
                (snapshot) in
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
                
                //creator REPLACE WITH NAME INSTEAD OF ID
                self.creatorNameLabel.text = "Whoever " + self.event.getCreatorID() + " is";
                self.creatorNameLabel.sizeToFit();                
                
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
