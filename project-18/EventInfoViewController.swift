//
//  EventInfoViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/18/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit
import FirebaseDatabase

//Current bug: only allow back button after transaction completes, if user goes super fast, it will crash

class EventInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {

    /* UI STUFF ----------------------------------------------------*/
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
                self.joinButton.backgroundColor = UIColor.redColor();
                Globals.me.attendEvent(self.event!.getEventID(), eventName: self.event!.getName(), creatorID: self.event!.getCreatorID());
                
                var newAttendees = self.event!.getAttendees();
                newAttendees.append(Globals.me.getUserID());
                self.event!.setAttendees(newAttendees);
                self.updateJoinedView();
            }
                
            //if user is now unjoined, change button UI, handle user unattend, and update joined view
            else {
                self.joinButton.setTitle("Join", forState: UIControlState.Normal);
                self.joinButton.backgroundColor = UIColor.yellowColor();
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
    
    /*--------------------------------------------------------------*/
    
    
    private var eventID:String? //will null check before pulling
    private var event:Event? //guarenteed non-null after pull
    private var comments:[Comment] = [] //list of comments
    private var userHasJoined:Bool = false;
    private var joinedImages:[UIImage?] = []; //images of ppl who joined to be show in joinedcollectionview
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (eventID != nil) {
            self.pullAndShowEvent(); //TODO:Hide or set everything to initial state before showing with info
            self.pullAndShowComments();
        }
        else {
            print("Event ID is null, WHY IS IT NULL");
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
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(EventInfoViewController.respondToSwipeGesture(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
//        swipeDown.delegate = self;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.navigationBarHidden = false;
        self.title = "Event Info";
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
            self.event = Event.init(eventDict: snapshot.value as! NSDictionary);
            
            //update the view with event info -------------------------------------
            //NAME
            self.eventNameLabel.text = self.event!.getName();
            
            //update joined bool, joined button, joined label, joined collection view
            self.userHasJoined = (self.event!.getAttendees().contains(Globals.me.getUserID()));
            self.updateJoinedView();
            if (self.userHasJoined) {
                self.joinButton.setTitle("Joined", forState: UIControlState.Normal);
                self.joinButton.backgroundColor = UIColor.redColor();
            }
            else {
                self.joinButton.setTitle("Join", forState: UIControlState.Normal);
                self.joinButton.backgroundColor = UIColor.yellowColor();
            }
            
            //START DATE    TODO: edit Starts vs started label
            let date = NSDate(timeIntervalSince1970: NSTimeInterval(self.event!.getStartTime())/1000);
            self.startTimeLabel.text = stringFromDate(date);
            
            //LENGTH/ENDS IN   TODO: edit the length/ends in label
            let currentTime = Int(NSDate().timeIntervalSince1970 * 1000);
            //if event hasn't started yet, show event length
            if (currentTime < Int(self.event!.getStartTime())) {
                self.lengthPreLabel.text = "Length";
                let startText = durationFromTimeIntervals(startTime: Int(self.event!.getStartTime()),
                    endTime: Int(self.event!.getEndTime()))
                self.lengthLabel.text = startText;
            }
            //event has started, so show how long until end
            else {
                self.lengthPreLabel.text = "Ends in";
                var endText = durationFromTimeIntervals(startTime: currentTime,
                    endTime: Int(self.event!.getEndTime()))
                if (endText.isEmpty) {
                    endText = "Just ended"
                }
                self.lengthLabel.text = endText;
            }
            
            //LOCATION
            self.locationLabel.text = "\(self.event!.getLocation().latitude), \(self.event!.getLocation().longitude)";
            
            //DESCRIPTION with auto-resize to fit text
            self.descriptionLabel.text = self.event!.getDescription();
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
    
    /* 
     * Pulls array of comments, populates self.comments array, and reloads commentTableView.
     */
    func pullAndShowComments() {
        Globals.fb.child("CommentDatabase").child(self.eventID!).child("comments").observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            let eventComments:[FIRDataSnapshot]? = snapshot.children.allObjects as? [FIRDataSnapshot];
            self.comments = []; //clear current list
            
            //only if comments exist
            if (eventComments != nil && eventComments!.count != 0) {
                //iterate through all snapshots and convert each .value -> dictionary -> comment and add to comments array
                for eachComment in eventComments!{
                    self.comments.append(Comment.init(dictionary:eachComment.value as! [String:AnyObject]));
                }
                //display comments in tableview
                print("num comments: \(self.comments.count)");
                self.noCommentLabel.hidden = true;
                self.commentTableView.reloadData();
            }
                
            //no comments so show no comments label
            else {
                self.noCommentLabel.hidden = false;
            }
        });
    }
    
    /*
     * Uploads the text in self.commentWriteItem to Firebase. 
     */
    func writeComment() {
        let commentText = (self.commentWriteItem.customView as! UITextField).text;
        if (!(commentText?.isEmpty)!) {
            let comment = Comment.init(comment: commentText!, userID: Globals.me.getUserID(), eventID: self.eventID!);
            comment.pushToFirebase();
            pullAndShowComments();
            //Hide keyboard and clear textfield
            (self.commentWriteItem.customView as! UITextField).text = "";
            self.commentWriteItem.customView?.resignFirstResponder();
        }
        else {
            print("empty");
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
    
    
    
    func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        print("bottom swipe");
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        if ((self.navigationController) != nil) {
            self.navigationController?.navigationBarHidden = true;
        }
    }
    
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
        
        let commentUserID = self.comments[indexPath.item].getUserID();
        
        //commentName from users database
        Globals.fb.child("Users").child(commentUserID).child("name").observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            cell!.commentName.text = String(snapshot.value!);
        });

        //comment text
        cell!.commentText.text = self.comments[indexPath.item].getComment();
        
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