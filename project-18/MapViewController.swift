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
UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var tableView: UITableView!           // The table view for search results
    @IBOutlet weak var mapSearchBar: UISearchBar!   // The search bar
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var mapView: MKMapView!
    
    var filteredEventNames = [String]()             // Event names that fit the query
    var selectedEventID: String?                    // The eventID of the selected event
    var searchText: String?                         // Search query, used for sorting
    let locationManager = CLLocationManager();      // To get user location
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Search setup
        self.mapSearchBar.delegate = self
        self.mapSearchBar.returnKeyType = .Done;
        self.mapSearchBar.enablesReturnKeyAutomatically = false;
        
        // TableView cell
        self.tableView.registerNib(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell");
        
        //Map setup
        //default to UCSD for map center
        let initialLocation = CLLocation(latitude: 32.8811, longitude: -117.2370);
        let regionRadius:CLLocationDistance = 1300;
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, regionRadius*2.0, regionRadius*2.0);
        self.mapView.setRegion(coordinateRegion, animated: true);
        
        //ask for location permission and update location if granted
        self.locationManager.requestWhenInUseAuthorization();
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.startUpdatingLocation();
        
        let dank = EventMarker(title: "Eric Zhang", subTitle: "Starts in: 69 hrs 69 m", coordinate: initialLocation.coordinate, eventID: "yooYSUWICTOWW")
        self.mapView.addAnnotation(dank)
        
        // Check for NotificationEventToday
        addEventTodayNotifications()
        //Globals.me.blockUser("1076100269116381")
    }
    
    /* Call back to update user location and center map, ending location services after one update */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = manager.location?.coordinate;
        
        if (userLocation != nil) {
            /*let regionRadius:CLLocationDistance = 1300;
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation!, regionRadius*2.0, regionRadius*2.0);
            self.mapView.setRegion(coordinateRegion, animated: true);
            self.locationManager.stopUpdatingLocation();*/
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.startUpdatingLocation();
        
        //always hide nav bar when view appearing
        self.navigationController?.navigationBarHidden = true;
        
        updateEvents();
    }
    
    // Checks to see if there are events you've joined happening today
    // If there are, adds those Notifications to the database
    // Kinda jank, should be handled by script, but whatever
    
    func addEventTodayNotifications() {
        
        // ADD EVENTS TODAY NOTIFICATION
        for eventID in Globals.me.attendingEvents {
            // The event we are looking at
            let event = Globals.eventsIDToEvent[eventID]
            
            // Event start time - current time
            let difference = Int(event!.getStartTime()) - Int(NSDate().timeIntervalSince1970 * 1000)
            
            // If the event hasn't started already and is happening in less than 10 hours
            if (difference > 0 &&
                difference < 10 * 60 * 60 * 1000) {
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                
                let timeString = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: NSTimeInterval(event!.getStartTime())/1000))
                
                let net = NotificationEventToday(type: Globals.TYPE_EVENT_TODAY, pictureID: "0", timeString: timeString, eventID: eventID, eventName: event!.getName())
                net.pushToFirebase([Globals.me.getUserID()])
            }
        }
    }
    
    func updateEvents() {
        print("event refresh");
        //Pull events from fb and add to map
        //clear current map view pins
        self.mapView.removeAnnotations(self.mapView.annotations);
        
        for eachEvent in Globals.eventsIDToEvent.values {
            //Figure out time till
            let currentTime = NSDate().timeIntervalSince1970 * 1000
            
            //set startsIn to "x h and x min" before event starts
            var length:Int64 = Int64(eachEvent.getStartTime()) - Int64(currentTime) //length till start
            let hoursUntilStart = length/(1000*60*60)
            
            var timeText = "";
            //see if event has started
            if (length < 0) {
                //event has either started or ended if starts in is empty, so compare with end time now
                length = Int64(eachEvent.getEndTime()) - Int64(currentTime); //length till end
                if (length < 0) {
                    //still empty means event has already ended
                    timeText = "This event has already ended."
                }
                else {
                    //event ends in "x h and x min"
                    var text = durationFromTimeIntervals(startTime: Int64(currentTime), endTime: Int64(eachEvent.getEndTime()));
                    if (text.isEmpty) {
                        text = "Just ended!"
                    }
                    timeText = "Ends in: " + text
                }
            }
            else {
                var text = durationFromTimeIntervals(startTime: Int64(currentTime), endTime: Int64(eachEvent.getStartTime()))
                if (text.isEmpty) {
                    text = "Starting!"
                }
                timeText = "Starts in: " + text
            }
            
            //add marker to the map only if under 2 hours
            if (hoursUntilStart < 2) {
                let marker = EventMarker(title: eachEvent.getName(), subTitle: timeText,
                                         coordinate: eachEvent.getLocation(), eventID: eachEvent.getEventID())
                self.mapView.addAnnotation(marker)
            }
        }
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
        self.tableView.hidden = false;
        self.tableView.reloadData()
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
    
    /* Resign first responder and hide table view if "Done" button is pressed */
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder();
        self.tableView.hidden = true;
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.tableView.hidden = false;
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        self.mapSearchBar.resignFirstResponder();
        tableView.hidden = true;
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
