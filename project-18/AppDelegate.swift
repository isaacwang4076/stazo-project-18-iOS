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
        
        // FIREBASE STARTUP
        FIRApp.configure()
        
        // TEST EVENT PUSH
        //let e = Event(name: "First iOS event", description: "This is an iOS-generated event",
                      //creatorID: "1196215920412322", startTime: 69, endTime: 420)
        //e.pushToFirebase();
        
        // TEST EVENT PULL
        Globals.fb.child("Events").child("yooUPKNKMOWSR").observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let eventDict:NSDictionary = snapshot.value as! [String : AnyObject]
            let pulledEvent:Event = Event(eventDict: eventDict)
            pulledEvent.toString()
        })
        
        // TEST USER PUSH
        //let u = User(userID: "123", userName: "Test")
        //u.pushToFirebase()
        
        // TEST USER PULL
        Globals.fb.child("Users").child("1196215920412322").observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let userDict:NSDictionary = snapshot.value as! [String : AnyObject]
            let pulledUser:User = User(userDict: userDict)
            pulledUser.toString()
        })
        
        return true
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

