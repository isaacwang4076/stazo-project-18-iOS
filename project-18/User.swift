//
//  User.swift
//  project-18
//
//  Created by Isaac Wang on 7/11/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import FirebaseDatabase

/* Representation of a User of the app */

class User: NSObject, NSCoding {
    
    // Constants
    let fb = Globals.fb                                 // Reference to the app's database
    let DEFAULT_BIO = "This user does not have a bio."  // Used if the user does not have a bio
    
    // Variables, ALL GUARENTEED NON-NULL
    var userID: String                 // Unique user identification
    var userName: String               // User's name
    var bio: String                    // User's bio
    var myEvents: [String] = []        // A list of eventID's that this user has created
    var attendingEvents: [String] = [] // A list of eventID's that this user has joined
//    var reportedEvents: [String]? = []  // A list of eventID's that this user has reported
    var userTrails: [String] = []      // A list of userID's that this user has followed
    var userFollowers: [String] = []   // A list of userID's that are following this user
//    var friends = [String: String]()    // A Hashmap of userName to userID for this user's fb friends
    
    
    // BASIC CONSTRUCTOR
    // - Used for new users
    init(userID: String, userName: String) {
        self.userID = userID
        self.userName = userName
        self.bio = DEFAULT_BIO
    }
    
    // FIREBASE PULL CONSTRUCTOR
    // - Takes in a json object (NSDictionary) and constructs
    //   a user out of it.
    init(userDict: NSDictionary) {
        self.userName = userDict.valueForKey("name") as! String
        self.userID = userDict.valueForKey("id") as! String
        self.bio = userDict.valueForKey("bio") as! String

        if ((userDict.valueForKey("attendingEvents") as? NSDictionary)?.allValues != nil) {
            self.attendingEvents = (userDict.valueForKey("attendingEvents") as! NSDictionary).allValues as! [String]
        }
        if ((userDict.valueForKey("myEvents") as? NSDictionary)?.allValues != nil) {
            self.myEvents = (userDict.valueForKey("myEvents") as! NSDictionary).allValues as! [String]
        }
        if ((userDict.valueForKey("userFollowers") as? NSDictionary)?.allValues != nil) {
            self.userFollowers = (userDict.valueForKey("userFollowers") as! NSDictionary).allKeys as! [String]
        }
        if ((userDict.valueForKey("userTrails") as? NSDictionary)?.allValues != nil) {
            self.userTrails = (userDict.valueForKey("userTrails") as! NSDictionary).allValues as! [String]
        }
    }
    
    // PUSH TO FIREBASE
    // - Add this user to firebase "Users" section
    func pushToFirebase() {
        fb.child("Users").child(userID).setValue(convertToDictionary())
    }
    
    // CONVERT TO DICTIONARY
    // - Helper function for pushToFirebase(), converts user into dictionary
    func convertToDictionary() -> NSDictionary {
        return [
        "attendingEvents": attendingEvents,
        "bio": bio,
        "id": userID,
        "myEvents": myEvents,
        "name": userName,
        "userFollowers": userFollowers,
        "userTrails": userTrails]
    }
    
    // ADD USER TRAIL
    // - Add a userID to userTrails
    // - newTrail -> userID of user that we are following
    // - True -> Trail was added
    // - False -> Trail was not added
    func addTrail(newTrail: String) -> Bool {
        
        // If user is already following newTrail, return false
        if (userTrails.contains(newTrail)) {
            print("\naddTrail() in User: userTrails already contains ", newTrail)
            return false
        }
        
        // Add the trail
        userTrails.append(newTrail)
        
        // Update database
        fb.child("Users").child(userID).child("userTrails").setValue(userTrails)
        
        addToFollowers(newTrail, givingFollowID: userID)
        
        // TODO NotificationNewFollow
        
        // Trail successfully added
        print("\naddTrail() in User: successfully added trail ", newTrail)
        return true
    }
    
    // REMOVE USER TRAIL
    // - Remove a userID from userTrails
    // - removeTrail -> userID of user that we are unfollowing
    // - True -> Trail was removed
    // - False -> Trail was not removed
    func removeTrail(removeTrail: String) -> Bool {
        
        if let index = userTrails.indexOf(removeTrail) {
            // Remove the trail
            userTrails.removeAtIndex(index)
            
            // Update Databse
            fb.child("Users").child(userID).child("userTrails").setValue(userTrails)
            
            removeFromFollowers(removeTrail, givingFollowID: userID)
            
            // Trail successfully removed
            print("\nremoveTrail() in User: successfully removed trail ", removeTrail)
            return true
        } else {
            // If user is not following removeTrail, return false
            print("\nremoveTrail() in User: userTrails does not contain ", removeTrail)
            return false
        }
    }
    
    // ADD USER FOLLOWER
    // - Helper function for addTrail
    // - Adds the follower's userID to the followed's userFollowers
    func addToFollowers(receivingFollowID: String, givingFollowID: String) {
        fb.child("Users").child(receivingFollowID).child("userFollowers").child(givingFollowID).setValue(true)
    }
    
    // REMOVE USER FOLLOWER
    // - Helper function for removeTrail
    // - Removes the follower's userID from the followed's userFollowers
    func removeFromFollowers(receivingFollowID: String, givingFollowID: String) {
        fb.child("Users").child(receivingFollowID).child("userFollowers").child(givingFollowID).setValue(nil)
    }
    
    
    // ATTEND EVENT
    // - Handles a user "joining" an event
    // - True -> Event was joined
    // - False -> Event was not joined (already joined)
    func attendEvent(eventID: String, eventName: String, creatorID: String) -> Bool {
        
        // If user is already attending the event, return false
        if (attendingEvents.contains(eventID)) {
            print("\nattendEvent() in User: already attending event with ID ", eventID)
            return false
        }
        
        // ---- Update Event Information ------------------------------------------------------
        
        // Add the user's userID to attendees on the database
        fb.child("Events").child(eventID).child("attendees").childByAutoId().setValue(userID)
        
        // popularity increment
        fb.child("Events").child(eventID).child("popularity").runTransactionBlock({
            data in
            if (!data.value!.isEqual!(NSNull())) {
                let currentPopularity = data.value as! Int;
                data.value = currentPopularity + 1;
            }
            return FIRTransactionResult.successWithValue(data);
        })
        
        // ------------------------------------------------------------------------------------

        
        
        // ---- Update User Information -------------------------------------------------------
        
        // Add the eventID to attendingEvents locally (for the current session)
        attendingEvents.append(eventID)
        
        // Add the eventID to attendingEvents on the database (for future sessions)
        fb.child("Users").child(userID).child("attendingEvents").childByAutoId().setValue(eventID)
        
        // ------------------------------------------------------------------------------------
        
        // TODO NotificationJoinedEvent
        
        // Event successfully attended
        print("\nattendEvent() in User: now attending event with ID ", eventID)
        return true;
    }
    
    // UNATTEND EVENT
    // - Handles a user "un-joining" an event
    // - True -> Event was unjoined
    // - False -> Event was not unjoined (not joined to begin with)
    func unattendEvent(eventID: String) -> Bool {
        
        // If user is already attending the event, return false
        if (attendingEvents.contains(eventID) == false) {
            print("\nunattendEvent() in User: not yet attending event with ID ", eventID)
            return false
        }
        
        // ---- Update Event Information ------------------------------------------------------
        
        // Remove the user's userID from attendees on the database
        // Listener for event's attendees snapshot
        fb.child("Events").child(eventID).child("attendees").observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            for attendeeSnapshot in snapshot.children {
                if attendeeSnapshot.value == self.userID {
                    attendeeSnapshot.ref.setValue(nil)
                    break
                }
            }
        })

        
        // popularity decrement
        fb.child("Events").child(eventID).child("popularity").runTransactionBlock({
            data in
            if (!data.value!.isEqual!(NSNull())) {
                let currentPopularity = data.value as! Int;
                data.value = currentPopularity - 1;
            }
            return FIRTransactionResult.successWithValue(data);
        })
        
        // ------------------------------------------------------------------------------------
        
        
        
        // ---- Update User Information -------------------------------------------------------
        
        // Remove the eventID from attendingEvents locally (for the current session)
        attendingEvents.removeAtIndex(attendingEvents.indexOf(eventID)!)
        
        // Remove the eventID from attendingEvents on the database (for future sessions)
        // Listener for user's attendingEvents snapshot
        fb.child("Users").child(userID).child("attendingEvents").observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            for eventSnapshot in snapshot.children {
                if eventSnapshot.value == eventID {
                    eventSnapshot.ref.setValue(nil)
                    break
                }
            }
        })
        // ------------------------------------------------------------------------------------
        
        
        // Event successfully attended
        print("\nunattendEvent() in User: no longer attending event with ID ", eventID)
        return true;
    }
    
    // TOSTRING METHOD
    // - Just for checking that the user has the right info
    func toString() {
        print("\nUser toString()\n\nuserName is : ", userName, "\nattendingEvents is: ", attendingEvents, "\nbio is: ", bio,
              "\nuserID is : ", userID, "\nmyEvents is: ",
              myEvents, "\nuserFollowers is : ", userFollowers, "\nuserTrails is : ", userTrails)
    }
    
    //ENCODER METHODS FOR SAVING USER OBJECT TO SHARED PREFERENCES
    required init (coder decoder:NSCoder) {
        self.userID = decoder.decodeObjectForKey("userID") as! String;
        self.userName = decoder.decodeObjectForKey("userName") as! String;
        self.bio = decoder.decodeObjectForKey("bio") as! String;
        self.myEvents = decoder.decodeObjectForKey("myEvents") as! [String];
        self.attendingEvents = decoder.decodeObjectForKey("attendingEvents") as! [String];
        self.userTrails = decoder.decodeObjectForKey("userTrails") as! [String];
        self.userFollowers = decoder.decodeObjectForKey("userFollowers") as! [String];
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.userID, forKey: "userID");
        coder.encodeObject(self.userName, forKey: "userName");
        coder.encodeObject(self.bio, forKey: "bio");
        coder.encodeObject(self.myEvents, forKey: "myEvents");
        coder.encodeObject(self.attendingEvents, forKey: "attendingEvents");
        coder.encodeObject(self.userTrails, forKey: "userTrails");
        coder.encodeObject(self.userFollowers, forKey: "userFollowers");
    }
    
    //debugging
    func printUserInfo() {
        print("USER INFO ----------------------------");
        print("User id: " + Globals.me.userID);
        print("User name: " + Globals.me.userName);
        print("Bio: " + Globals.me.bio);
        print("Attending: ", terminator:""); for i in 0 ..< Globals.me.attendingEvents.count {print("\(Globals.me.attendingEvents[i])", terminator:"; ")}
        print("\nMy Events: ", terminator:""); for i in 0 ..< Globals.me.myEvents.count {print("\(Globals.me.myEvents[i])", terminator:"; ")}
        print("\nUser Followers: ", terminator:""); for i in 0 ..< Globals.me.userFollowers.count {print("\(Globals.me.userFollowers[i])", terminator:"; ")}
        print("\nUser Trails: ",terminator:""); for i in 0 ..< Globals.me.userTrails.count {print("\(Globals.me.userTrails[i])", terminator:"; ")}
        print("\n------------------------------------");
    }
    
    // TODO
    // - Getters and setters
    // - Facebook friend handling
    // - Bio filtering
    
}