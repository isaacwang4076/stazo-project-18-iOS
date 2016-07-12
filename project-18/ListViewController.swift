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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let fb = FIRDatabase.database().reference();
        fb.child("Event").observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            print("\(snapshot.key) -> \(snapshot.value)");
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