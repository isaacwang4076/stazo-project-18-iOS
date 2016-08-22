//
//  NotificationViewController.swift
//  project-18
//
//  Created by Isaac Wang on 8/5/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class NotificationViewController: UIViewController {
    
    let fb = Globals.fb
    
    var notifs: [Notification] = [Notification]()
    var selectedEventID: String?
    
    @IBOutlet var notificationTableView: UITableView!
    @IBOutlet var notificationTableViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the navigation bar (included for back-navigation on segue to EventInfo)
        self.navigationController?.navigationBarHidden = true;
        
        self.notificationTableView.registerNib(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell");
        
        pullAndDisplayNotifications()
    }
    
    func pullAndDisplayNotifications() {
        
        // PULL: Store all the user's Notifications in the notifs array
        fb.child("NotifDatabase").child("1196215920412322").observeSingleEventOfType(FIRDataEventType.Value, withBlock: {
            (userNotifs) in
            for notifSnapshot in userNotifs.children {
                var notif: Notification? = nil
                let notifDict:NSDictionary = (notifSnapshot as! FIRDataSnapshot).value as! NSDictionary
                
                if notifDict.valueForKey("type") as! Int == Globals.TYPE_NEW_FOLLOW {
                    notif = NotificationNewFollow(notifDict: notifDict)
                }
                else if notifDict.valueForKey("type") as! Int == Globals.TYPE_COMMENT_EVENT {
                    notif = NotificationCommentEvent(notifDict: notifDict)
                }
                else if notifDict.valueForKey("type") as! Int == Globals.TYPE_FRIEND_HOST {
                    notif = NotificationFriendHost(notifDict: notifDict)
                }
                else if notifDict.valueForKey("type") as! Int == Globals.TYPE_JOINED_EVENT {
                    notif = NotificationJoinedEvent(notifDict: notifDict)
                }
                else if notifDict.valueForKey("type") as! Int == Globals.TYPE_INVITE_EVENT {
                    notif = NotificationInviteEvent(notifDict: notifDict)
                }
                else if notifDict.valueForKey("type") as! Int == Globals.TYPE_WELCOME {
                    notif = NotificationWelcome(notifDict: notifDict)
                }
                
                self.notifs.append(notif!)

            }
            
            // DISPLAY: Once all the Notifications have been pulled, reload the table view
            self.notificationTableView.reloadData()
        })
        
    }
    
    // TABLE VIEW ------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.notificationTableViewHeightConstraint.constant = CGFloat(self.notifs.count * 80);
        
        // Return number of notifications
        print("\n", self.notifs.count, " Notifications counted.")
        return self.notifs.count;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Only one section
        return 1
    }
    
    // CELL CREATION
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Create cell
        let cell:NotificationTableViewCell = tableView.dequeueReusableCellWithIdentifier("NotificationCell", forIndexPath: indexPath) as! NotificationTableViewCell;
        
        // Grab Event to base cell off of
        let notifToShow:Notification = notifs[indexPath.row]
        
        // Populate cell based on the Event's info
        populateCell(cell, notifToShow: notifToShow)
        
        return cell
    }
    
    func populateCell(cell: NotificationTableViewCell, notifToShow: Notification) {
        cell.message.text = notifToShow.generateMessage()
        
        //NOTIF IMAGE with URL request
        let width = "250";
        let urlString = "https://graph.facebook.com/" + notifToShow.pictureID!
            + "/picture?width=" + width;
        let url = NSURL(string: urlString);
        //send request to get image
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) in
            //if data grabbed, update image in main thread
            if (data != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    cell.notifImage.image = UIImage(data: data!)?.rounded;
                });
            }
        };
        task.resume();
    }
    
    
    // HANDLE CELL CLICK
    // - Go to corresponding event info page
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.selectedEventID = Globals.eventsNameToID[self.filteredEventNames[indexPath.row]];
        notifs[indexPath.row].onNotificationClicked(self, userID: Globals.me.getUserID())
    }
    
    // -----------------------------------------------------------------------------------------------
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //if it's the eventinfo segue, set the event id
        if (segue.identifier == "openEventInfo") {
            (segue.destinationViewController as! EventInfoViewController).hidesBottomBarWhenPushed = true;
            (segue.destinationViewController as! EventInfoViewController).setEventID(self.selectedEventID!);
        }
    }
    
}