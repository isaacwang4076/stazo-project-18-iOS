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
    
    // Notification types
    let TYPE_COMMENT_EVENT: Int = 0
    let TYPE_FRIEND_HOST: Int = 1
    let TYPE_NEW_FOLLOW: Int = 2
    let TYPE_JOINED_EVENT: Int = 3
    let TYPE_INVITE_EVENT: Int = 4
    let TYPE_WELCOME: Int = 5
}
