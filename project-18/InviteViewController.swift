//
//  InviteViewController.swift
//  project-18
//
//  Created by Isaac Wang on 8/17/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class InviteViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var inviteSearchBar: UISearchBar!
        
    @IBOutlet weak var usersTableView: UITableView!
    
    @IBOutlet weak var usersTableViewHeightConstraint: NSLayoutConstraint!
    
    var filteredFriendIDs = [String]()
    var searchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the navigation bar (included for back-navigation on segue to EventInfo)
        self.navigationController?.navigationBarHidden = true;
        
        // Search setup
        inviteSearchBar.delegate = self
        
        // TableView cell
        self.usersTableView.registerNib(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell");
        
    }
    
    // SEARCH ----------------------------------------------------------------------------------------
    
    
    // ON SEARCH CHANGE
    // - Updates results
    // - Updates search table view to match results
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Update results based on query
        filteredFriendIDs = Globals.friendsIDToName.keys.filter { friendID in
            return Globals.friendsIDToName[friendID]!.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        // Make search smarter
        sortFilteredFriendNames(searchText)
        
        // Update results
        usersTableView.reloadData()
    }
    
    // Updates the order of filteredEventNames using prefixCompare
    func sortFilteredFriendNames(searchText: String) {
        self.searchText = searchText
        filteredFriendIDs = filteredFriendIDs.sort(prefixCompare)
    }
    
    // For query "fu", prioritizes "Fundraiser" over "KungFu"
    func prefixCompare(user1ID: String, user2ID: String) -> Bool {
        return Globals.friendsIDToName[user1ID]!.lowercaseString.hasPrefix(self.searchText!.lowercaseString)
    }
    
    // -----------------------------------------------------------------------------------------------
    
    // TABLE VIEW ------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.usersTableViewHeightConstraint.constant = CGFloat(self.filteredFriendIDs.count) * 80;
        
        
        // Return number of matching queries
        return self.filteredFriendIDs.count;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Only one section
        return 1
    }
    
    // CELL CREATION
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Create cell
        let cell:UserTableViewCell = usersTableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserTableViewCell;
        
        // Grab Event to base cell off of
        let userID:String = self.filteredFriendIDs[indexPath.row]
        
        // Populate cell based on the Event's info
        populateCell(cell, userID: userID)
        
        return cell
    }
    
    
    // HANDLE CELL CLICK
    // - Go to corresponding event info page
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*
        self.selectedEventID = Globals.eventsNameToID[self.filteredEventNames[indexPath.row]];
        self.performSegueWithIdentifier("openEventInfo", sender: self);*/
    }
    
    // -----------------------------------------------------------------------------------------------

}