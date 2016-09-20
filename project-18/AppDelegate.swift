//
//  AppDelegate.swift
//  project-18
//
//  Created by Isaac Wang on 7/8/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //T0PB4R C0L0R
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        let statusBar: UIView = UIApplication.sharedApplication().valueForKey("statusBar") as! UIView
        if statusBar.respondsToSelector(Selector("setBackgroundColor:")) {
            //statusBar.backgroundColor = UITableView().separatorColor;
            statusBar.backgroundColor = Globals.COLOR_PRIMARY_DARK
        }
        
        // FIREBASE STARTUP
        FIRApp.configure()
        
        // F4C3B00K ST4RTUP
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true);
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // PULL ALL FRIENDS
        let params = ["fields": "id, first_name, last_name, middle_name, name, email, picture"]
        let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: params)
        request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error != nil {
                //let errorMessage = error.localizedDescription
                /* Handle error */
            }
            else if result.isKindOfClass(NSDictionary){
                /*  handle response */
                //print("\nFriends are : \(result)")
                let friendsArray = result["data"] as! NSArray;
                
                for friend in friendsArray {
                    //print("\nfriend is: \(friend)")
                    Globals.friendsIDToName[friend.valueForKey("id") as! String] = friend.valueForKey("name") as? String
                }
            }
        }
        
        /*Globals.friendsIDToName["1196215920412322"] = "Isaac Christopher Wang"
        Globals.friendsIDToName["1184188798300386"] = "Brian Chan"
        Globals.friendsIDToName["1177156832304841"] = "Ansel Blume"
        Globals.friendsIDToName["1138117392898486"] = "Matthew Ung"
        Globals.friendsIDToName["1131880253542315"] = "Luke Thomas"
        Globals.friendsIDToName["1076100269116381"] = "Eric Zhang"
        Globals.friendsIDToName["1070949549640758"] = "Gates Zeng"*/


        
        // TEST EVENT PUSH
        //let e = Event(name: "First iOS event", description: "This is an iOS-generated event",
                      //creatorID: "1196215920412322", startTime: 69, endTime: 420)
        //e.pushToFirebase();
        
        // TEST EVENT PULL
        /*fb.child("Events").child("yooUPKNKMOWSR").observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let eventDict:NSDictionary = snapshot.value as! [String : AnyObject]
            let pulledEvent:Event = Event(eventDict: eventDict)})*/
        
        // TEST USER PUSH
        //let u = User(userID: "123", userName: "Test")
        //u.pushToFirebase()
        
        // TEST USER PULL
        /*fb.child("Users").child("1196215920412322").observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let userDict:NSDictionary = snapshot.value as! [String : AnyObject]
            let pulledUser:User = User(userDict: userDict)
            //pulledUser.toString()
 
            // TEST USER ADD/REMOVE TRAIL
            //pulledUser.addTrail("abc")
            //pulledUser.removeTrail("abc")
            
            // TEST USER ATTEND/UNATTEND EVENT
            pulledUser.attendEvent("yooDOUXCTVRGU", eventName: "pls2", creatorID: "1196215920412322")
            //pulledUser.unattendEvent("yooDOUXCTVRGU")
        })*/
        
        // TEST NOTIFICATION PUSH
        //let nnf: Notification = NotificationNewFollow(type: Globals.TYPE_NEW_FOLLOW, followerID: "yeet", followerName: "Jim the Follower")
        //nnf.pushToFirebase(["1196215920412322"])
        //let nce: Notification = NotificationCommentEvent(type: Globals.TYPE_COMMENT_EVENT, pictureID: "ayy lmao", eventID: "event id tho", eventName: "dank memes rank streams", userNames: ["Sean the Third Commenter"])
        //nce.pushToFirebase(["1196215920412322"])
        //let nfh: Notification = NotificationFriendHost(type: Globals.TYPE_FRIEND_HOST, pictureID: "pic ID", hostName: "hostName", eventID: "eventId tho2", eventName: "yeet event name2", timeString: "Tuesday at 69:69 PM")
        //nfh.pushToFirebase(["1196215920412322"])
        //let nfh: Notification = NotificationJoinedEvent(type: Globals.TYPE_JOINED_EVENT, pictureID: "picIDTHO", joinedUserName: "James the event joiner", eventID: "lit eventid", eventName: "lit event yo")
        //nfh.pushToFirebase(["1196215920412322"])
        //let nie: Notification = NotificationInviteEvent(type: Globals.TYPE_INVITE_EVENT, pictureID: "picIDFAM", eventID: "event id fam", eventName: "litter lit lit", userNames: ["Ling lo"])
        //nie.pushToFirebase(["1196215920412322"])
        //let nw: Notification = NotificationWelcome(type: Globals.TYPE_WELCOME, userName: "I-Money$$$")
        //nw.pushToFirebase(["1196215920412322"])
        
        // TEST NOTIFICATION PULL
//        fb.child("NotifDatabase").child("1196215920412322").observeSingleEventOfType(FIRDataEventType.Value, withBlock: {
//            (userNotifs) in
//            for notifSnapshot in userNotifs.children {
//                var notif: Notification? = nil
//                let notifDict:NSDictionary = (notifSnapshot as! FIRDataSnapshot).value as! NSDictionary
//                if notifDict.valueForKey("type") as! Int == Globals.TYPE_NEW_FOLLOW {
//                    notif = NotificationNewFollow(notifDict: notifDict)
//                }
//                else if notifDict.valueForKey("type") as! Int == Globals.TYPE_COMMENT_EVENT {
//                    notif = NotificationCommentEvent(notifDict: notifDict)
//                }
//                else if notifDict.valueForKey("type") as! Int == Globals.TYPE_FRIEND_HOST {
//                    notif = NotificationFriendHost(notifDict: notifDict)
//                }
//                else if notifDict.valueForKey("type") as! Int == Globals.TYPE_JOINED_EVENT {
//                    notif = NotificationJoinedEvent(notifDict: notifDict)
//                }
//                else if notifDict.valueForKey("type") as! Int == Globals.TYPE_INVITE_EVENT {
//                    notif = NotificationInviteEvent(notifDict: notifDict)
//                }
//                else if notifDict.valueForKey("type") as! Int == Globals.TYPE_WELCOME {
//                    notif = NotificationWelcome(notifDict: notifDict)
//                }
//                
//                print("\nNotification:\n", notif!.generateMessage())
//
//            }
//        })
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        //fb stuff
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

