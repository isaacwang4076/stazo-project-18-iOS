//
//  NotificationViewController.swift
//  project-18
//
//  Created by Isaac Wang on 8/5/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class NotificationViewController: UIViewController {
    
    let fb = Globals.fb
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func pullAndDisplayNotifications() {
        fb.child("NotifDatabase").child("1196215920412322").observeSingleEventOfType(FIRDataEventType.Value, withBlock: {
                        (userNotifs) in
                        for notifSnapshot in userNotifs.children {
                            var notif: Notification? = nil
                            let notifDict:NSDictionary = (notifSnapshot as! FIRDataSnapshot).value as! NSDictionary
                            if notifDict.valueForKey("type") as! Int == Globals.TYPE_NEW_FOLLOW {
                                notif = NotificationNewFollow(notifDict: notifDict)
                            }
                            else if notifDict.valueForKey("type") as! Int == Globals.TYPE_COMMENT_EVENT {
                                notif = NotificationCommentEvent(notifDict: notifDict)
                            }
                            else if notifDict.valueForKey("type") as! Int == Globals.TYPE_FRIEND_HOST {
                                notif = NotificationFriendHost(notifDict: notifDict)
                            }
                            else if notifDict.valueForKey("type") as! Int == Globals.TYPE_JOINED_EVENT {
                                notif = NotificationJoinedEvent(notifDict: notifDict)
                            }
                            else if notifDict.valueForKey("type") as! Int == Globals.TYPE_INVITE_EVENT {
                                notif = NotificationInviteEvent(notifDict: notifDict)
                            }
                            else if notifDict.valueForKey("type") as! Int == Globals.TYPE_WELCOME {
                                notif = NotificationWelcome(notifDict: notifDict)
                            }
                           
                            print("\nNotification:\n", notif!.generateMessage())
            
                        }
                    })

    }
    
}