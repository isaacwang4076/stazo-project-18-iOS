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
    static var friendsIDToName: Dictionary<String, String> = [:] // HashMap from friend name to friend userID (used for search on Invite)
    
    // Notification types
    static let TYPE_COMMENT_EVENT: Int = 0
    static let TYPE_FRIEND_HOST: Int = 1
    static let TYPE_NEW_FOLLOW: Int = 2
    static let TYPE_JOINED_EVENT: Int = 3
    static let TYPE_INVITE_EVENT: Int = 4
    static let TYPE_WELCOME: Int = 5
    
    // FB Token FROM LAST SESSION
    static var lastFBToken = FBSDKAccessToken.currentAccessToken();
    
    // Current user, will crash if null, but should always be non-null after login screen
    static var me:User = User(userID: "69", userName: "eric");
//        NSKeyedUnarchiver.unarchiveObjectWithData(
//        NSUserDefaults.standardUserDefaults().objectForKey("CurrentUser") as! NSData
//    ) as! User;
//    
    
    // COLORS
    
    // BASE
    /*<color name="colorTextPrimary">#212121</color>
    <color name="colorTextSecondary">#727272</color>
    <color name="colorDivider">#B6B6B6</color>
    <color name="colorDividerLight">#e6e6e6</color>
    <color name="colorDividerExtraLight">#f2f2f2</color>
    <color name="colorDividerDark">#999999</color>(
    <color name="colorNewNotification">#E1F5FE</color>*/
    
    // TEMPLATE
    
    static let COLOR_PRIMARY = UIColor(netHex:0x0288D1)
    static let COLOR_PRIMARY_DARK = UIColor(netHex:0x01579B)
    static let COLOR_PRIMARY_LIGHT = UIColor(netHex:0x03A9F4)
    static let COLOR_ACCENT = UIColor(netHex:0xFFEB3B)
    static let COLOR_ACCENT_DARK = UIColor(netHex:0xFBC02D)
    
    static let COLOR_NEW_NOTIF = UIColor(netHex: 0xE1F5FE)
    static let COLOR_UNSELECTED_CELL = UIColor.whiteColor()
    static let COLOR_SELECTED_CELL = COLOR_ACCENT
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

func populateCell(cell: UserTableViewCell, userID: String, isSelected: Bool) {
    
    cell.userName.text = Globals.friendsIDToName[userID]!
    if (isSelected) {
        cell.backgroundColor = Globals.COLOR_SELECTED_CELL
    } else {
        cell.backgroundColor = Globals.COLOR_UNSELECTED_CELL
    }
    
    // FRIEND IMAGE with URL request
    let width = "250";
    let urlString = "https://graph.facebook.com/" + userID
        + "/picture?width=" + width;
    let url = NSURL(string: urlString);
    //send request to get image
    let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
        (data, response, error) in
        //if data grabbed, update image in main thread
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), {
                cell.userImage.image = UIImage(data: data!)?.rounded;
            });
        }
    };
    task.resume();
    
}

func stringFromDate(date: NSDate) -> String{ //TODO: Add today check and maybe tomorrow check?
    let formatter = NSDateFormatter();
    formatter.dateFormat = "MMM dd HH:mm a";
    let startTimeString = formatter.stringFromDate(date);
    //substringing to add "at"
    return startTimeString.substringToIndex(startTimeString.startIndex.advancedBy(6)) + " at" + (startTimeString.substringFromIndex(startTimeString.startIndex.advancedBy(6)));
}

func durationFromTimeIntervals(startTime startTime: Int, endTime: Int) -> String{
    let length:Int = endTime - startTime
    let eventHour = length/(1000*60*60)
    let eventMin = length/(1000*60) - eventHour*60
    
    var finalString = "";
    if (eventHour > 0) {
        finalString += "\(eventHour)"
        if (eventHour == 1) {
            finalString += " hr"
        }
        else {
            finalString += " hrs"
        }
        if (eventMin > 0) {
            finalString += " and "
        }
    }
    if (eventMin > 0) {
        if (eventMin == 1) {
            finalString += "\(eventMin)"
            finalString += " min"
        }
        else {
            finalString += "\(eventMin)"
            finalString += " mins"
        }
    }
    return finalString
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
