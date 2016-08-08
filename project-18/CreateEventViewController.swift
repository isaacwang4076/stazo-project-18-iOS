//
//  CreateEventViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/24/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController {
    
    var createEventTable:CreateEventTable?;
    
    @IBAction func addImageClick(sender: AnyObject) {
    }
    @IBAction func selectLocationClick(sender: AnyObject) {
        if (createEvent()) {
            //call segue to location select
        }
    }
    @IBAction func cancelClick(sender: AnyObject) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Attempts to create an event without location based off of info from text fields.
     * Pops up a message if fields are wrong/empty and returns false. Returns true if event is made and can proceed.
     */
    func createEvent() -> Bool {
        
        //take out leading and trailing whitespace and check if event name is empty
        let eventName = self.createEventTable!.eventName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet());
        let eventDescription = self.createEventTable!.eventDescription.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet());
        if (!eventName.isEmpty) {
            print(self.createEventTable!.eventName.text!);
            if (self.createEventTable!.tempStart != 0) {
                if (self.createEventTable!.tempEnd != 0) {
                    Event.init(name: eventName, description: eventDescription, creatorID: Globals.me.userID , startTime: UInt64(self.createEventTable!.tempStart), endTime: UInt64(self.createEventTable!.tempEnd));
                    print("made event");
                    return true;
                }
                else {
                    return false;
                }
            }
            else {
                return false;
            }
            
        }
        else {
            print("please enter name");
            return false;
        }
        
        
//        return true;
    }

    
    // MARK: - Navigation

    // Subview access
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showCreateEventTable") {
            self.createEventTable = segue.destinationViewController as! CreateEventTable;
        }
    }
 

}
