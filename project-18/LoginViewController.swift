//
//  LoginViewController.swift
//  project-18
//
//  Created by Eric Zhang on 7/21/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if let _ = FBSDKAccessToken.currentAccessToken() {
            self.performSegueWithIdentifier("mainSegue", sender: self)
        }
        else {
            let loginButton = FBSDKLoginButton();
            loginButton.readPermissions = ["email"]; //lol wut else do we want
            loginButton.center = self.view.center;
            loginButton.delegate = self;
            view.addSubview(loginButton); //ignore warnings
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print(FBSDKAccessToken.currentAccessToken().userID);
        self.performSegueWithIdentifier("mainSegue", sender: self);
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
