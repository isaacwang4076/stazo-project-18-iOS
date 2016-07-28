//
//  ListViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/11/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //The three table views
    @IBOutlet var popularTableView: UITableView!
    @IBOutlet var todayTableView: UITableView!
    @IBOutlet var laterTableView: UITableView!
    
    @IBOutlet var popularTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var todayTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var laterTableHeightConstraint: NSLayoutConstraint!
    
    //Show more button
    
    //Array list of events
    var eventArray = [Event]();
    var popularEventArray = [Event]();
    var todayEventArray = [Event]();
    var laterEventArray = [Event]();
    
    //constants
    let NUM_POPULAR = 2;
    let NUM_TODAY = 4;
    let NUM_LATER = 4;
    
    //vars
    var ready:Bool = false;
    var selectedEventID:String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fb = Globals.fb;
        
        //Register table view cell nib
        self.popularTableView.registerNib(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "Cell");
        self.todayTableView.registerNib(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "Cell");
        self.laterTableView.registerNib(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "Cell");

        
        //Pull list of events and add to eventArray
        fb.child("Events").observeSingleEventOfType(.Value, withBlock: {
            (snapshot) in
            for eachEvent in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let eventDictionary = eachEvent.value as! [String:AnyObject];
                let x = Event.init(eventDict: eventDictionary);
                print("Pulled event: \(x.getName())");
                self.eventArray.append(Event.init(eventDict: eventDictionary));
            }
            
            
            //process the events into table view categories
            //temp popularity sort lmao
            print("event array count \(self.eventArray.count)");
            for i in 0 ..< self.eventArray.count {
                self.popularEventArray.append(self.eventArray[i]);
            }
            for i in 0 ..< self.eventArray.count {
                self.todayEventArray.append(self.eventArray[i]);
            }
            for i in 0 ..< self.eventArray.count {
                self.laterEventArray.append(self.eventArray[i]);
            }
            
            //update table view accordingly
            self.updateTableViews();
        });
        
        
        //TODO: Add logic for sorting popular and upcoming events, add see more logic, add variable row height logic if necessary
        
        
    }
    
    
    func updateTableViews() {
        self.ready = true;
        self.popularTableView.reloadData();
        self.todayTableView.reloadData();
        self.laterTableView.reloadData();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Table view data source and delegates -------------------------------------------- */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.popularTableView) {
            return 2
        }
        if (tableView == self.todayTableView) {
            return 2
        }
        if (tableView == self.laterTableView) {
            return 4
        }
        return 1
    }
    
    func createTableViewCellFromEvent(event: Event) -> UITableViewCell {
        let cell = UITableViewCell();
        
        return cell;
    }
    
    //cofigure each tableviewcell with event info
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:EventTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventTableViewCell;
        if (self.ready == true) {
            if (tableView == self.popularTableView) {
                cell.eventName.text = popularEventArray[indexPath.item].getName();
                cell.eventTime.text = "some time";
            }
            if (tableView == self.todayTableView) {
                cell.eventName.text = todayEventArray[indexPath.item].getName();
                cell.eventTime.text = "some time";
            }
            if (tableView == self.laterTableView) {
                cell.eventName.text = laterEventArray[indexPath.item].getName();
                cell.eventTime.text = "some time";
            }
        }
        return cell;
    }
    
    //when a tableviewcell in any of the three tables is selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //get eventID from respective event array based off of category and row selected
        if (tableView == self.popularTableView) {
            self.selectedEventID = self.popularEventArray[indexPath.row].getEventID();
            self.performSegueWithIdentifier("openEventInfo2", sender: self);
            print("event: \(self.popularEventArray[indexPath.row].getName())");
        }
        if (tableView == self.todayTableView) {
            self.selectedEventID = self.todayEventArray[indexPath.row].getEventID();
            self.performSegueWithIdentifier("openEventInfo2", sender: self);
            print("event: \(self.todayEventArray[indexPath.row].getName())");
        }
        if (tableView == self.laterTableView) {
            self.selectedEventID = self.laterEventArray[indexPath.row].getEventID();
            self.performSegueWithIdentifier("openEventInfo2", sender: self);
            print("event: \(self.laterEventArray[indexPath.row].getName())");
        }
    }
    /* ----------------------------------------------------------------------------*/
    
    
    //when preparing to open eventinfo, set eventID to load
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "openEventInfo2") {
            (segue.destinationViewController as! EventInfoViewController).setEventID(self.selectedEventID);
        }
    }
    
}