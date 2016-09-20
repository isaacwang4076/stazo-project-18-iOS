//
//  EULAViewController.swift
//  project-18
//
//  Created by Eric Zhang on 9/14/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit

class EULAViewController: UIViewController {

    @IBOutlet var eulaTextView: UITextView!
    /* Set nsuserdefaults for EULA agreement to true and go back to login screen */
    @IBAction func agreeToEULA(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "EULAAgreement");
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //fix the textview bug
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        self.eulaTextView.setContentOffset(CGPointZero, animated: true);
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
