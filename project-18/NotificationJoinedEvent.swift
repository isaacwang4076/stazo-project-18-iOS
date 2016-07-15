//
//  NotificationJoinedEvent.swift
//  project-18
//
//  Created by Isaac Wang on 7/14/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import FirebaseDatabase

/* Notification for when a user joins your event */

class NotificationJoinedEvent: Notification {
    
    // Variables (unique to NewFollow)
    
    var joinedUserName: String?
    var eventID: String?
    var eventName: String?
    
    // NEW NOTIFICATION CONSTRUCTOR
    // - Sets all variables and generates new notifID
    init(type: Int, pictureID: String, joinedUserName: String, eventID: String, eventName: String) {
        
        // Superclass constructor
        super.init(type: type, pictureID: pictureID)
        
        // Unique variables instantiation
        self.joinedUserName = joinedUserName
        self.eventID = eventID
        self.eventName = eventName
    }
    
    // EXISTING NOTIFICATION CONSTRUCTOR
    // - Sets all variables (copies existing NotifID)
    init(notifDict: NSDictionary) {
        
        // Superclass constructor
        super.init(type: notifDict.valueForKey("type") as! Int, pictureID: notifDict.valueForKey("pictureId") as! String, notifID: notifDict.valueForKey("notifID") as! String)
        
        // Unique variables instantiation
        self.joinedUserName = notifDict.valueForKey("joinedUserName") as? String
        self.eventID = notifDict.valueForKey("eventId") as? String
        self.eventName = notifDict.valueForKey("eventName") as? String
        self.viewed = notifDict.valueForKey("viewed") as! Bool
    }
    
    // OVERRIDE SUPERCLASS METHODS ----------------------------------------------------------------------
    
    override func convertToDictionary(notif: Notification) -> NSDictionary {
        
        // Store unique variables
        let notifDict: NSMutableDictionary = ["joinedUserName": (notif as! NotificationJoinedEvent).joinedUserName!, "eventId": (notif as! NotificationJoinedEvent).eventID!, "eventName": (notif as! NotificationJoinedEvent).eventName!]
        
        // Store common variables
        notifDict.addEntriesFromDictionary(super.convertToDictionary(notif) as [NSObject : AnyObject])
        
        return notifDict
    }
    
    override func hasConflict(userNotifs: FIRDataSnapshot) -> (FIRDataSnapshot, FIRDatabaseReference)? {
        
        // Iterate through the user's Notifications
        for notifSnap in userNotifs.children {
            let notifMap: NSDictionary = (notifSnap as! FIRDataSnapshot).value as! NSDictionary
            
            // Check Notification type
            if (notifMap.valueForKey("type") as! Int != Globals.TYPE_JOINED_EVENT) {
                continue
            }
            
            // Check followerID
            let nje: NotificationJoinedEvent =  NotificationJoinedEvent(notifDict: notifMap)
            if (nje.eventID == self.eventID) {
                
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
    
    override func onNotificationClicked() {
        // TODO go to event info for event with id eventID
        self.viewed = true
    }
    
    override func generateMessage() -> String {
        let firstName = joinedUserName!.characters.split{$0 == " "}.map(String.init)[0]
        return firstName + " joined your event: \"" + eventName! + "\"."
    }
    // --------------------------------------------------------------------------------------------------------
    
}