//
//  NotificationEventToday.swift
//  project-18
//
//  Created by Isaac Wang on 9/7/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import FirebaseDatabase

/* Notification for when an event is happening today */

class NotificationEventToday: Notification {
    
    // Variables (unique to NewFollow)
    
    var eventID: String?
    var eventName: String?
    var timeString: String?
    
    // NEW NOTIFICATION CONSTRUCTOR
    // - Sets all variables and generates new notifID
    init(type: Int, pictureID: String, timeString: String, eventID: String, eventName: String) {
        
        // Superclass constructor
        super.init(type: type, pictureID: pictureID)
        
        // Unique variables instantiation
        self.eventID = eventID
        self.eventName = eventName
        self.timeString = timeString
    }
    
    // EXISTING NOTIFICATION CONSTRUCTOR
    // - Sets all variables (copies existing NotifID)
    init(notifDict: NSDictionary) {
        
        // Superclass constructor
        super.init(type: notifDict.valueForKey("type") as! Int, pictureID: notifDict.valueForKey("pictureId") as! String, notifID: notifDict.valueForKey("notifID") as! String)
        
        // Unique variables instantiation
        self.eventID = notifDict.valueForKey("eventId") as? String
        self.eventName = notifDict.valueForKey("eventName") as? String
        self.timeString = notifDict.valueForKey("timeString") as? String
        self.viewed = notifDict.valueForKey("viewed") as! Bool
    }
    
    // OVERRIDE SUPERCLASS METHODS ----------------------------------------------------------------------
    
    override func convertToDictionary(notif: Notification) -> NSDictionary {
        
        // Store unique variables
        let notifDict: NSMutableDictionary = ["eventId": (notif as! NotificationEventToday).eventID!, "eventName": (notif as! NotificationEventToday).eventName!, "timeString": (notif as! NotificationEventToday).timeString!]
        
        // Store common variables
        notifDict.addEntriesFromDictionary(super.convertToDictionary(notif) as [NSObject : AnyObject])
        
        return notifDict
    }
    
    override func hasConflict(userNotifs: FIRDataSnapshot) -> (FIRDataSnapshot, FIRDatabaseReference)? {
        
        // Iterate through the user's Notifications
        for notifSnap in userNotifs.children {
            let notifMap: NSDictionary = (notifSnap as! FIRDataSnapshot).value as! NSDictionary
            
            // Check Notification type
            if (notifMap.valueForKey("type") as! Int != Globals.TYPE_EVENT_TODAY) {
                continue
            }
            
            // Check followerID
            let net: NotificationEventToday =  NotificationEventToday(notifDict: notifMap)
            if (net.eventID == self.eventID) {
                
                // Conflict found
                return (notifSnap as! FIRDataSnapshot, notifSnap.ref)
            }
        }
        
        // No conflicts found
        return nil
    }
    
    override func handleConflict(snapToBase: (FIRDataSnapshot, FIRDatabaseReference)) -> Notification? {
        // Not conflict-accepting -> do nothing in the case of a conflict
        return nil
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
        return eventName! + " is happening at " + timeString!
    }
    // --------------------------------------------------------------------------------------------------------
    
}