//
//  LocationSelectViewController.swift
//  project-18
//
//  Created by Eric Zhang on 8/31/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit
import MapKit

class LocationSelectViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapSearchBar: UISearchBar!
    @IBAction func okButtonPress(sender: AnyObject) {
        if (self.selectedAnnotation != nil) {
            //set new loc and push new event
            self.noLocEvent?.setLocation(self.selectedAnnotation!.coordinate);
            self.noLocEvent?.toString();
            self.noLocEvent?.pushToFirebase();
            let alert = UIAlertController(title: "Yay!",
                                          message: "Event successfully made!", preferredStyle: .Alert);
            alert.addAction(UIAlertAction(title: "Swag", style: .Default , handler: successCallback));
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
    func successCallback(alert:UIAlertAction) {self.navigationController?.popToRootViewControllerAnimated(true)}
    private var selectedAnnotation:MKPointAnnotation?;
    var noLocEvent:Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select Location";
        self.navigationController?.navigationBarHidden = false;
        
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
    
    //long press callback
    func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .Began {
            return;
        }
        let touchPoint = gestureRecognizer.locationInView(self.mapView);
        let touchMapCoord = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView);
        let annotation = MKPointAnnotation();
        annotation.coordinate = touchMapCoord;
        
        //remove annotation current annotation if exists and add new annotation from press
        if selectedAnnotation != nil {
            self.mapView.removeAnnotation(self.selectedAnnotation!);
        }
        self.selectedAnnotation = annotation;
        self.mapView.addAnnotation(self.selectedAnnotation!);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func setNoLocEvent(noLocEvent:Event) {
        self.noLocEvent = noLocEvent;
    }

}
