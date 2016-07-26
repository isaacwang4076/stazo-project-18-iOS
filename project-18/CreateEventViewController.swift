//
//  CreateEventViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/24/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController {

    @IBOutlet var eventNameTextView: UITextField!
    @IBOutlet var descriptionTextView: UITextField!

    
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
        /*var newEvent = Event.init();
        
        if (self.eventNameTextView.text != nil) {
            newEvent.setName(self.eventNameTextView.text!);
        }
        else {
            print("no event name message");
        }
        
        if (self.descriptionTextView.text != nil) {
            newEvent.setDescription(self.descriptionTextView.text!);
        }*/
        
        
        return true;
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
