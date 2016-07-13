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
}
