//
//  User.swift
//  project-18
//
//  Created by Isaac Wang on 7/11/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation

class User {
    
    // Constants
    let fb = Globals.fb
    let DEFAULT_BIO = "This user does not have a bio."
    
    // Variables
    var userID: String?
    var userName: String?
    var bio: String?
    var myEvents: [String]? = []
    var attendingEvents: [String]? = []
    var reportedEvents: [String]? = []
    var userTrails: [String]? = []
    var userFollowers: [String]? = []
    var friends = [String: String]()
    
    
    // BASIC CONSTRUCTOR
    // - Used for new users
    init(userID: String, userName: String) {
        self.userID = userID
        self.userName = userName
        self.bio = DEFAULT_BIO
    }
    
    // FIREBASE PULL CONSTRUCTOR
    // - Takes in a json object (snapshot) and constructs
    //   a user out of it.
    init(userDict: NSDictionary) {
        self.attendingEvents = (userDict.valueForKey("attendingEvents") as? NSDictionary)?.allValues as! [String]?
        self.bio = userDict.valueForKey("bio") as! String?
        self.userID = userDict.valueForKey("id") as! String?
        self.myEvents = (userDict.valueForKey("myEvents") as? NSDictionary)?.allValues as! [String]?
        self.userName = userDict.valueForKey("name") as! String?
        self.userFollowers = userDict.valueForKey("userFollowers") as? [String]
        self.userTrails = userDict.valueForKey("userTrails") as? [String]
    }
    
    // PUSH TO FIREBASE
    // - Add this user to firebase "Users" section
    func pushToFirebase() {
        fb.child("Users").child(userID!).setValue(convertToDictionary())
    }
    
    // CONVERT TO DICTIONARY
    // - Helper function for pushToFirebase(), converts user into dictionary
    func convertToDictionary() -> NSDictionary {
        return [
        "attendingEvents": attendingEvents!,
        "bio": bio!,
        "id": userID!,
        "myEvents": myEvents!,
        "name": userName!,
        "userFollowers": userFollowers!,
        "userTrails": userTrails!]
    }
    
    // ADD USER TRAIL
    // - Add a userID to userTrails
    // - newTrail -> userID of user that we are following
    // - True -> Trail was added
    // - False -> Trail was not added
    func addTrail(newTrail: String) -> Bool {
        
        // If user is already following newTrail, return false
        if (userTrails!.contains(newTrail)) {
            print("\naddTrail in User: userTrails already contains ", newTrail)
            return false
        }
        
        // Add the trail
        userTrails?.append(newTrail)
        
        // Update database
        fb.child("Users").child(userID!).child("userTrails").setValue(userTrails)
        
        addToFollowers(newTrail, givingFollowID: userID!)
        
        // TODO NotificationNewFollow
        
        // Trail successfully added
        print("\naddTrail in User: successfully added trail ", newTrail)
        return true
    }
    
    // Remove USER TRAIL
    // - Remove a userID from userTrails
    // - removeTrail -> userID of user that we are unfollowing
    // - True -> Trail was removed
    // - False -> Trail was not removed
    func removeTrail(removeTrail: String) -> Bool {
        
        if let index = userTrails!.indexOf(removeTrail) {
            // Remove the trail
            userTrails!.removeAtIndex(index)
            
            // Update Databse
            fb.child("Users").child(userID!).child("userTrails").setValue(userTrails)
            
            removeFromFollowers(removeTrail, givingFollowID: userID!)
            
            // Trail successfully removed
            print("\nremoveTrail in User: successfully removed trail ", removeTrail)
            return true
        } else {
            // If user is not following removeTrail, return false
            print("\nremoveTrail in User: userTrails does not contain ", removeTrail)
            return false
        }
    }
    
    func addToFollowers(receivingFollowID: String, givingFollowID: String) {
        fb.child("Users").child(receivingFollowID).child("userFollowers").child(givingFollowID).setValue(true)
    }
    func removeFromFollowers(receivingFollowID: String, givingFollowID: String) {
        fb.child("Users").child(receivingFollowID).child("userFollowers").child(givingFollowID).setValue(nil)
    }
    
    // TOSTRING METHOD
    // - Just for checking that the user has the right info
    func toString() {
        print("\nUser toString()\n\nuserName is : ", userName, "\nattendingEvents is: ", attendingEvents, "\nbio is: ", bio,
              "\nuserID is : ", userID, "\nmyEvents is: ",
              myEvents, "\nuserFollowers is : ", userFollowers, "\nuserTrails is : ", userTrails)
    }
    
}