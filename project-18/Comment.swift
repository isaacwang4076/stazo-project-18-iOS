//
//  Comment.swift
//  project-18
//
//  Created by Eric Zhang on 7/13/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation

class Comment {
    
    //vars, ALL GUARENTEED NON-NULL
    private var comment:String = ""
    private var userID:String = ""
    private var eventID:String = ""
    private var commentID:String = "" //comment id from firebase autoid push
    private var reporters:[String] = [];
    
    init() {}
    /* Comment creation */
    init(comment:String, userID:String, eventID:String) {
        self.comment = comment;
        self.userID = userID;
        self.eventID = eventID;
    }
    /* Pull constructor from firebase */
    init (dictionary:NSDictionary) {
        self.comment = dictionary.valueForKey("comment") as! String;
        self.eventID = dictionary.valueForKey("event_ID") as! String;
        self.userID = dictionary.valueForKey("user_ID") as! String;
        self.commentID = dictionary.valueForKey("comment_ID") as! String;
        if ((dictionary.valueForKey("reporters") as? NSDictionary)?.allValues != nil) {
            self.reporters = (dictionary.valueForKey("reporters") as! NSDictionary).allValues as! [String]
        }
    }
    
    //push dat shit
    func pushToFirebase() {
        let commentRef = Globals.fb.child("CommentDatabase").child(self.eventID).child("comments").childByAutoId()
        self.commentID = commentRef.key; //set commentID to firebaseID
        commentRef.setValue(self.toDictionary());
    }
    func toDictionary() -> NSDictionary {
        return ["comment":self.comment, "user_ID":self.userID, "event_ID":self.eventID, "comment_ID":self.commentID, "reporters":reporters];
    }
    
    //getter functions that gaurentees non-null values
    func getComment() -> String {
        return self.comment;
    }
    
    func getUserID() -> String {
        return self.userID;
    }
    
    func getEventID() -> String {
        return self.eventID;
    }
    
    func getReporters() -> [String] {
        return self.reporters;
    }
    
    func addReporter(reporterID:String) {
        
        // can't report your own comment
        if (reporterID == Globals.me.getUserID()) {
            return;
        }
        
        print(self.reporters);
        if (!self.reporters.contains(reporterID)) {
            self.reporters.append(reporterID);
            print(self.commentID);
            print("reported by \(reporterID)");
            Globals.fb.child("CommentDatabase").child(self.eventID).child("comments").child(self.commentID).child("reporters").childByAutoId().setValue(reporterID);
        }
    }

}