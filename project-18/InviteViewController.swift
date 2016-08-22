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

class InviteViewController: UIViewController {
    
    @IBOutlet weak var inviteSearchBar: UISearchBar!
    
    var filteredFriendNames = [String]()
    var searchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the navigation bar (included for back-navigation on segue to EventInfo)
        self.navigationController?.navigationBarHidden = true;
        
    }
    
    // SEARCH ----------------------------------------------------------------------------------------
    
    
    // ON SEARCH CHANGE
    // - Updates results
    // - Updates search table view to match results
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Update results based on query
        filteredFriendNames = Globals.friendsNameToID.keys.filter { friend in
            return friend.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        // Make search smarter
        sortFilteredFriendNames(searchText)
        
        // Update results
    }
    
    // Updates the order of filteredEventNames using prefixCompare
    func sortFilteredFriendNames(searchText: String) {
        self.searchText = searchText
        filteredFriendNames = filteredFriendNames.sort(prefixCompare)
    }
    
    // For query "fu", prioritizes "Fundraiser" over "KungFu"
    func prefixCompare(eventName1: String, eventName2: String) -> Bool {
        return eventName1.lowercaseString.hasPrefix(self.searchText!.lowercaseString)
    }
    
    // -----------------------------------------------------------------------------------------------

}