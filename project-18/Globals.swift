//
//  Globals.swift
//  project-18
//
//  Created by Isaac Wang on 7/11/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct Globals {
    static let fb = FIRDatabase.database().reference()    // Reference to the database
    static let eventFirebaseKeys = ["name", "description", "creator_id", "endTime", "event_id", "popularity", "reports", "startTime"]
    
    // Notification types
    static let TYPE_COMMENT_EVENT: Int = 0
    static let TYPE_FRIEND_HOST: Int = 1
    static let TYPE_NEW_FOLLOW: Int = 2
    static let TYPE_JOINED_EVENT: Int = 3
    static let TYPE_INVITE_EVENT: Int = 4
    static let TYPE_WELCOME: Int = 5
    
    //FB Token FROM LAST SESSION
    static var lastFBToken = FBSDKAccessToken.currentAccessToken();
    
    //Current user, will crash if null, but should always be non-null after login screen
    static var me:User = User(userID: "69", userName: "eric");
//        NSKeyedUnarchiver.unarchiveObjectWithData(
//        NSUserDefaults.standardUserDefaults().objectForKey("CurrentUser") as! NSData
//    ) as! User;
//    
}
