//
//  Comment.swift
//  project-18
//
//  Created by Eric Zhang on 7/13/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation

class Comment {
    
    //vars, ? means it can be null
    private var comment:String?
    private var userID:String?
    private var eventID:String?
    
    init() {}
    init(comment:String, userID:String, eventID:String) {
        self.comment = comment;
        self.userID = userID;
        self.eventID = eventID;
    }
    
    //push dat shit
    func pushToFirebase() {
        Globals.fb.child("CommentDatabase").child(self.eventID!).setValue(self);
    }
    func toDictionary() -> NSDictionary {
        return ["comment":self.comment!, "userID":self.userID!, "eventID":self.eventID!];
    }
    
    //getter functions that gaurentees non-null values
    func getComment() -> String {
        return self.comment!;
    }
    
    func getUserID() -> String {
        return self.userID!;
    }
    
    func getEventID() -> String {
        return self.eventID!;
    }

}