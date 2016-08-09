//
//  MapViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/18/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class MapViewController: UIViewController, UISearchBarDelegate,
 UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!           // The table view for search results
    @IBOutlet weak var mapSearchBar: UISearchBar!   // The search bar
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var searchController: UISearchController!       // Search bar controller
    var filteredEventNames = [String]()             // Event names that fit the query
    var selectedEventID: String?                    // The eventID of the selected event

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the navigation bar (included for back-navigation on segue to EventInfo)
        self.navigationController?.navigationBarHidden = true;
        
        // Search setup
        mapSearchBar.delegate = self
        self.tableView.registerNib(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell");

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // SEARCH ----------------------------------------------------------------------------------------
    
    
    // ON SEARCH CHANGE
    // - Updates results
    // - Updates search table view to match results
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Update results based on query
        filteredEventNames = Globals.eventsNameToID.keys.filter { event in
            return event.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        // Update search table view
        tableView.reloadData()
    }
    
    // -----------------------------------------------------------------------------------------------

    
    
    // TABLE VIEW ------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.tableViewHeightConstraint.constant = CGFloat(self.filteredEventNames.count) * 70;

        
        // Return number of matching queries
        return self.filteredEventNames.count;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Only one section
        return 1
    }
    
    // CELL CREATION
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Create cell
        let cell:EventTableViewCell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as! EventTableViewCell;
        
        // Grab Event to base cell off of
        let eventToShow:Event = Globals.eventsIDToEvent[Globals.eventsNameToID[self.filteredEventNames[indexPath.row]]!]!
        
        // Populate cell based on the Event's info
        populateCell(cell, eventToShow: eventToShow)
        
        return cell
    }
    
    
    // HANDLE CELL CLICK
    // - Go to corresponding event info page
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedEventID = Globals.eventsNameToID[self.filteredEventNames[indexPath.row]];
        self.performSegueWithIdentifier("openEventInfo", sender: self);
    }
    
    // -----------------------------------------------------------------------------------------------

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //if it's the eventinfo segue, set the event id
        if (segue.identifier == "openEventInfo") {
            (segue.destinationViewController as! EventInfoViewController).hidesBottomBarWhenPushed = true;
            (segue.destinationViewController as! EventInfoViewController).setEventID(self.selectedEventID!);
        }
    }
    

}
