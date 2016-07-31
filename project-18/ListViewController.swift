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
    
    /* UI STUFF ----------------------------------------------------*/
    //The three table views
    @IBOutlet var popularTableView: UITableView!
    @IBOutlet var todayTableView: UITableView!
    @IBOutlet var laterTableView: UITableView!
    @IBOutlet var popularTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var todayTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var laterTableHeightConstraint: NSLayoutConstraint!
    
    //Two see more buttons
    @IBOutlet var seeMoreTodayButton: UIButton!
    @IBAction func seeMoreTodayClick(sender: AnyObject) {
        self.showAllToday = true;
        self.seeMoreTodayButton.hidden = true;
        self.todayTableView.reloadData();
    }
    @IBOutlet var seeMoreLaterButton: UIButton!
    @IBAction func seeMoreLaterClick(sender: AnyObject) {
        self.showAllLater = true;
        self.seeMoreLaterButton.hidden = true;
        self.laterTableView.reloadData();
    }
    /*--------------------------------------------------------------*/
    
    
    //Array list of events
    private var eventArray:[Event] = [];
    private var popularEventArray:[Event] = [];
    private var todayEventArray:[Event] = [];
    private var laterEventArray:[Event] = [];
    
    //constants for initial max number of cells in each table
    private let NUM_POPULAR = 2;
    private let NUM_TODAY = 4;
    private let NUM_LATER = 4;
    private let POPULAR_THRESHOLD = 1;
    
    //vars
    private var ready:Bool = false;
    private var selectedEventID:String = "";
    private var showAllToday:Bool = false;
    private var showAllLater:Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fb = Globals.fb;
        self.navigationController?.navigationBarHidden = true;
        
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
            print("event array count \(self.eventArray.count)");
            for i in 0 ..< self.eventArray.count {
                if (self.eventArray[i].getPopularity() >= UInt(self.POPULAR_THRESHOLD)) {
                    self.popularEventArray.append(self.eventArray[i]);
                }
            }
            //TODO: TODAY AND LATER SORT
            for i in 0 ..< self.eventArray.count {
                self.todayEventArray.append(self.eventArray[i]);
            }
            for i in 0 ..< self.eventArray.count {
                self.laterEventArray.append(self.eventArray[i]);
            }
            
            //update table view accordingly
            self.updateTableViews();
        });
        
        
        //TODO: Add "No events are popular/today/later" signs
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.navigationBarHidden = true;
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
    
    //assign number of rows based off of count up until NUM_<CATEGORY>, also resize constraints
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!self.ready) {return 1}
        if (tableView == self.popularTableView) {
            if (self.popularEventArray.count < self.NUM_POPULAR) {
                self.popularTableHeightConstraint.constant = CGFloat(self.popularEventArray.count)*70;
                return self.popularEventArray.count;
            }
            self.popularTableHeightConstraint.constant = CGFloat(self.NUM_POPULAR)*70;
            return self.NUM_POPULAR;
        }
        if (tableView == self.todayTableView) {
            if (self.todayEventArray.count <= self.NUM_TODAY) {
                self.todayTableHeightConstraint.constant = CGFloat(self.todayEventArray.count)*70;
                return self.todayEventArray.count;
            }
            else {
                //more than NUM_TODAY so add see more button if not yet tapped
                if (!self.showAllToday) {
                    self.todayTableHeightConstraint.constant = CGFloat(self.NUM_TODAY)*70 + 30;
                    self.seeMoreTodayButton.hidden = false;
                    return self.NUM_TODAY;
                }
                //show everything if see more tapped
                else {
                    self.todayTableHeightConstraint.constant = CGFloat(self.todayEventArray.count)*70;
                    return self.todayEventArray.count;
                }
            }
        }
        if (tableView == self.laterTableView) {
            if (self.laterEventArray.count <= self.NUM_LATER) {
                self.laterTableHeightConstraint.constant = CGFloat(self.laterEventArray.count)*70;
                return self.laterEventArray.count;
            }
            else {
                //more than NUM_LATER so add see more button if not yet tapped
                if (!self.showAllLater) {
                    self.laterTableHeightConstraint.constant = CGFloat(self.NUM_LATER)*70 + 30;
                    self.seeMoreLaterButton.hidden = false;
                    return self.NUM_LATER;
                }
                //show everything if see more tapped
                else {
                    self.laterTableHeightConstraint.constant = CGFloat(self.laterEventArray.count)*70;
                    return self.laterEventArray.count;
                }
            }
        }
        return 0;
    }
    
    func createTableViewCellFromEvent(event: Event) -> UITableViewCell {
        let cell = UITableViewCell();
        
        return cell;
    }
    
    //configure each tableviewcell with event info
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:EventTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventTableViewCell;
        
        //callback var set to true only after firebase is done loading, recalled with updateTableView()
        if (self.ready == true) {
            //grab event from respective array
            var eventToShow:Event;
            if (tableView == self.popularTableView) {
                eventToShow = self.popularEventArray[indexPath.item];
            }
            else if (tableView == self.todayTableView) {
                eventToShow = self.todayEventArray[indexPath.item];
            }
            else {
                eventToShow = self.laterEventArray[indexPath.item];
            }
            
            cell.eventName.text = eventToShow.getName();
            cell.numGoing.text = "\(eventToShow.getPopularity())";
            
            //start date TODO:correct date formatting? I think the android one is inconsistent
            let date = NSDate(timeIntervalSince1970: NSTimeInterval(eventToShow.getStartTime())/1000);
            let formatter = NSDateFormatter();
            formatter.dateFormat = "MMM dd HH:mm a";
            let startTimeString = formatter.stringFromDate(date);
            //substringing to add "at"
            cell.eventTime.text = startTimeString.substringToIndex(startTimeString.startIndex.advancedBy(6)) + " at" + (startTimeString.substringFromIndex(startTimeString.startIndex.advancedBy(6)));
        }
        return cell;
    }
    
    //when a tableviewcell in any of the three tables is selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //get eventID from respective event array based off of category and row selected and segue to eventInfo
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
        //get rid of the highlighting
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    /* ----------------------------------------------------------------------------*/
    
    
    //when preparing to open eventinfo, set eventID to load
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "openEventInfo2") {
            (segue.destinationViewController as! EventInfoViewController).setEventID(self.selectedEventID);
        }
    }
    
}