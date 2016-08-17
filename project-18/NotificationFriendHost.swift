//
//  NotificationFriendHost.swift
//  project-18
//
//  Created by Isaac Wang on 7/14/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import FirebaseDatabase

/* Notification for when a user you are following is hosting an event */

class NotificationFriendHost: Notification {
    
    // Variables (unique to NewFollow)
    
    var hostName: String?
    var eventID: String?
    var eventName: String?
    var timeString: String?
    
    // NEW NOTIFICATION CONSTRUCTOR
    // - Sets all variables and generates new notifID
    init(type: Int, pictureID: String, hostName: String, eventID: String, eventName: String, timeString: String) {
        
        // Superclass constructor
        super.init(type: type, pictureID: pictureID)
        
        // Unique variables instantiation
        self.hostName = hostName
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
        self.hostName = notifDict.valueForKey("hostName") as? String
        self.eventID = notifDict.valueForKey("eventId") as? String
        self.eventName = notifDict.valueForKey("eventName") as? String
        self.timeString = notifDict.valueForKey("timeString") as? String
        self.viewed = notifDict.valueForKey("viewed") as! Bool
    }
    
    // OVERRIDE SUPERCLASS METHODS ----------------------------------------------------------------------
    
    
    override func convertToDictionary(notif: Notification) -> NSDictionary {
        
        // Store unique variables
        let notifDict: NSMutableDictionary = ["hostName": (notif as! NotificationFriendHost).hostName!, "eventId": (notif as! NotificationFriendHost).eventID!, "eventName": (notif as! NotificationFriendHost).eventName!, "timeString": (notif as! NotificationFriendHost).timeString!]
        
        // Store common variables
        notifDict.addEntriesFromDictionary(super.convertToDictionary(notif) as [NSObject : AnyObject])
        
        return notifDict
    }
    
    override func hasConflict(userNotifs: FIRDataSnapshot) -> (FIRDataSnapshot, FIRDatabaseReference)? {
        
        // No conflict possible
        return nil
    }
    
    override func handleConflict(snapToBase: (FIRDataSnapshot, FIRDatabaseReference)) -> Notification? {
        
        // No conflict possible
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
        let firstName = hostName!.characters.split{$0 == " "}.map(String.init)[0]
        return firstName + " is hosting " + eventName! + " " + timeString! + "."
    }
    // --------------------------------------------------------------------------------------------------------
    
}