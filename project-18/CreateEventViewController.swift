//
//  CreateEventViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/24/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit
import MapKit

class CreateEventViewController: UIViewController, CreateEventTableProtocol {
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var datePickerToolbar: UIToolbar!
    
    @IBAction func selectLocationClick(sender: AnyObject) {
        if (createEvent()) {
            //call segue to location select
            self.performSegueWithIdentifier("pushLocationSelect", sender: self);
        }
    }
    @IBAction func cancelClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    var createEventTable:CreateEventTable?;
    var startDate:NSDate?;
    var endDate:NSDate?;
    var noLocEvent:Event?;
    
    //small setups for nav bar, date picker
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Event";
        self.navigationController?.navigationBarHidden = false;
        
        self.datePicker.backgroundColor = UIColor.lightGrayColor();
        let today = NSDate();
        self.datePicker.minimumDate = today;
        self.datePicker.maximumDate = NSCalendar.currentCalendar()
            .dateByAddingUnit(.Day, value: 7, toDate: today, options: []);
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        self.navigationController?.navigationBarHidden = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            //check if start date empty
            if (self.startDate != nil) {
                //check if end date empty
                if (self.endDate != nil) {
                    //check if start date < end date
                    let startDateInt:UInt64 = UInt64(self.startDate!.timeIntervalSince1970) * 1000;
                    let endDateInt:UInt64 = UInt64(self.endDate!.timeIntervalSince1970) * 1000;
                    if (startDateInt < endDateInt) {
                        self.noLocEvent = Event.init(name: eventName,
                                   description: eventDescription,
                                   creatorID: Globals.me.getUserID() ,
                                   startTime: startDateInt,
                                   endTime: endDateInt,
                                   location: CLLocationCoordinate2D(latitude: 69, longitude: 69));
                        return true;
                    }
                        
                    //RESPECTIVE ALERTS
                    else {
                        let alert = UIAlertController(title: "Silly you!",
                                                      message: "The end date needs to be after the start date!", preferredStyle: .Alert);
                        alert.addAction(UIAlertAction(title: "OK", style: .Default , handler: nil));
                        self.presentViewController(alert, animated: true, completion: nil);
                        return false;
                    }
    
                }
                else {
                    let alert = UIAlertController(title: "Oops!",
                                                  message: "Please enter an end time for the event.", preferredStyle: .Alert);
                    alert.addAction(UIAlertAction(title: "OK", style: .Default , handler: nil));
                    self.presentViewController(alert, animated: true, completion: nil);
                    return false;
                }
            }
            else {
                let alert = UIAlertController(title: "Oops!",
                                              message: "Please enter a start time for the event.", preferredStyle: .Alert);
                alert.addAction(UIAlertAction(title: "OK", style: .Default , handler: nil));
                self.presentViewController(alert, animated: true, completion: nil);
                return false;
            }
            
        }
        else {
            let alert = UIAlertController(title: "Oops!",
                                          message: "Please enter a name for the event.", preferredStyle: .Alert);
            alert.addAction(UIAlertAction(title: "OK", style: .Default , handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
            return false;
        }
    }

    /* Date picker methods -------------------------------------------------------------------*/
    func openStartDatePicker() { //called on start date tableviewcell click
        self.datePicker.hidden = false;
        if (self.startDate != nil) { //wau, eric zhang w the small ux bopper
            self.datePicker.date = self.startDate!;
        }
        self.createEventTable?.eventName.resignFirstResponder();
        self.createEventTable?.eventDescription.resignFirstResponder();
        self.datePickerToolbar.hidden = false;
        self.datePicker.removeTarget(self, action: #selector(CreateEventViewController.updateEndDate),
                                     forControlEvents: UIControlEvents.ValueChanged);
        self.datePicker.addTarget(self, action: #selector(CreateEventViewController.updateStartDate),
                                  forControlEvents: UIControlEvents.ValueChanged);
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil);
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self,
                                         action: #selector(CreateEventViewController.hideStartDatePicker));
        self.datePickerToolbar.items = [space, doneButton];
    }
    
    func openEndDatePicker() { //called on end date tableviewcell click
        self.datePicker.hidden = false;
        if (self.endDate != nil) { //wau, eric zhang w the small ux bopper
            self.datePicker.date = self.endDate!;
        }
        self.createEventTable?.eventName.resignFirstResponder();
        self.createEventTable?.eventDescription.resignFirstResponder();
        self.datePickerToolbar.hidden = false;
        self.datePicker.removeTarget(self, action: #selector(CreateEventViewController.updateStartDate),
                                     forControlEvents: UIControlEvents.ValueChanged);
        self.datePicker.addTarget(self, action: #selector(CreateEventViewController.updateEndDate),
                                  forControlEvents: UIControlEvents.ValueChanged);
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil);
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self,
                                         action: #selector(CreateEventViewController.hideEndDatePicker));
        self.datePickerToolbar.items = [space, doneButton];
    }
    
    func updateStartDate() { //callback on update
        self.startDate = self.datePicker.date;
        self.createEventTable?.updateStartDate(stringFromDate(startDate!));
    }
    
    func updateEndDate() { //callback on update
        self.endDate = self.datePicker.date;
        self.createEventTable?.updateEndDate(stringFromDate(endDate!));
    }
    
    func hideStartDatePicker() { //callback on done
        self.datePicker.hidden = true;
        self.datePickerToolbar.hidden = true;
        if (self.startDate == nil) {
            self.updateStartDate();
        }
        self.datePicker.removeTarget(self, action: #selector(CreateEventViewController.updateStartDate),
                                     forControlEvents: UIControlEvents.ValueChanged);
        self.createEventTable?.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0), animated: true);
    }
    
    func hideEndDatePicker() { //callback on done
        self.datePicker.hidden = true;
        self.datePickerToolbar.hidden = true;
        if (self.endDate == nil) {
            self.updateEndDate();
        }
        self.datePicker.removeTarget(self, action: #selector(CreateEventViewController.updateEndDate),
                                     forControlEvents: UIControlEvents.ValueChanged);
        self.createEventTable?.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0), animated: true);
    }
    /* ---------------------------------------------------------------------------------------*/

    
    // Subview access
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showCreateEventTable") {
            self.createEventTable = segue.destinationViewController as? CreateEventTable;
            self.createEventTable?.delegate = self;
        }
        if (segue.identifier == "pushLocationSelect") {
            (segue.destinationViewController as! LocationSelectViewController).setNoLocEvent(self.noLocEvent!);
        }
    }
 

}

