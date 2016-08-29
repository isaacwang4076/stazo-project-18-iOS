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
import MapKit

class MapViewController: UIViewController, UISearchBarDelegate,
 UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    @IBOutlet var tableView: UITableView!           // The table view for search results
    @IBOutlet weak var mapSearchBar: UISearchBar!   // The search bar
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var mapView: MKMapView!
    
    var filteredEventNames = [String]()             // Event names that fit the query
    var selectedEventID: String?                    // The eventID of the selected event
    var searchText: String?                         // Search query, used for sorting

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the navigation bar (included for back-navigation on segue to EventInfo)
        self.navigationController?.navigationBarHidden = true;
        
        // Search setup
        self.mapSearchBar.delegate = self
        
        // TableView cell
        self.tableView.registerNib(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell");
        
        //Map setup
        let initialLocation = CLLocation(latitude: 32.8811, longitude: -117.2370);
        let regionRadius:CLLocationDistance = 1300;
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, regionRadius*2.0, regionRadius*2.0);
        self.mapView.setRegion(coordinateRegion, animated: true);
        
        let dank = EventMarker(title: "Eric Zhang", subTitle: "Starts in: 69 hrs 69 m", coordinate: initialLocation.coordinate, eventID: "yooYSUWICTOWW")
        self.mapView.addAnnotation(dank)
        
        //Pull events from fb and add to map
        Globals.fb.child("Events").observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            for eachEventSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot]{
                let eventDictionary = eachEventSnapshot.value as! [String:AnyObject]
                let eachEvent = Event.init(eventDict: eventDictionary)
                let currentTime = NSDate().timeIntervalSince1970 * 1000
                var startsIn = durationFromTimeIntervals(startTime: Int(currentTime), endTime: Int(eachEvent.getStartTime()))
                if (startsIn.isEmpty) {
                    startsIn = "This event has already ended."
                }
                else {
                    startsIn = "Starts in: " + startsIn
                }
                let marker = EventMarker(title: eachEvent.getName(), subTitle: startsIn,
                    coordinate: eachEvent.getLocation(), eventID: eachEvent.getEventID())
                self.mapView.addAnnotation(marker)
            }
        })

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
        
        // Make search smarter
        sortFilteredEventNames(searchText)
        
        // Update search table view
        tableView.reloadData()
    }
    
    // Updates the order of filteredEventNames using prefixCompare
    func sortFilteredEventNames(searchText: String) {
        self.searchText = searchText
        filteredEventNames = filteredEventNames.sort(prefixCompare)
    }
    
    // For query "fu", prioritizes "Fundraiser" over "KungFu" and "ful" over "fulllllllll"
    func prefixCompare(eventName1: String, eventName2: String) -> Bool {
        let firstMatch = eventName1.lowercaseString.hasPrefix(self.searchText!.lowercaseString)
        let secondMatch = eventName2.lowercaseString.hasPrefix(self.searchText!.lowercaseString)
        if (firstMatch && !secondMatch) {
            return true
        }
        if (secondMatch && !firstMatch) {
            return false
        }
        return eventName1.endIndex < eventName2.endIndex

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

    
    /* Map stuff-------------------------------------------------------------------------------------*/
    
    private class EventMarker: NSObject, MKAnnotation {
        @objc let title: String?
        let subTitle: String
        @objc let coordinate: CLLocationCoordinate2D
        let eventID: String
        
        init(title: String, subTitle: String, coordinate: CLLocationCoordinate2D, eventID: String) {
            self.title = title;
            self.subTitle = subTitle;
            self.coordinate = coordinate;
            self.eventID = eventID;
            super.init();
        }
        
        @objc var subtitle: String? {
            return self.subTitle;
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is EventMarker {
            let identifier = "Pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            }
            else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: -5)
            }
            
//            let detailView = UIView()
//            let views = ["detailView": detailView]
//            detailView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[detailView(200)]", options: [], metrics: nil, views: views))
//            detailView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[detailView(21)]", options: [], metrics: nil, views: views))
//            let textView = UITextView(frame: CGRect(x: 0, y: -15, width: 200, height: 50))
//            textView.text = "Starts In: 12hrs 59m"
//            textView.sizeToFit()
//            textView.backgroundColor = view.backgroundColor
//            detailView.addSubview(textView)
//            detailView.sizeToFit()
//            view.detailCalloutAccessoryView = detailView
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let eventMarker = view.annotation as! EventMarker
        self.selectedEventID = eventMarker.eventID
        self.performSegueWithIdentifier("openEventInfo", sender: self)
    }
    
    /*-----------------------------------------------------------------------------------------------*/
    
    

    //when going to eventInfo, set the VC's eventID property and hide the bottombar
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //if it's the eventinfo segue, set the event id
        if (segue.identifier == "openEventInfo") {
            (segue.destinationViewController as! EventInfoViewController).hidesBottomBarWhenPushed = true;
            (segue.destinationViewController as! EventInfoViewController).setEventID(self.selectedEventID!);
        }
    }
    

}
