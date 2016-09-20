//
//  Event.swift
//  project-18
//
//  Created by Isaac Wang on 7/8/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import MapKit

/* Representation of an Event for the app */

class Event {
    
    // Constants
    let fb = Globals.fb                             // Reference to the app's database
    let EVENT_ID_LEN : Int = 10;                    // Length of an eventID
    
    // Variables
    private var name: String?           // The name of the event e.g. Bake Sale
    private var description: String?    // The description of the event
    private var creatorID: String?      // The ID of the User who created the event
    private var eventID: String?        // The ID of this Event
    private var startTime: UInt64?      // The start time of the event, an epoch-based long
    private var endTime: UInt64?        // The end time of the event, an epoch-based long
    // TODO location                    // The location of the event (coordinates)
    private var location: CLLocationCoordinate2D
    //guarenteed NON-NULL
    private var attendees:[String] = [] // A list of User ID's for Users who have joined this event
    private var popularity: UInt = 0    // How popular the event is (equal to attendees size)
    //private var reports: UInt = 0       // Number of reports the event has
    private var reporters:[String] = []
    
    // NO LOCATION CONSTRUCTOR
    // - Used in CreateEventAct pre-location selection
    // - eventID not included because it is generated only
    //   just before the event is pushed to Firebase
    init(name: String, description: String, creatorID: String,
         startTime:UInt64, endTime:UInt64, location:CLLocationCoordinate2D) {
        self.name = name
        self.description = description
        self.creatorID = creatorID
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
    }
    
    // FIREBASE PULL CONSTRUCTOR
    // - Takes in a json object (snapshot) and constructs
    //   an event out of it.
    // - TODO add in location
    init(eventDict: NSDictionary) {
        self.name = eventDict.valueForKey("name") as! String?
        self.description = eventDict.valueForKey("description") as! String?
        self.creatorID = eventDict.valueForKey("creator_id") as! String?
        self.endTime = (eventDict.valueForKey("endTime") as! NSNumber).unsignedLongLongValue
        self.eventID = eventDict.valueForKey("event_id") as! String?
        self.popularity = eventDict.valueForKey("popularity") as! UInt //crashes when transactions are still going through from inc/dec
        //only set reporters if it exists
        if (((eventDict.valueForKey("reporters") as? NSDictionary)?.allValues as? [String]) != nil ){
            self.reporters = (eventDict.valueForKey("reporters") as? NSDictionary)?.allValues as! [String];
        }
        self.startTime = (eventDict.valueForKey("startTime") as! NSNumber).unsignedLongLongValue
        //only set attendees if it exists
        if (((eventDict.valueForKey("attendees") as? NSDictionary)?.allValues as? [String]) != nil ){
            self.attendees = (eventDict.valueForKey("attendees") as? NSDictionary)?.allValues as! [String];
        }
        let locationDictionary = eventDict.valueForKey("location") as! NSDictionary
        self.location = CLLocationCoordinate2D(latitude: locationDictionary.valueForKey("latitude") as! Double,
                                               longitude: locationDictionary.valueForKey("longitude") as! Double)
    }
    
    // TODO location constructor
    
    // PUSH TO FIREBASE
    // - Finalizes the event by setting the ID and pushes it to Firebase
    func pushToFirebase() {
        // Assign this event an ID
        generateID();
        
        // Add this event to Events
        // Uses convert to dictionary to represent event as JSON object
        fb.child("Events").child(eventID!).setValue(convertToDictionary())
        
        // Add this event to the User's myEvents
        fb.child("Users").child(creatorID!).child("myEvents").childByAutoId().setValue(eventID!);
        
        // TODO Notification
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, h:mm a"
        
        var timeString = stringFromDate(NSDate(timeIntervalSince1970: NSTimeInterval(startTime!)/1000));
        //change Today to today
        if timeString.substringToIndex(timeString.startIndex.advancedBy(5)) == "Today" {
            timeString = "today" + timeString.substringFromIndex(timeString.startIndex.advancedBy(5));
        }
        
        let nfh: Notification = NotificationFriendHost(type: Globals.TYPE_FRIEND_HOST, pictureID: Globals.me.getUserID(), hostName: Globals.me.getUserName(), eventID: eventID!, eventName: name!, timeString: timeString)
        nfh.pushToFirebase(Array(Globals.friendsIDToName.keys))
    }
    
    
    // CONVERT TO DICTIONARY
    // - Helper function for pushToFirebase, converts event into dictionary
    // - TODO add in location
    func convertToDictionary() -> NSDictionary {
        return [
        "name" : name!,
        "description" : description!,
        "creator_id" : creatorID!,
        "endTime" : NSNumber(unsignedLongLong: endTime!),
        "event_id" : eventID!,
        "popularity" : popularity,
        //"reports" : reports,
            "reporters" : reporters,
        "startTime": NSNumber(unsignedLongLong: startTime!),
        "location": NSDictionary(dictionary: ["latitude":location.latitude, "longitude":location.longitude])
        ]
    }
    
    // EQUALS METHOD
    // - Checks for equality between this event and another
    func equals(other: Event) -> Bool {
        return (other.getEventID() == getEventID())
    }
    
    // ID GENERATOR
    // - Appends 10 letters to "yoo" and sets as the eventID
    // - We don't check for uniqueness, but math says we don't
    //   have to worry
    func generateID() {
        let allowedChars = "abcdefghijklmnopqrstuvwxyz"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var newID = "yoo"
        
        for _ in (0..<EVENT_ID_LEN) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            newID += String(newCharacter)
        }
        eventID = newID
    }
    
    // Time-specific information

    // TODO happeningLaterToday
    // TODO happeningSoon
    // TODO getTimeString
    
    // Location-specific information
    
    // TODO getAddress
    
    
    // TOSTRING METHOD
    // - Just for checking that the event has the right info
    func toString() {
        print("\nEvent toString()\n\nname is: ", name, "\ndescription is: ", description, "\ncreatorID is: ", creatorID,
              "\nendTime is: ", endTime, "\neventID is: ", eventID, "\npopularity is: ",
              popularity, /*"\nreports is: ", reports,*/ "\nreporters is: ", reporters, "\nstartTime is: ", startTime, "\nattendees is: ",
              attendees, "\nlocation is:", location)
    }
    
    
    
    // GETTERS AND SETTERS FOR ALL VARIABLES
    func getName() -> String {
        return name!
    }
    func setName(name: String) {
        self.name = name
    }
    func getDescription() -> String {
        return description!
    }
    func setDescription(description: String) {
        self.description = description
    }
    func getCreatorID() -> String {
        return creatorID!
    }
    func setCreatorID(creatorID: String) {
        self.creatorID = creatorID
    }
    func getEventID() -> String {
        return eventID!
    }
    func setEventID(eventID: String) {
        self.eventID = eventID
    }
    func getStartTime() -> UInt64 {
        return startTime!
    }
    func setStartTime(startTime: UInt64) {
        self.startTime = startTime
    }
    func getEndTime() -> UInt64 {
        return endTime!
    }
    func setEndTime(endTime: UInt64) {
        self.endTime = endTime
    }
    // TODO location getter/setter
    func getAttendees() -> [String] {
        return attendees
    }
    func setAttendees(attendees: [String]) {
        self.attendees = attendees
    }
    func getPopularity() -> UInt {
        return popularity
    }
    func setPopularity(popularity: UInt) {
        self.popularity = popularity
    }
    /*func getReports() -> UInt {
        return reports
    }
    func setReports(reports: UInt) {
        self.reports = reports
    }*/
    func getReporters() -> [String] {
        return reporters
    }
    func setRepoerters(reporters: [String]) {
        self.reporters = reporters
    }
    func getLocation() -> CLLocationCoordinate2D {
        return self.location
    }
    func setLocation(location: CLLocationCoordinate2D) {
        self.location = location
    }
    
}