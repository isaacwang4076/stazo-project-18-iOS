//
//  NotificationInviteEvent.swift
//  project-18
//
//  Created by Isaac Wang on 7/14/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import FirebaseDatabase

/* Notification for when a user is invited to an event (almost identical to NotificationCommentEvent) */

class NotificationInviteEvent: Notification {
    
    // Variables (unique to InviteEvent)
    
    var eventID: String?
    var eventName: String?
    var userNames: [String]?
    
    // NEW NOTIFICATION CONSTRUCTOR
    // - Sets all variables and generates new notifID
    init(type: Int, pictureID: String, eventID: String, eventName: String, userNames: [String]) {
        
        // Superclass constructor
        super.init(type: type, pictureID: pictureID)
        
        // Unique variables instantiation
        self.eventID = eventID
        self.eventName = eventName
        self.userNames = userNames
    }
    
    // EXISTING NOTIFICATION CONSTRUCTOR
    // - Sets all variables (copies existing NotifID)
    init(notifDict: NSDictionary) {
        
        // Superclass constructor
        super.init(type: notifDict.valueForKey("type") as! Int, pictureID: notifDict.valueForKey("pictureId") as! String, notifID: notifDict.valueForKey("notifID") as! String)
        
        // Unique variables instantiation
        self.eventID = notifDict.valueForKey("eventId") as? String
        self.eventName = notifDict.valueForKey("eventName") as? String
        self.userNames = notifDict.valueForKey("userNames") as? [String]
        self.viewed = notifDict.valueForKey("viewed") as! Bool
    }
    
    // OVERRIDE SUPERCLASS METHODS ----------------------------------------------------------------------
    
    
    override func convertToDictionary(notif: Notification) -> NSDictionary {
        
        // Store unique variables
        let notifDict: NSMutableDictionary = ["eventId": (notif as! NotificationInviteEvent).eventID!, "eventName": (notif as! NotificationInviteEvent).eventName!, "userNames": (notif as! NotificationInviteEvent).userNames!]
        
        // Store common variables
        notifDict.addEntriesFromDictionary(super.convertToDictionary(notif) as [NSObject : AnyObject])
        
        return notifDict
    }
    
    override func hasConflict(userNotifs: FIRDataSnapshot) -> (FIRDataSnapshot, FIRDatabaseReference)? {
        
        // Iterate through the user's Notifications
        for notifSnap in userNotifs.children {
            let notifMap: NSDictionary = (notifSnap as! FIRDataSnapshot).value as! NSDictionary
            
            // Check Notification type
            if (notifMap.valueForKey("type") as! Int != Globals.TYPE_INVITE_EVENT) {
                continue
            }
            
            // Check eventID
            let nie: NotificationInviteEvent =  NotificationInviteEvent(notifDict: notifMap)
            if (nie.eventID == self.eventID) {
                
                // Conflict found
                return (notifSnap as! FIRDataSnapshot, notifSnap.ref)
            }
        }
        
        // No conflicts found
        return nil
    }
    
    override func handleConflict(snapToBase: (FIRDataSnapshot, FIRDatabaseReference)) -> Notification? {
        
        // Get a copy of the old Notification
        let conflictNotif: NotificationInviteEvent = NotificationInviteEvent(notifDict: snapToBase.0.value as! NSDictionary)
        
        // Update the new Notification (this one) by appending the old userNames
        for name in conflictNotif.userNames! {
            if (userNames?.contains(name) == false) {
                userNames?.append(name)
            }
        }
        
        // Remove the old conflicting Notification
        snapToBase.1.setValue(nil)
        
        // Do nothing in the case of a conflict
        return self
    }
    
    // --------------------------------------------------------------------------------------------------------
    
    // IMPLEMENT PROTOCOL METHODS -----------------------------------------------------------------------------
    
    override func onNotificationClicked(controller: NotificationViewController, userID: String) {
        
        // Set the local Notification to viewed
        self.viewed = true
        
        // Set the Notification on the database to viewed
        setToViewed(userID)
        
        // Navigate to EventInfo for event
        controller.selectedEventID = eventID
        controller.performSegueWithIdentifier("openEventInfo", sender: controller);
    }
    
    override func generateMessage() -> String {
        var message = userNames![0].characters.split{$0 == " "}.map(String.init)[0]
        if (userNames?.endIndex > 1) {
            message += " and " + String(userNames!.endIndex - 1) + " other"  // e.g. James and 1 other
        }
        if (userNames?.endIndex > 2) {
            message += "s"                                                   // e.g. James and 2 others
        }
        message += " invited you to \"" + eventName! + "\"."                 // e.g. James and 2 others invited you to "Bake Sale".
        return message
    }
    // --------------------------------------------------------------------------------------------------------
    
}