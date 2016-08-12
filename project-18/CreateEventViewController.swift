//
//  CreateEventViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/24/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController, CreateEventTableProtocol {
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var datePickerToolbar: UIToolbar!
    
    var createEventTable:CreateEventTable?;
    
    @IBAction func addImageClick(sender: AnyObject) {
    }
    @IBAction func selectLocationClick(sender: AnyObject) {
        if (createEvent()) {
            //call segue to location select
        }
    }
    @IBAction func cancelClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    
    var startDate:NSDate?;
    var endDate:NSDate?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false;
        self.title = "Create Event";
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        self.navigationController?.navigationBarHidden = true;
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
            if (self.startDate != nil) {
                if (self.endDate != nil) {
                    
                    let startDateInt:UInt64 = UInt64(self.startDate!.timeIntervalSince1970) * 1000;
                    let endDateInt:UInt64 = UInt64(self.endDate!.timeIntervalSince1970) * 1000;
                    if (startDateInt < endDateInt) {
                        print(startDateInt);
                        print(endDateInt);
                        Event.init(name: eventName, description: eventDescription, creatorID: Globals.me.userID , startTime: startDateInt, endTime: endDateInt);
                        return true;
                    }
                    else {
                        print("Silly you! The end date is earlier than the start date!");
                        return false;
                    }
    
                }
                else {
                    print("please enter end");
                    return false;
                } //TODO: ALERTS
            }
            else {
                print("please enter start");
                return false;
            }
            
        }
        else {
            print("please enter name");
            return false;
        }
        
    }

    func openStartDatePicker() {
        self.datePicker.hidden = false;
        if (self.startDate != nil) { //wau, eric zhang w the small ux bopper
            self.datePicker.date = self.startDate!;
        }
        self.datePickerToolbar.hidden = false;
        self.datePicker.backgroundColor = UIColor.lightGrayColor();
        self.datePicker.removeTarget(self, action: #selector(CreateEventViewController.updateEndDate),
                                     forControlEvents: UIControlEvents.ValueChanged);
        self.datePicker.addTarget(self, action: #selector(CreateEventViewController.updateStartDate),
                                  forControlEvents: UIControlEvents.ValueChanged);
        self.datePickerToolbar.items?.first?.target = self;
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil);
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self,
                                         action: #selector(CreateEventViewController.hideStartDatePicker));
        self.datePickerToolbar.items = [space, doneButton];
    }
    
    func openEndDatePicker() {
        self.datePicker.hidden = false;
        if (self.endDate != nil) { //wau, eric zhang w the small ux bopper
            self.datePicker.date = self.endDate!;
        }
        self.datePickerToolbar.hidden = false;
        self.datePicker.backgroundColor = UIColor.lightGrayColor();
        self.datePicker.removeTarget(self, action: #selector(CreateEventViewController.updateStartDate),
                                     forControlEvents: UIControlEvents.ValueChanged);
        self.datePicker.addTarget(self, action: #selector(CreateEventViewController.updateEndDate),
                                  forControlEvents: UIControlEvents.ValueChanged);
        self.datePickerToolbar.items?.first?.target = self;
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil);
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self,
                                         action: #selector(CreateEventViewController.hideEndDatePicker));
        self.datePickerToolbar.items = [space, doneButton];
    }
    
    func updateStartDate() {
        print("one");
        self.startDate = self.datePicker.date;
        self.createEventTable?.updateStartDate(stringFromDate(startDate!));
    }
    
    func updateEndDate() {
        print("two");
        self.endDate = self.datePicker.date;
        self.createEventTable?.updateEndDate(stringFromDate(endDate!));
    }
    
    func hideStartDatePicker() {
        self.datePicker.hidden = true;
        self.datePickerToolbar.hidden = true;
        if (self.startDate == nil) {
            self.updateStartDate();
        }
        self.datePicker.removeTarget(self, action: #selector(CreateEventViewController.updateStartDate),
                                     forControlEvents: UIControlEvents.ValueChanged);
    }
    
    func hideEndDatePicker() {
        self.datePicker.hidden = true;
        self.datePickerToolbar.hidden = true;
        if (self.endDate == nil) {
            self.updateEndDate();
        }
        self.datePicker.removeTarget(self, action: #selector(CreateEventViewController.updateEndDate),
                                     forControlEvents: UIControlEvents.ValueChanged);
    }
    
    
    // MARK: - Navigation

    // Subview access
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showCreateEventTable") {
            self.createEventTable = segue.destinationViewController as? CreateEventTable;
            self.createEventTable?.delegate = self;
        }
    }
 

}

