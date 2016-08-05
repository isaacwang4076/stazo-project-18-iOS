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
    
    //var searchController : UISearchController!
    
    @IBOutlet var tableView: UITableView!
    //@IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var mapSearchBar: UISearchBar!
    
    var searchController: UISearchController!
    
    var filteredEventNames = [String]()
    var selectedEventID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tabBarController?.tabBar.translucent = false
        self.tabBarController?.tabBar.barTintColor = UIColor.whiteColor()
        self.tabBarController?.tabBar.tintColor = UIColor.blueColor()
        self.navigationController?.navigationBarHidden = true;

        // Do any additional setup after loading the view.
        
        // SEARCH STUFF
        
        /*self.searchController = UISearchController(searchResultsController:  nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.definesPresentationContext = true*/
        
        mapSearchBar.delegate = self
        self.tableView.registerNib(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "Cell");

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // SEARCH ----------------------------------------------------------------------------------------
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }

    /*func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }*/
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredEventNames = Globals.eventsNameToID.keys.filter { event in
            return event.lowercaseString.containsString(searchText.lowercaseString)
        }
//        print("Filtered event IDs:")
//        print(filteredEventIDs)
        tableView.reloadData()
    }
    
    // -----------------------------------------------------------------------------------------------

    
    
    // TABLE VIEW ------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("/n filteredEventIDs.count is ", self.filteredEventNames.count)
        if self.filteredEventNames.count == 0 {
            tableView.hidden = true
        } else {
            tableView.hidden = false
        }
        return self.filteredEventNames.count;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:EventTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventTableViewCell;
        
        /*cell.textLabel?.text = self.filteredEventNames[indexPath.row]
//        cell.textLabel?.text = "yeet"
        //cell.backgroundColor = UIColor.whiteColor()
        self.view.bringSubviewToFront(tableView)*/
        
        let eventToShow:Event = Globals.eventsIDToEvent[Globals.eventsNameToID[self.filteredEventNames[indexPath.row]]!]!
        
        populateCell(cell, eventToShow: eventToShow)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let eventName = (tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! EventCell).eventName.text!
        
        //print("\nEvent with name: ", eventName, " and id: ", Globals.eventsNameToID[eventName], " pressed.")
        self.selectedEventID = Globals.eventsNameToID[self.filteredEventNames[indexPath.row]];
        self.performSegueWithIdentifier("openEventInfo", sender: self);
    }
    
    // -----------------------------------------------------------------------------------------------

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using 
        
        //if it's the eventinfo segue, set the event id
        if (segue.identifier == "openEventInfo") {
            (segue.destinationViewController as! EventInfoViewController).hidesBottomBarWhenPushed = true;
            (segue.destinationViewController as! EventInfoViewController).setEventID(self.selectedEventID!);
        }
        // Pass the selected object to the new view controller.
    }
    

}
