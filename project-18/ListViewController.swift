//
//  ListViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/11/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit
import Firebase

class ListViewController: UIViewController {
    
    @IBOutlet var laterTableView: UITableView!
    @IBOutlet var todayTableView: UITableView!
    @IBOutlet var popularTableView: UITableView!
    @IBAction func showMore(sender: AnyObject) {
        NSLog("show more!");
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fb = Globals.fb;
        var eventArray = [Event]();
        
        fb.child("Events").observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            eventArray.append(Event.init(eventDict: snapshot.value!.dictionaryWithValuesForKeys(Globals.eventFirebaseKeys)));
            NSLog("Loaded one event");
        });
        
        updateTableViews();
    }
    
    func updateTableViews() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}