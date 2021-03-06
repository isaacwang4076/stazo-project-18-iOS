//
//  LoginViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/21/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet var convergLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
        
    /* Check if user agreed to EULA and pushes agreement if they haven't. 
       Then check if user is logged in, if logged in then pull user and push next view, otherwise show login button */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        //check EULA agreement
        let agreement = NSUserDefaults.standardUserDefaults().boolForKey("EULAAgreement");
        if (!agreement) {
            self.performSegueWithIdentifier("presentEULA", sender: self);
        }
        else {
            //check FB login
            if (FBSDKAccessToken.currentAccessToken() != nil) {
                print("User logged in");
                self.convergLabel.hidden = true;
                handleLogin();
            }
            else {
                let loginButton = FBSDKLoginButton();
                loginButton.readPermissions = ["email"]; //lol wut else do we want
                loginButton.center = self.view.center;
                loginButton.delegate = self;
                view.addSubview(loginButton); //ignore warnings
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /* Delegate methods for login button */
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    //Go to next view upon successful login
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("Login successful");
        
    }
    
    func handleLogin() {
        if FBSDKAccessToken.currentAccessToken() != nil {
            
            print("checking firebase for user");
            //check if user already exists on our database
            Globals.fb.child("Users").observeSingleEventOfType(.Value, withBlock: {
                snapshot in
                
                //if user already exists, pull user and store in app
                if (snapshot.hasChild(FBSDKAccessToken.currentAccessToken().userID)) {
                    print("user exists");
                    let pulledUserDict = snapshot.childSnapshotForPath(FBSDKAccessToken.currentAccessToken().userID).value as! NSDictionary;
                    let me = User(userDict: pulledUserDict);
                    Globals.me = me;
                    Globals.me.printUserInfo();
                    
                    
                    let fb = Globals.fb
                    
                    // PULL ALL EVENTS
                    fb.child("Events").observeEventType(FIRDataEventType.Value, withBlock: { (allEventsSnapshot) in
                        for eventSnapshot in allEventsSnapshot.children.allObjects as! [FIRDataSnapshot] {
                            let eventDict:NSDictionary = eventSnapshot.value as! [String : AnyObject]
                            print("\n", me.blockedUserIDs)
                            print("\n", eventDict["creator_id"] as! String)
                            print("\n", Globals.me.blockedUserIDs.contains(eventDict["creator_id"] as! String))
                            if (!Globals.me.blockedUserIDs.contains(eventDict["creator_id"] as! String)) {
                                Globals.eventsNameToID[eventDict.valueForKeyPath("name") as! String] = eventDict.valueForKeyPath("event_id") as? String
                                Globals.eventsIDToEvent[eventDict.valueForKeyPath("event_id") as! String] = Event(eventDict: eventDict)
                            }
                        }
                        self.performSegueWithIdentifier("mainSegue", sender: self);
                    })
                }
                    
                    //TODO: TEST THIS
                else {
                    print("user doesn't exist");
                    //if user doesn't exist on out database, make a new one from fb info, store in app, push to database
                    FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name"]).startWithCompletionHandler({
                        (connection, result, error) -> Void in
                        if (error == nil) {
                            print(result["name"]);
                            
                            //Create user, save to app info, push to our database, and segue to main view
                            let me = User(userID: result["id"] as! String, userName: result["name"] as! String);
                            Globals.me = me;
                            print("New user----");
                            Globals.me.printUserInfo();
                            me.pushToFirebase();
                            
                            
                            // Send out welcome Notification
                            let nw: Notification = NotificationWelcome(type: Globals.TYPE_WELCOME, userName: me.getUserName())
                            nw.pushToFirebase([me.getUserID()])
                            
                            
                            
                            let fb = Globals.fb
                            
                            // PULL ALL EVENTS
                            fb.child("Events").observeEventType(FIRDataEventType.Value, withBlock: { (allEventsSnapshot) in
                                for eventSnapshot in allEventsSnapshot.children.allObjects as! [FIRDataSnapshot] {
                                    let eventDict:NSDictionary = eventSnapshot.value as! [String : AnyObject]
                                    
                                    if (!Globals.me.blockedUserIDs.contains(eventDict["creator_id"] as! String)) {
                                        Globals.eventsNameToID[eventDict.valueForKeyPath("name") as! String] = eventDict.valueForKeyPath("event_id") as? String
                                        Globals.eventsIDToEvent[eventDict.valueForKeyPath("event_id") as! String] = Event(eventDict: eventDict)
                                    }
                                }
                                self.performSegueWithIdentifier("mainSegue", sender: self);
                            })
                        }
                    });
                }
                
            });
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
