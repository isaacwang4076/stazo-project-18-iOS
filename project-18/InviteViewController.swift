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
    
    @IBOutlet weak var inviteLabel: UILabel!
    
    @IBOutlet weak var usersTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBAction func sendInvitesClick(sender: AnyObject) {
        sendInvites()
        //return back to eventInfo
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    let MAX_CELLS = 7                   // The maximum number of results displayed at a time
    
    var searchText: String = ""         // The search query
    var filteredFriendIDs = [String]()  // List of IDs of friends who match the query
    var invitedFriendIDs = [String]()   // List of IDs of friends whom the user has invited
    
    // Info for this event
    var eventID: String?
    var eventName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show nav bar and set title
        self.navigationController?.navigationBarHidden = false;
        self.title = "Event Invite";
        
        // Search setup
        inviteSearchBar.delegate = self
        
        // TableView cell
        self.usersTableView.registerNib(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell");

        // Set label text
        self.inviteLabel.text = "Invite friends to \(self.eventName!)"
    }
    
    // Called in prepareForSegue in EventInfoViewController, sets the info for the event
    func setEventInfo(event: Event) {
        self.eventID = event.getEventID()
        self.eventName = event.getName()

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
        return Globals.friendsIDToName[user1ID]!.lowercaseString.hasPrefix(self.searchText.lowercaseString)
    }
    
    // -----------------------------------------------------------------------------------------------
    
    // TABLE VIEW ------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numCells = min(MAX_CELLS, self.filteredFriendIDs.count)
        
        self.usersTableViewHeightConstraint.constant = CGFloat(numCells) * 80;
        
        // Return number of cells
        return numCells;
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
        populateCell(cell, userID: userID, isSelected: invitedFriendIDs.contains(userID))
        
        return cell
    }
    
    
    // HANDLE CELL CLICK
    // - Go to corresponding event info page
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // The ID of the friend who was clicked
        let selectedFriendID = self.filteredFriendIDs[indexPath.row]
        
        // If they are already in the invite list, remove them
        if (invitedFriendIDs.contains(selectedFriendID)) {
            invitedFriendIDs.removeAtIndex(invitedFriendIDs.indexOf(selectedFriendID)!)
            usersTableView.cellForRowAtIndexPath(indexPath)!.backgroundColor = Globals.COLOR_UNSELECTED_CELL
        }
        // Otherwise, add them
        else {
            invitedFriendIDs.append(self.filteredFriendIDs[indexPath.row])
            usersTableView.cellForRowAtIndexPath(indexPath)!.backgroundColor = Globals.COLOR_SELECTED_CELL
        }
        
        // So when you click someone they aren't highlighted the default grey
        usersTableView.deselectRowAtIndexPath(indexPath, animated: false)

        print("\ninvitedFriendIDs: ", invitedFriendIDs)
    }
    
    // -----------------------------------------------------------------------------------------------
    
    
    // Send an invite for this event from me to all the selected friends
    func sendInvites() {
        
        print("\nSending invites...")
        for friendID in invitedFriendIDs {
            let nie: Notification = NotificationInviteEvent(type: Globals.TYPE_INVITE_EVENT, pictureID: Globals.me.getUserID(), eventID: eventID!, eventName: eventName!, userNames: [Globals.me.getUserName()])
            nie.pushToFirebase([friendID])
        }
    }
    
}