//
//  Event.swift
//  project-18
//
//  Created by Isaac Wang on 7/8/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase


class Event {
    
    // Constants
    let fb = FIRDatabase.database().reference()    // Reference to the database
    let EVENT_ID_LEN : Int = 10;                    // Length of an Event ID
    
    // Variables
    var name: String?           // The name of the event e.g. Bake Sale
    var description: String?    // The description of the event
    var creatorID: String?      // The ID of the User who created the event
    var eventID: String?        // The ID of this Event
    var startTime: UInt64?      // The start time of the event, an epoch-based long
    var endTime: UInt64?        // The end time of the event, an epoch-based long
    // TODO location            // The location of the event (coordinates)
    var attendees = [String]?() // A list of User ID's for Users who have joined this event
    
    var popularity: UInt = 0    // How popular the event is (equal to attendees size)
    var reports: UInt = 0       // Number of reports the event has
    
    
    
    // DEFAULT CONSTRUCTOR
    // - Required by Firebase, not used in our code
    init() {}
    
    // NO LOCATION CONSTRUCTOR
    // - Used in CreateEventAct pre-location selection
    // - eventID not included because it is generated only
    //   just before the event is pushed to Firebase
    init(name: String, description: String, creatorID: String,
         startTime:UInt64, endTime:UInt64) {
        self.name = name
        self.description = description
        self.creatorID = creatorID
        self.startTime = startTime
        self.endTime = endTime
    }
    
    // TODO location constructor
    // TODO Firebase-pull constructor
    
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
    }
    
    // CONVERT TO DICTIONARY
    // - Helper function for pushToFirebase, converts event into dictionary
    func convertToDictionary() -> NSDictionary {
        return [
        "name" : name!,
        "description" : description!,
        "creator_id" : creatorID!,
        "endTime" : NSNumber(unsignedLongLong: endTime!),
        "event_id" : eventID!,
        "popularity" : popularity,
        "reports" : reports,
        "startTime": NSNumber(unsignedLongLong: startTime!)]
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
        return attendees!
    }
    func setAttendees(attendees: [String]) {
        self.attendees = attendees
    }
    func getPopularity() -> UInt {
        return popularity
    }
    func setPopularity(popularity: UInt) {
        self.popularity = reports
    }
    func getReports() -> UInt {
        return reports
    }
    func setReports(reports: UInt) {
        self.reports = reports
    }
    
    
}