//
//  NotificationNewFollow.swift
//  project-18
//
//  Created by Isaac Wang on 7/13/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import FirebaseDatabase

/* Notification for when a user follows another user */
/* NO LONGER USED, FOLLOW SYSTEM ROLLED BACK */

class NotificationNewFollow: Notification {
    
    // Variables (unique to NewFollow)
    
    var followerID: String?
    var followerName: String?
    
    // NEW NOTIFICATION CONSTRUCTOR
    // - Sets all variables and generates new notifID
    init(type: Int, followerID: String, followerName: String) {
        
        // Superclass constructor
        super.init(type: type, pictureID: followerID)
        
        // Unique variables instantiation
        self.followerID = followerID
        self.followerName = followerName
    }
    
    // EXISTING NOTIFICATION CONSTRUCTOR
    // - Sets all variables (copies existing NotifID)
    init(notifDict: NSDictionary) {
        
        // Superclass constructor
        super.init(type: notifDict.valueForKey("type") as! Int, pictureID: notifDict.valueForKey("pictureId") as! String, notifID: notifDict.valueForKey("notifID") as! String)
        
        // Unique variables instantiation
        self.followerID = notifDict.valueForKey("followerId") as? String
        self.followerName = notifDict.valueForKey("followerName") as? String
        self.viewed = notifDict.valueForKey("viewed") as! Bool
    }
    
    // OVERRIDE SUPERCLASS METHODS ----------------------------------------------------------------------
    
    override func convertToDictionary(notif: Notification) -> NSDictionary {
        
        // Store unique variables
        let notifDict: NSMutableDictionary = ["followerId": (notif as! NotificationNewFollow).followerID!, "followerName": (notif as! NotificationNewFollow).followerName!]
        
        // Store common variables
        notifDict.addEntriesFromDictionary(super.convertToDictionary(notif) as [NSObject : AnyObject])
        
        return notifDict
    }
    
    override func hasConflict(userNotifs: FIRDataSnapshot) -> (FIRDataSnapshot, FIRDatabaseReference)? {
        
        // Iterate through the user's Notifications
        for notifSnap in userNotifs.children {
            let notifMap: NSDictionary = (notifSnap as! FIRDataSnapshot).value as! NSDictionary
            
            // Check Notification type
            if (notifMap.valueForKey("type") as! Int != Globals.TYPE_NEW_FOLLOW) {
                continue
            }
            
            // Check followerID
            let nnf: NotificationNewFollow =  NotificationNewFollow(notifDict: notifMap)
            if (nnf.followerID == self.followerID) {
                
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
        // TODO go to the profile of the user
        self.viewed = true
    }
    
    override func generateMessage() -> String {
        let firstName = followerName!.characters.split{$0 == " "}.map(String.init)[0]
        return firstName + " is now following you."
    }
    // --------------------------------------------------------------------------------------------------------

}