//
//  EventInfoViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/18/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit
import FirebaseDatabase


class EventInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /* UI STUFF ----------------------------------------------------*/
    //Event name and join button (reference and action func)
    @IBOutlet var eventNameLabel: UILabel!
    @IBOutlet var joinButton: UIButton!
    @IBAction func joinClick(sender: AnyObject) {
        self.userHasJoined = !self.userHasJoined;
        if (self.userHasJoined) {
            self.joinButton.setTitle("Joined", forState: UIControlState.Normal);
            self.joinButton.backgroundColor = UIColor.redColor();
            //push userID to attendees list
            
        }
        else {
            self.joinButton.setTitle("Join", forState: UIControlState.Normal);
            self.joinButton.backgroundColor = UIColor.yellowColor();
            //remove userID from attendees list
            
        }
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
    @IBAction func inviteClick(sender: AnyObject) {}
    @IBOutlet var joinedView: UIView!
    
    
    //Photo and comment views and buttons
    @IBAction func viewPhotoClick(sender: AnyObject) {}
    @IBOutlet var uploadImageView: UIImageView!
    @IBOutlet var commentTableView: UITableView!
    @IBOutlet var commentTableHeightConstraint: NSLayoutConstraint!
    /*--------------------------------------------------------------*/
    
    
    private var eventID:String? //will null check before pulling
    private var event:Event! //guarenteed non-null from pull
    private var comments:[Comment] = [] //list of comments
    private var userHasJoined:Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false;
        if (eventID != nil) {
            pullAndShowEvent();
            pullAndShowComments();
        }
        else {
            print("Event ID is null, WHY IS IT NULL");
        }
        
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(EventInfoViewController.respondToSwipeGesture(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
//        swipeDown.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Gets the event from the passed in eventID and updates view with event info
    func pullAndShowEvent() {
        Globals.fb.child("Events").child(self.eventID!).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            self.event = Event.init(eventDict: snapshot.value as! NSDictionary);
            
            //update the view with event info
            //name
            self.eventNameLabel.text = self.event.getName();
            
            //update joined bool and join button
            if self.event.getAttendees() != nil {
                self.userHasJoined = (self.event.getAttendees()!.contains(Globals.me.userID));
                self.joinedLabel.text = "Joined (\(self.event.getAttendees()!.count))";
            }
            if (self.userHasJoined) {
                self.joinButton.setTitle("Joined", forState: UIControlState.Normal);
                self.joinButton.backgroundColor = UIColor.redColor();
            }
            else {
                self.joinButton.setTitle("Join", forState: UIControlState.Normal);
                self.joinButton.backgroundColor = UIColor.yellowColor();
            }
            
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
            //send request to get image
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
                (data, response, error) in
                //if data grabbed, update image if in main thread
                if (data != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.creatorImageView.image = UIImage(data: data!)?.rounded;
                    });
                }
            };
            task.resume();
            //btw this is the one-line grab for small url data
//          self.creatorImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: urlString)!)!);
            
        });
    }
    
    func pullAndShowComments() {
        Globals.fb.child("Comments").child(self.eventID!).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            let eventComments:[FIRDataSnapshot]? = snapshot.children.allObjects as? [FIRDataSnapshot];
            
            //only if comments exist
            if (eventComments != nil) {
                //iterate through all snapshots and convert each .value -> dictionary -> comment and add to comments array
                for eachComment in  eventComments!{
                    self.comments.append(Comment.init(dictionary:eachComment.value as! [String:AnyObject]));
                }
                //display comments in tableview
                
            }
                
            //no comments so show "No comments"
            else {
                
            }
        });
    }
    
    
    func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        print("bottom swipe");
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated);
//        if ((self.navigationController) != nil) {
//            self.navigationController?.navigationBarHidden = true;
//        }
//    }
    
    /* Comment table data source and delegates ---------------------------------------*/
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:CommentTableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? CommentTableViewCell;
        //if not registered yet, then register first
        if (cell == nil) {
            tableView.registerNib(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "Cell");
            cell = (tableView.dequeueReusableCellWithIdentifier("Cell") as! CommentTableViewCell);
        }
        
        cell!.commentName.text = "Name";
        cell!.commentText.text = "alskdjfasdf\nasdfa\nasdfas\nasdfad\nasdfadsf\nasdf";
//        cell!.commentText.sizeToFit();
        self.commentTableHeightConstraint.constant = 200;
        
        return cell!;
    }
    
    /*--------------------------------------------------------------------------------*/
    
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