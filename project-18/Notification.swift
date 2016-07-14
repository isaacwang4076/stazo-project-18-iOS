//
//  Notification.swift
//  project-18
//
//  Created by Isaac Wang on 7/13/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import FirebaseDatabase

// Super class for all Notifications
// - For each user who is notified of something,
//   a copy of the same notification is sent to
//   that user's Notifications.

class Notification {
    
    // Constants
    let fb = Globals.fb             // Reference to the app's database
    let NOTIF_ID_LEN = 10;          // Length of a notification's ID
    
    // Common Variables (All types of Notifications have these)
    var notifID: String?            // ID of this notification
    var viewed: Bool = false        // Whether this notification has been viewed
    var type: Int?                  // The type of this notification
    var pictureID: String?          //A string value (usually a userID) that indicates what
                                    //   image should be displayed in the Notification screen.
    
    
    // NEW NOTIF INITIALIZATION
    // - Generates new notifID
    // - Sets common variables (type, pictureID)
    init(type: Int, pictureID: String) {
        self.type = type;
        self.pictureID = pictureID
        generateNotifID()
    }
    
    // EXISTING NOTIF INITIALIZATION
    // - Does not generate new notifID
    // - Sets common variables (type, pictureID, notifID)
    init(type: Int, pictureID: String, notifID: String) {
        self.type = type;
        self.pictureID = pictureID
        self.notifID = notifID
    }
    
    // NOTIF ID GENERATION
    // - Creates an ID for this notification
    // - Will be unique within each user's Notifications,
    //   though the same notification can exist in more
    //   than one user's Notifications
    func generateNotifID() {
        let allowedChars = "abcdefghijklmnopqrstuvwxyz"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var newID = ""
        
        for _ in (0..<NOTIF_ID_LEN) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            newID += String(newCharacter)
        }
        notifID = newID
    }
    
    // TODO pushToFirebase
    func pushToFirebase(usersWhoCare: [String]) {
        for id in usersWhoCare {
            fb.child("NotifDatabase").child(id).observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (userNotifs) in
                let stb = self.hasConflict(userNotifs)
                
                // Conflict case
                // - Means this Notification should be combined
                //   with an already existing Notification in 
                //   the user's NotifDatabase
                if (stb != nil) {
                    print("/npushToFirebase in Notification: Notification with ID ", self.notifID, " reached conflict")
                    if let resolved: Notification = self.handleConflict(stb!) {
                        print("/npushToFirebase in Notification: resolved conflict and pushing Notification with ID ", self.notifID)
                        self.fb.child("NotifDatabase").child(id).childByAutoId().setValue(self.convertToDictionary(resolved))
                    }
                }
                // No conflict case
                else {
                    // Simply add this notification as you would expect
                    print("/npushToFirebase in Notification: pushing Notification with ID ", self.notifID, " without conflict")
                    self.fb.child("NotifDatabase").child(id).childByAutoId().setValue(self.convertToDictionary(self))
                }
            })
        }
    }
    
    // CONVERT TO DICTIONARY
    // - Helper function for pushToFirebase (either self or resolved conflict)
    // - Converts given Notification into Dictionary form
    // - Will be Overriden by all subclasses to include additional variables,
    //   however they will all implement the superclass's version as well
    //   to append the common variables
    func convertToDictionary(notif: Notification) -> NSDictionary {
        return ["notifID": notifID!, "viewed": viewed, "type": type!, "pictureId": pictureID!]
    }
    
    // "ABSTRACT" METHODS, ALL SUB-CLASSES SHOULD OVERRIDE --------------------------------s
    // - Included in this class and not in protocol because
    //   they are needed for the pushToFirebase() function
    
    // FIND CONFLICT
    // - Given a reference to a user's Notifications,
    //   determines whether there is a conflict with this
    //   one (meaning this Notification should be combined 
    //   with an already existing Notification
    // - Returns nil if there is no conflict
    // - Returns a Tuple containing a Snapshot of the conflicting
    //   Notification, as well as a reference to its location in
    //   the user's Notifications
    func hasConflict(userNotifs: FIRDataSnapshot) -> (FIRDataSnapshot, FIRDatabaseReference)? {return nil}
    
    // HANDLE CONFLICT
    // - Given a Snapshot of a conflicting Notification and
    //   a reference to its location in a user's Notification,
    //   resolves the conflict (varies depending on type)
    // - If the type is conflict-sensitive, will remove the
    //   previously existing Notification and return a new
    //   combined Notification. For example, instead of getting
    //   100 Notifications for each of the 100 users who commented
    //   on your event, you'll instead get one Notification that
    //   100 users commented on your event.
    // - If the type is not conflict-sensitive, simply returns
    //   null (meaning pushToFirebase will do nothing). This
    //   removes potential spam of follow/unfollow or join/unjoin
    //   by one user clogging another user's Notifications
    func handleConflict(snapToBase: (FIRDataSnapshot, FIRDatabaseReference)) -> Notification? {return nil}
    
    
    // ------------------------------------------------------------------------------------

}

// INTERFACE FOR NOTIFICATIONS
// - More "abstract" methods for all notifications
// - Every notification will implement differently
protocol ActsLikeNotification {
    
    // HANDLE CLICK
    // - Defines what happens when the user taps the
    //   Notification in the Notifications View
    func onNotificationClicked()
    
    // GENERATE MESSAGE
    // - Defines what message will be displayed for
    //   this Notificaiton in the Notificaitons View
    func generateMessage() -> String
}

