//
//  MapViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/18/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate,
 UITableViewDelegate, UITableViewDataSource {

    var searchController : UISearchController!
    
    @IBOutlet var tableView: UITableView!

    var allEventIDs =   ["abc", "abcd", "helloWorld", "IsaacWang"]
    var filteredEventIDs = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // SEARCH STUFF
        
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        
        self.navigationItem.titleView = searchController.searchBar
        
        self.definesPresentationContext = true
        
        
        // CELL STUFF
        self.tableView = UITableView()
        //tableView.tableHeaderView = searchController.searchBar
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // SEARCH ----------------------------------------------------------------------------------------

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredEventIDs = allEventIDs.filter { event in
            return event.lowercaseString.containsString(searchText.lowercaseString)
        }
        print(filteredEventIDs)
        tableView.reloadData()
    }
    
    // -----------------------------------------------------------------------------------------------

    
    
    // TABLE VIEW ------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("/n filteredEventIDs.count is ", self.filteredEventIDs.count)

        return self.filteredEventIDs.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        //cell.textLabel?.text = self.filteredEventIDs[indexPath.row]
        cell.textLabel?.text = "yeet"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // -----------------------------------------------------------------------------------------------

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using 
        
        //if it's the eventinfo segue, set the event id
        if (segue.identifier == "openEventInfo") {
            (segue.destinationViewController as! EventInfoViewController).setEventID("yooYSUWICTOWW");
        }
        // Pass the selected object to the new view controller.
    }
    

}
