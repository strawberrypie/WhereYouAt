//
//  ViewController.swift
//  WhereYouAt
//
//  Created by Kj Drougge on 2014-12-30.
//  Copyright (c) 2014 kj. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet var fbLoginView: FBLoginView!
    
    var firstName: String! = ""
    var lastName: String! = ""
    var email: String! = ""
    var profilePictureID: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.fbLoginView.delegate = self
        //self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        
        
    }
   
    @IBOutlet weak var buttonLogin: UIButton!
    
    @IBAction func buttonClick(sender: AnyObject) {
        var permissions: NSArray = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.logInWithPermissions(permissions) {
            (user: PFUser!, error: NSError!) -> Void in
            if !(user != nil) {
                if error != nil {
                    println("User cancelled FB login")
                }else{
                    println("FB login error: \(error)")
                }
            } else if user.isNew {
                println("User signed up and logged in with Facebook")
                
                if !PFFacebookUtils.isLinkedWithUser(user) {
                    PFFacebookUtils.linkUser(user, permissions:nil, {
                        (succeeded: Bool!, error: NSError!) -> Void in
                        if succeeded.boolValue {
                            NSLog("Woohoo, user logged in with Facebook!")
                        }
                    })
                }
                
                var currentUser = PFUser.currentUser()
                
                currentUser["firstname"] = "kj"
                currentUser["lastname"] = "kj"
                currentUser.email = "test@test"

                
                
                FBRequestConnection.startForMeWithCompletionHandler {
                    (connection, user2, error) -> Void in
                    
                    if error == nil {
                        
                        self.firstName = user2.first_name
                        self.lastName = user2.last_name
                        self.email = user2.objectForKey("email") as String
                        self.profilePictureID = user2.objectID
                        
                        currentUser["firstname"] = self.firstName
                        currentUser["lastname"] = self.lastName
                        currentUser.email = self.email
                        currentUser["profilePictureID"] = self.profilePictureID
                        
                        currentUser.saveInBackground()

                        self.performSegueWithIdentifier("moveToMessages", sender: self)
                        
                        //println("c: \(currentUser.objectId)")
                        //println("f: \(self.firstName), l: \(self.lastName), e: \(self.email)")
                        
                        //self.performSegueWithIdentifier("moveToMessages", sender: self)
                    }
                }
            } else {
                println("User logged in via Facebook")
                var currentUser = PFUser.currentUser()
                self.firstName = currentUser["firstname"] as String
                self.lastName = currentUser["lastname"] as String
                self.email = currentUser.email
                self.profilePictureID = currentUser["profilePictureID"] as String
                
                self.performSegueWithIdentifier("moveToMessages", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "moveToMessages" {
            var messagesVC: MessagesViewController = segue.destinationViewController as MessagesViewController
            messagesVC.firstName = self.firstName
            messagesVC.lastName = self.lastName
            messagesVC.email = self.email
            messagesVC.profilePictureID = self.profilePictureID
        }
    }

    
/*
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        println("Login")
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        println("Username: \(user.name)")
        //self.profilePictureView.profileID = user.objectID
        
        self.firstName = user.first_name
        self.lastName = user.last_name
        
        FBRequestConnection.startForMeWithCompletionHandler {
            (connection, user, error) -> Void in
            
            if error == nil {
                self.email = user.objectForKey("email") as String
                self.profilePictureID = user.objectID
                self.performSegueWithIdentifier("moveToMessages", sender: self)
            }
        }
    }
    
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        println("Logout")
        //self.profilePictureView.profileID = nil
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        println("Error: \(error.localizedDescription)")
    }
*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

