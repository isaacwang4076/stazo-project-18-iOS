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
    let NOTIF_ID_LEN = 10;          // Length of a notification's ID
    
    // Variables
    var notifID: String?            // ID of this notification
    var viewed: Bool = false        // Whether this notification has been viewed
    var type: Int?                  // The type of this notification
    var pictureID: String?          // A string value (usually a userID) that indicates what
                                    //   image should be displayed in the Notification screen.
    
    
    // NEW NOTIF INITIALIZATION
    // - Generates new notifID
    // - Sets common variables (type, pictureID)
    init(type: Int, pictureID: String) {
        generateNotifID()
        self.type = type;
        self.pictureID = pictureID
    }
    
    // EXISTING NOTIF INITIALIZATION
    // - Does not generate new notifID
    // - Sets common variables (notifID, type, pictureID)
    init(notifID: String, type: Int, pictureID: String) {
        self.notifID = notifID
        self.type = type;
        self.pictureID = pictureID
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
}

// INTERFACE FOR NOTIFICATIONS
// - "Abstract" methods for all notifications
// - Every notification will implement differently
protocol ActsLikeNotification {
    func onNotificationClicked()
    func generateMessage() -> String
    func hasConflict(userNotifs: FIRDataSnapshot) -> (FIRDataSnapshot, FIRDatabaseReference)?
    func handleConflict(snapToBase: (FIRDataSnapshot, FIRDatabaseReference)) -> Notification
}

