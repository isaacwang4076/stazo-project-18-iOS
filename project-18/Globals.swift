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
    static var eventsNameToID: Dictionary<String, String> = [:] // HashMap from event name to event id (used for search on Map)
    static var eventsIDToEvent: Dictionary<String, Event> = [:] // HashMap from event id to Event (used for grabbing events)
    static var friendsNameToID: Dictionary<String, String> = [:] // HashMap from friend name to friend userID (used for search on Invite)
    
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

// GLOBAL FUNCTIONS

func populateCell(cell: EventTableViewCell, eventToShow: Event) {
    
    cell.eventName.text = eventToShow.getName();
    cell.numGoing.text = "\(eventToShow.getPopularity())";
    
    //start date TODO:correct date formatting? I think the android one is inconsistent
    let date = NSDate(timeIntervalSince1970: NSTimeInterval(eventToShow.getStartTime())/1000);
    let formatter = NSDateFormatter();
    formatter.dateFormat = "MMM dd HH:mm a";
    let startTimeString = formatter.stringFromDate(date);
    //substringing to add "at"
    cell.eventTime.text = startTimeString.substringToIndex(startTimeString.startIndex.advancedBy(6)) + " at" + (startTimeString.substringFromIndex(startTimeString.startIndex.advancedBy(6)));
}

func stringFromDate(date: NSDate) -> String{ //TODO: Add today check and maybe tomorrow check?
    let formatter = NSDateFormatter();
    formatter.dateFormat = "MMM dd HH:mm a";
    let startTimeString = formatter.stringFromDate(date);
    //substringing to add "at"
    return startTimeString.substringToIndex(startTimeString.startIndex.advancedBy(6)) + " at" + (startTimeString.substringFromIndex(startTimeString.startIndex.advancedBy(6)));
}
