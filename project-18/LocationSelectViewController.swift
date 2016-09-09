//
//  LocationSelectViewController.swift
//  project-18
//
//  Created by Eric Zhang on 8/31/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit
import MapKit

class LocationSelectViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    /* UI ---------------------------------------*/
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapSearchBar: UISearchBar!
    @IBOutlet var mapSearchTable: UITableView!
    @IBOutlet var mapSearchTableHeightConstraint: NSLayoutConstraint!
    @IBAction func okButtonPress(sender: AnyObject) {
        if (self.selectedAnnotation != nil) {
            //set new loc and push new event
            self.noLocEvent?.setLocation(self.selectedAnnotation!.coordinate);
            self.noLocEvent?.toString();
            self.noLocEvent?.pushToFirebase();
            let alert = UIAlertController(title: "Yay!",
                                          message: "Event successfully made!", preferredStyle: .Alert);
            alert.addAction(UIAlertAction(title: "Swag", style: .Default , handler: {
                alert in
                self.tabBarController?.selectedIndex = 0; //go back to map
                self.navigationController?.popToRootViewControllerAnimated(true); //go back a view for next use
            }));
            self.presentViewController(alert, animated: true, completion: nil);
        }
        //no loc selected
        else {
            let alert = UIAlertController(title: "Oops!",
                                          message: "Select a location or people won't know where to go!", preferredStyle: .Alert);
            alert.addAction(UIAlertAction(title: "OK", style: .Default , handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
        }
    }
    /*---------------------------------------------*/
    
    private var selectedAnnotation:MKPointAnnotation?;
    private var noLocEvent:Event?
    private var locationSearchResults:[MKMapItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select Location";
        self.navigationController?.navigationBarHidden = false;
        self.mapSearchBar.returnKeyType = .Done;
        self.mapSearchBar.enablesReturnKeyAutomatically = false;
        
        //Initial center location
        let initialLocation = CLLocation(latitude: 32.8811, longitude: -117.2370);
        let regionRadius:CLLocationDistance = 1300;
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, regionRadius*2.0, regionRadius*2.0);
        self.mapView.setRegion(coordinateRegion, animated: true);
        
        //setup long press recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(LocationSelectViewController.handleLongPress(_:)));
        longPress.minimumPressDuration = 1.0;
        self.mapView.addGestureRecognizer(longPress);
    }
    
    /* Long Press callback---------------------*/
    func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .Began {
            return;
        }
        let touchPoint = gestureRecognizer.locationInView(self.mapView);
        let touchMapCoord = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView);
        self.addCoordinate(touchMapCoord);
    }
    
    /* Adds a coordinate to map and replace last one if it exists */
    func addCoordinate(coordinate:CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation();
        annotation.coordinate = coordinate;
        
        //remove annotation current annotation if exists and add new annotation from press
        if selectedAnnotation != nil {
            self.mapView.removeAnnotation(self.selectedAnnotation!);
        }
        self.selectedAnnotation = annotation;
        self.mapView.addAnnotation(self.selectedAnnotation!);
    }
    
    /* Search Bar delegate----------------------*/
    /* Search for location based on text in search bar and reload mapSearchTable with locationSearchResults populated */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = searchText;
            request.region = self.mapView.region;
            let search = MKLocalSearch(request: request);
            search.startWithCompletionHandler({
                (response, error) in
                if let mapItems = response?.mapItems {
                    self.locationSearchResults = mapItems;
                    self.mapSearchTable.hidden = false;
                    self.mapSearchTable.reloadData();
                }
            })
        }
        else {
            self.locationSearchResults = [];
            self.mapSearchTable.hidden = true;
        }
    }
    
    /* Resign search bar first responder and hide table when done button pressed */
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.mapSearchTable.hidden = true;
        searchBar.resignFirstResponder();
    }
    
    /* Table View data source and delegates -----------------*/
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.mapSearchTableHeightConstraint.constant = CGFloat(self.locationSearchResults.count * 44);
        print("Number: \(self.locationSearchResults.count)")
        return self.locationSearchResults.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //show info based off of location search results in each cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell");
        cell!.textLabel?.text = self.locationSearchResults[indexPath.item].name;
        cell!.detailTextLabel?.text = self.parseAddress(self.locationSearchResults[indexPath.item].placemark);
        return cell!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //add coordinate to map upon selection of a cell and also hide the table view
        self.addCoordinate(self.locationSearchResults[indexPath.item].placemark.coordinate);
        self.mapSearchBar.resignFirstResponder();
        self.mapSearchTable.hidden = true;
    }
    

    /* Returns a better formatted string from placemark for cell subtitle */
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNoLocEvent(noLocEvent:Event) {
        self.noLocEvent = noLocEvent;
    }
}
