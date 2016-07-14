//
//  NotificationNewFollow.swift
//  project-18
//
//  Created by Isaac Wang on 7/13/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NotificationNewFollow: Notification, ActsLikeNotification {
    
    // Variables (unique to NewFollow)
    var followerName: String?
    var followerID: String?
    
    // NEW NOTIFICATION CONSTRUCTOR
    init(type: Int, followerName: String, followerID: String) {
        
        // Superclass constructor
        super.init(type: type, pictureID: followerID)
        
        // Unique variables instantiation
        self.followerName = followerName
        self.followerID = followerID
    }
    
    // TODO EXISTING NOTIFICATION CONSTRUCTOR
    
    // IMPLEMENT PROTOCOL METHODS
    
    func onNotificationClicked() {}
    
    func generateMessage() -> String {
        return ""
    }
    
    func hasConflict(userNotifs: FIRDataSnapshot) -> (FIRDataSnapshot, FIRDatabaseReference)? {
        return nil
    }
    
    func handleConflict(snapToBase: (FIRDataSnapshot, FIRDatabaseReference)) -> Notification {
        return self
    }
}