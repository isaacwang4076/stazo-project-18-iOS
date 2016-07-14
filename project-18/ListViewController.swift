//
//  ListViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/11/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit
import Firebase

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //The three table views
    @IBOutlet var popularTableView: UITableView!
    @IBOutlet var todayTableView: UITableView!
    @IBOutlet var laterTableView: UITableView!

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

    override func viewDidLoad() {
        super.viewDidLoad()
        let fb = Globals.fb;
        
        //Pull list of events and add to eventArray
        fb.child("Events").observeSingleEventOfType(.Value, withBlock: {
            (snapshot) in
            for eachEvent in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let eventDictionary = eachEvent.value as! [String:AnyObject];
                let x:Event = Event.init(eventDict: eventDictionary);
                print("eventname: \(x.getName())");
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
            
            //update table view accordingly
            self.laterEventArray = self.eventArray;
            self.updateTableViews();
        });
        
//        self.popularTableView.estimatedRowHeight = 80
//        self.popularTableView.rowHeight = UITableViewAutomaticDimension
//        
//        self.popularTableView.setNeedsLayout()
//        self.popularTableView.layoutIfNeeded()
        
    }
    
    
    func updateTableViews() {
        self.ready = true;
        popularTableView.reloadData();
        todayTableView.reloadData();
        laterTableView.reloadData();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        NSLog("one");
        let cell:ListTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ListTableViewCell;
        if (self.ready == true) {
            if (tableView == self.popularTableView) {
                print(indexPath.item);
                cell.eventName.text = popularEventArray[indexPath.item].getName();
                cell.eventTime.text = "some time";
            }
            if (tableView == self.todayTableView) {
                print(indexPath.item);
                cell.eventName.text = todayEventArray[indexPath.item].getName();
                cell.eventTime.text = "some time";
            }
            if (tableView == self.laterTableView) {
                print(indexPath.item);
                cell.eventName.text = laterEventArray[indexPath.item].getName();
                cell.eventTime.text = "some time";
            }
        }
        return cell;
    }
    
    
}