//
//  EventInfoViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/18/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreLocation

//Current bug: only allow back button after transaction completes, if user goes super fast, it will crash

class EventInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {

    /* UI STUFF ----------------------------------------------------*/
    //Elements hidden/unhidden for nonexistent events
    @IBOutlet var mainView: UIView!

    //Event name and join button (reference and action func)
    @IBOutlet var eventNameLabel: UILabel!
    @IBOutlet var joinButton: UIButton!
    @IBAction func joinClick(sender: AnyObject) {
        if (self.event != nil) { //check just in case event takes a while to load
            //Reverse joined boolean
            self.userHasJoined = !self.userHasJoined;
            
            //if user is now joined, change button UI, handle user attend, and upate joined view
            if (self.userHasJoined) {
                self.joinButton.setTitle("Joined", forState: UIControlState.Normal);
                self.joinButton.backgroundColor = Globals.COLOR_DIVIDER_LIGHT
                Globals.me.attendEvent(self.event!.getEventID(), eventName: self.event!.getName(), creatorID: self.event!.getCreatorID());
                
                var newAttendees = self.event!.getAttendees();
                newAttendees.append(Globals.me.getUserID());
                self.event!.setAttendees(newAttendees);
                self.updateJoinedView();
            }
                
            //if user is now unjoined, change button UI, handle user unattend, and update joined view
            else {
                self.joinButton.setTitle("Join", forState: UIControlState.Normal);
                self.joinButton.backgroundColor = Globals.COLOR_ACCENT
                Globals.me.unattendEvent(self.event!.getEventID());
                
                var newAttendees = self.event!.getAttendees();
                let index = self.event!.getAttendees().indexOf(Globals.me.getUserID());
                newAttendees.removeAtIndex((newAttendees.startIndex.distanceTo(index!)));
                self.event!.setAttendees(newAttendees);
                self.updateJoinedView();
            }
            
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
    @IBAction func inviteClick(sender: AnyObject) {
        self.performSegueWithIdentifier("openInvite", sender: self);
    }
    @IBOutlet var joinedCollectionView: UICollectionView!
    @IBOutlet var joinedCollectionViewHeightConstraint: NSLayoutConstraint!
    
    //Photo and comment views and buttons
    @IBOutlet var noCommentLabel: UILabel!
    @IBOutlet var commentTableView: UITableView!
    @IBOutlet var commentTableHeightConstraint: NSLayoutConstraint!
    
    //Write comment toolbar items
    @IBOutlet var commentToolbar: UIToolbar!
    @IBOutlet var commentWriteItem: UIBarButtonItem!
    @IBAction func commentPostClick(sender: AnyObject) {
        self.writeComment();
    }
    
    @IBAction func reportEvent(sender: AnyObject) {
        let reportAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet);
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        reportAlertController.addAction(cancelAction);
        let reportEventAction = UIAlertAction(title: "Report event", style: .Default) { (action) in
            Globals.me.reportEvent(self.event!.getEventID())
        }
        reportAlertController.addAction(reportEventAction);
        let blockUserAction = UIAlertAction(title: "Block creator", style: .Default) { (action) in
            Globals.me.blockUser(self.event!.getCreatorID())
        }
        reportAlertController.addAction(blockUserAction);
        self.presentViewController(reportAlertController, animated: true, completion: nil);
    }
    /*--------------------------------------------------------------*/
    
    
    private var eventID:String? //will null check before pulling
    private var event:Event? //guarenteed non-null after pull
    private var comments:[Comment] = [] //list of comments
    private var commenters:[String] = [] //list of id's of users who have commented
    private var userHasJoined:Bool = false;
    private var joinedImages:[UIImage?] = []; //images of ppl who joined to be show in joinedcollectionview
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (eventID != nil && Globals.eventsIDToEvent.keys.contains(eventID!)) {
            self.pullAndShowEvent(); //TODO:Hide or set everything to initial state before showing with info
            self.pullAndShowComments();
        }
        else {
            print("Event ID is null or event doesn't exist anymore");
            mainView.hidden = true
            commentToolbar.hidden = true
            let alert = UIAlertController(title: "Ooops!",
                                          message: "This event no longer exists.", preferredStyle: .Alert);
            alert.addAction(UIAlertAction(title: "OK", style: .Default , handler: {
                alert in
                self.navigationController?.popToRootViewControllerAnimated(true); //go back a view
            }));
            self.presentViewController(alert, animated: true, completion: nil);
        }
        
        //Write comment text view
        let writeCommentTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width - 75, 28));
        writeCommentTextField.placeholder = "Write comment...";
        writeCommentTextField.font = UIFont.systemFontOfSize(15);
        writeCommentTextField.borderStyle = UITextBorderStyle.RoundedRect;
//        writeCommentTextField.autocorrectionType = UITextAutocorrectionType.No;
        writeCommentTextField.keyboardType = UIKeyboardType.Default;
        writeCommentTextField.returnKeyType = UIReturnKeyType.Done;
        writeCommentTextField.clearButtonMode = UITextFieldViewMode.WhileEditing;
        writeCommentTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        writeCommentTextField.delegate = self;
        self.commentWriteItem.customView = writeCommentTextField;

        //Keyboard listeners for writing comment
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventInfoViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventInfoViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil);
        
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(EventInfoViewController.respondToSwipeGesture(_:)))
//        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
//        self.view.addGestureRecognizer(swipeDown)
//        swipeDown.delegate = self;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.navigationBarHidden = false;
        self.title = "Event Info";
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated);
        //Remove keyboard listeners and comment listener when view disappears
        NSNotificationCenter.defaultCenter().removeObserver(self);
        Globals.fb.child("CommentDatabase").child(self.eventID!).child("comments").removeAllObservers();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Pulls event from passed in event ID and updates view with data from event
     */
    func pullAndShowEvent() {
        Globals.fb.child("Events").child(self.eventID!).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            if snapshot == NSNull() {
                print("Event ID is null or event doesn't exist anymore");
                self.mainView.hidden = true
                self.commentToolbar.hidden = true
                let alert = UIAlertController(title: "Ooops!",
                    message: "This event no longer exists.", preferredStyle: .Alert);
                alert.addAction(UIAlertAction(title: "OK", style: .Default , handler: {
                    alert in
                    self.navigationController?.popToRootViewControllerAnimated(true); //go back a view
                }));
                self.presentViewController(alert, animated: true, completion: nil);
                return;
            }
            
            self.event = Event.init(eventDict: snapshot.value as! NSDictionary);
            
            //update the view with event info -------------------------------------
            //NAME
            self.eventNameLabel.text = self.event!.getName();
            
            //JOIN - update joined bool, joined button, joined label, joined collection view
            self.userHasJoined = (self.event!.getAttendees().contains(Globals.me.getUserID()));
            self.updateJoinedView();
            if (self.userHasJoined) {
                self.joinButton.setTitle("Joined", forState: UIControlState.Normal);
                self.joinButton.backgroundColor = Globals.COLOR_DIVIDER_LIGHT
            }
            else {
                self.joinButton.setTitle("Join", forState: UIControlState.Normal);
                self.joinButton.backgroundColor = Globals.COLOR_ACCENT
            }
            
            //START DATE    TODO: edit Starts vs started label
            let date = NSDate(timeIntervalSince1970: NSTimeInterval(self.event!.getStartTime())/1000);
            self.startTimeLabel.text = stringFromDate(date);
            
            //LENGTH/ENDS IN
            let currentTime = Int64(NSDate().timeIntervalSince1970 * 1000);
            //if event hasn't started yet, show event length
            if (currentTime < Int64(self.event!.getStartTime())) {
                self.lengthPreLabel.text = "Length";
                let startText = durationFromTimeIntervals(startTime: Int64(self.event!.getStartTime()),
                    endTime: Int64(self.event!.getEndTime()))
                self.lengthLabel.text = startText;
            }
            //event has started, so show how long until end
            else {
                self.lengthPreLabel.text = "Ends in";
                var endText = durationFromTimeIntervals(startTime: currentTime,
                    endTime: Int64(self.event!.getEndTime()))
                if (endText.isEmpty) {
                    endText = "Just ended"
                }
                self.lengthLabel.text = endText;
            }
            
            //LOCATION
//            self.locationLabel.text = "\(self.event!.getLocation().latitude), \(self.event!.getLocation().longitude)";
            let geocoder = CLGeocoder();
            geocoder.reverseGeocodeLocation(
                CLLocation(latitude: self.event!.getLocation().latitude, longitude: self.event!.getLocation().longitude),
                completionHandler: {
                    (placemarks, error) in
                    if error != nil {
                        print("error: " + error!.description);
                    }
                    else {
                        let placemark = placemarks?.last;
                        self.locationLabel.text = (placemark!.name);
                    }
            })
//            let locationManager = CLLocationManager()
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.requestWhenInUseAuthorization()
//            locationManager.startUpdatingLocation()
            
            //DESCRIPTION with auto-resize to fit text
            if (self.event!.getDescription().isEmpty) {
                self.descriptionLabel.text = "This event has no description."
            }
            else {
                self.descriptionLabel.text = self.event!.getDescription();
            }
            self.descriptionLabel.sizeToFit();
            
            //CREATOR NAME with another fb pull, non-null guarentee
            Globals.fb.child("Users").child(self.event!.getCreatorID()).child("name").observeSingleEventOfType(.Value, withBlock: {
                snapshot in
                self.creatorNameLabel.text = String(snapshot.value!);
            });
            self.creatorNameLabel.sizeToFit();
            
            //CREATOR IMAGE with URL request
            let width = "250";
            let urlString = "https://graph.facebook.com/\(self.event!.getCreatorID())/picture?width=\(width)";
            let url = NSURL(string: urlString);
            //send request to get image
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
                (data, response, error) in
                //if data grabbed, update image in main thread
                if (data != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.creatorImageView.image = UIImage(data: data!)?.rounded;
                    });
                }
            };
            task.resume();
            
        });
    }
    
    /* 
     * Updates the images shown in the joined collection view. Calls the facebook graph url to pull image
     * based off of user ID and updates the array and collection view each time a photo is received from the 
     * url request. Also updates the Joined(x) label.
     */
    func updateJoinedView() {
        self.joinedLabel.text = "Joined (\(self.event!.getAttendees().count))";
        self.joinedImages = [UIImage?](count: self.event!.getAttendees().count, repeatedValue: nil);
        for i in 0 ..< self.joinedImages.count {
            let width = "150";
            let urlString = "https://graph.facebook.com/\(self.event!.getAttendees()[i])/picture?width=\(width)";
            let url = NSURL(string: urlString);
            //send request to get image
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { //TODO: fix some wierd thread thing
                (data, response, error) in
                //if data grabbed, updated image if in main thread
                if (data != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.joinedImages[i] = UIImage(data: data!);
                        self.joinedCollectionView.reloadData();
                    });
                }
            };
            task.resume();
        }
        self.joinedCollectionView.reloadData();
    }
    
    /*Comments----------------------------------------------------------------------------------------------*/
    /* 
     * Pulls array of comments, populates self.comments array, and reloads commentTableView.
     */
    func pullAndShowComments() {
        print("pulling and showing comments")
        Globals.fb.child("CommentDatabase").child(self.eventID!).child("comments").observeEventType(FIRDataEventType.Value, withBlock: {
            snapshot in
            print("comment refresh")
            let eventComments:[FIRDataSnapshot]? = snapshot.children.allObjects as? [FIRDataSnapshot];
            self.comments = []; //clear current list
            
            //only if comments exist
            if (eventComments != nil && eventComments!.count != 0) {
                //iterate through all snapshots and convert each .value -> dictionary -> comment and add to comments array
                for eachComment in eventComments!{
                    let comment = Comment.init(dictionary:eachComment.value as! [String:AnyObject])
                    if (!Globals.me.blockedUserIDs.contains(comment.getUserID())) {
                        self.comments.append(comment);
                    }
                    if (!self.commenters.contains(comment.getUserID())) {
                        self.commenters.append(comment.getUserID())
                    }
                }
                //display comments in tableview
                print("num comments: \(self.comments.count)");
                self.noCommentLabel.hidden = true;
            }
                
            //no comments so show no comments label
            else {
                self.noCommentLabel.hidden = false;
            }
            self.commentTableView.reloadData();
        });
    }
    
    /*
     * Uploads the text in self.commentWriteItem to Firebase. 
     */
    func writeComment() {
        //prevent users with more than 3 strikes fromc commenting and alert them
        if (Globals.me.getNumStrikes() < 3) {
            let commentText = (self.commentWriteItem.customView as! UITextField).text;
            if (!(commentText?.isEmpty)!) {
                let comment = Comment.init(comment: commentText!, userID: Globals.me.getUserID(), eventID: self.eventID!);
                
                
                comment.pushToFirebase();
    //            pullAndShowComments();
                
                // Build the NotificationCommentEvent
                let nce: Notification = NotificationCommentEvent(type: Globals.TYPE_COMMENT_EVENT, pictureID: Globals.me.getUserID(), eventID: eventID!, eventName: Globals.eventsIDToEvent[eventID!]!.getName(), userNames: [Globals.me.getUserName()])
                
                // The event creator should also receive the notification
                if (!commenters.contains(event!.getCreatorID())) {
                    commenters.append(event!.getCreatorID())
                }
                
                for attendee in event!.getAttendees() {
                    if (!commenters.contains(attendee)) {
                        commenters.append(attendee)
                    }
                }
                
                // You should not receive a Notification for your own comment
                if (commenters.contains(Globals.me.getUserID())) {
                    commenters.removeAtIndex(commenters.indexOf(Globals.me.getUserID())!)
                }
                
                // Send out the NotificiationCommentEvent
                nce.pushToFirebase(commenters)
                
                // Hide keyboard and clear textfield
                (self.commentWriteItem.customView as! UITextField).text = "";
                self.commentWriteItem.customView?.resignFirstResponder();
            }
            else {
                print("empty");
            }
        }
        else {
            let alert = UIAlertController(title: "Uh oh!",
                                          message: "Your events or comments have been reported too often, so you aren't allowed to write any comments anymore.", preferredStyle: .Alert);
            alert.addAction(UIAlertAction(title: "OK", style: .Default , handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
        }
    }
    
    //Shifts the view up when keyboard shows
    func keyboardWillShow(notifcation: NSNotification) {
        print("keyboard will show");
        if let keyboardSize = (notifcation.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let offset = notifcation.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size;
            //regular show
            if (keyboardSize.height == offset!.height) {
                self.view.frame.origin.y -= keyboardSize.height;
            }
            //when opening or closing assistive touch window
            else {
                self.view.frame.origin.y += keyboardSize.height - offset!.height;
            }
        }
    }
    
    //Shifts view back down when keyboard hides
    func keyboardWillHide(notifcation: NSNotification) {
        print("keyboard will hide");
//        if let keyboardSize = (notifcation.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
//            if (self.view.frame.origin.y != 0) {
//                self.view.frame.origin.y += keyboardSize.height;
//            }
//        }
        self.view.frame.origin.y = 0;
    }
    
    //Hides keyboard and unfocuses textfield when keyboard's Done button is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    /*---------------------------------------------------------------------------------------------------------*/
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {
//            (placemarks, error) -> Void in
//            if (error != nil) {
//                print("Geocoder error: " + error!.description)
//            }
//            else {
//                if placemarks!.count > 0 {
//                    let pm = placemarks![0] as CLPlacemark
//                    self.displayLocationInfo(pm)
//                }
//                else {
//                    print("Something wrong with data retrieved from geocoder")
//                }
//            }
//        })
//    }
//    
//    func displayLocationInfo(placemark:CLPlacemark) {
////        locationManager.stopUpdatingLocation()
//        print(placemark.name)
//    }
//    
//    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
//        print("Error when updating location: " + error.localizedDescription)
//    }
    
    
    
//    func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
//        print("bottom swipe");
//    }
    
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    
    /* Comment table data source and delegates ---------------------------------------*/
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.comments.count > 0) { //has comments
            return self.comments.count;
        }
        else { //no comments
            return 0;
        }
    }
    
    //cells only made if there are comments
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:CommentTableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? CommentTableViewCell;
        //if not registered yet, then register first
        if (cell == nil) {
            tableView.registerNib(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "Cell");
            cell = (tableView.dequeueReusableCellWithIdentifier("Cell") as! CommentTableViewCell);
        }
        
        let commentUserID = self.comments[indexPath.row].getUserID();
        
        //commentName from users database
        Globals.fb.child("Users").child(commentUserID).child("name").observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            cell!.commentName.text = String(snapshot.value!);
        });

        //comment text
        cell!.commentText.text = self.comments[indexPath.row].getComment();
        
        //commentImage
        let width = "150";
        let urlString = "https://graph.facebook.com/\(commentUserID)/picture?width=\(width)";
        let url = NSURL(string: urlString);
        //send request to get image
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) in
            //if data grabbed, update image in main thread
            if (data != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    cell!.commentImage.image = UIImage(data: data!);
                });
            }
        };
        task.resume();
    
        return cell!;
    }
    
    //auto-resizing of table view cells based on comment length
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80;
    }
    
    //set comment table height at each cell load
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.commentTableHeightConstraint.constant = self.commentTableView.contentSize.height;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("show report sheet");
        let reportAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet);
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            print("cancel");
        }
        reportAlertController.addAction(cancelAction);
        let reportEventAction = UIAlertAction(title: "Report comment", style: .Default) { (action) in
            self.comments[indexPath.row].addReporter(Globals.me.getUserID());
        }
        reportAlertController.addAction(reportEventAction);
        let blockUserAction = UIAlertAction(title: "Block user", style: .Default) { (action) in
            Globals.me.blockUser(self.comments[indexPath.row].getUserID())
        }
        reportAlertController.addAction(blockUserAction);
        dispatch_async(dispatch_get_main_queue()) { //wierd bug fix to make it present faster
            self.presentViewController(reportAlertController, animated: true, completion: nil);
        }
        print("showed");
    }
    
    /*--------------------------------------------------------------------------------*/
    
    
    
    /* Joined collection table data source and delegates -----------------------------*/
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.event != nil) {
            //set height of collection view based on number of images
            var height = (self.event!.getAttendees().count) / 5;
            if ((self.event!.getAttendees().count) % 5 != 0) {
                height += 1;
            }
            if (height > 0) {
                self.joinedCollectionViewHeightConstraint.constant = CGFloat(height*50 + (height-1)*10);
            } else {self.joinedCollectionViewHeightConstraint.constant = 0;}
            return (self.event!.getAttendees().count);
        }
        return 0;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! JoinedCell;
        cell.backgroundColor = UIColor.whiteColor();
        if (self.joinedImages[indexPath.item] != nil) {
            cell.imageView.image = self.joinedImages[indexPath.item];
        }
        return cell;
    }
    
    
    /*--------------------------------------------------------------------------------*/
    
    
    func setEventID(eventID: String) {
        self.eventID = eventID;
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "openInvite") {
            (segue.destinationViewController as! InviteViewController).setEventInfo(event!)
        }
    }
 

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