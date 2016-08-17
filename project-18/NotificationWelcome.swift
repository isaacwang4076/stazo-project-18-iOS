//
//  NotificationWelcome.swift
//  project-18
//
//  Created by Isaac Wang on 7/14/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import FirebaseDatabase

/* Notification for when you start using the app */

class NotificationWelcome: Notification {
    
    // Variables (unique to NewFollow)
    
    var userName: String?
    
    // NEW NOTIFICATION CONSTRUCTOR
    // - Sets all variables and generates new notifID
    init(type: Int, userName: String) {
        
        // Superclass constructor
        super.init(type: type, pictureID: "0")
        
        // Unique variables instantiation
        self.userName = userName
    }
    
    // EXISTING NOTIFICATION CONSTRUCTOR
    // - Sets all variables (copies existing NotifID)
    init(notifDict: NSDictionary) {
        
        // Superclass constructor
        super.init(type: notifDict.valueForKey("type") as! Int, pictureID: notifDict.valueForKey("pictureId") as! String, notifID: notifDict.valueForKey("notifID") as! String)
        
        // Unique variables instantiation
        self.userName = notifDict.valueForKey("name") as? String
        self.viewed = notifDict.valueForKey("viewed") as! Bool
    }
    
    // OVERRIDE SUPERCLASS METHODS ----------------------------------------------------------------------
    
    override func convertToDictionary(notif: Notification) -> NSDictionary {
        
        // Store unique variables
        let notifDict: NSMutableDictionary = ["name": (notif as! NotificationWelcome).userName!]
        
        // Store common variables
        notifDict.addEntriesFromDictionary(super.convertToDictionary(notif) as [NSObject : AnyObject])
        
        return notifDict
    }
    
    override func hasConflict(userNotifs: FIRDataSnapshot) -> (FIRDataSnapshot, FIRDatabaseReference)? {
    
        // No conflicts possible
        return nil
    }
    
    override func handleConflict(snapToBase: (FIRDataSnapshot, FIRDatabaseReference)) -> Notification? {
        
        // No conflicts possible
        return nil
    }
    
    // --------------------------------------------------------------------------------------------------------
    
    // IMPLEMENT PROTOCOL METHODS -----------------------------------------------------------------------------
    
    override func onNotificationClicked(controller: NotificationViewController, userID: String) {
        // TODO do something
        self.viewed = true
    }
    
    override func generateMessage() -> String {
        let firstName = userName!.characters.split{$0 == " "}.map(String.init)[0]
        return "Welcome to Campus, " + firstName + "!"
    }
    // --------------------------------------------------------------------------------------------------------
    
}