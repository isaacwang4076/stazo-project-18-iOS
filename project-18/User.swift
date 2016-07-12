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
    
    // TOSTRING METHOD
    // - Just for checking that the user has the right info
    func toString() {
        print("\nUser toString()\n\nuserName is : ", userName, "\nattendingEvents is: ", attendingEvents, "\nbio is: ", bio,
              "\nuserID is : ", userID, "\nmyEvents is: ",
              myEvents, "\nuserFollowers is : ", userFollowers, "\nuserTrails is : ", userTrails)
    }
    
}