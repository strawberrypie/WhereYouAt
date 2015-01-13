//
//  ViewController.swift
//  WhereYouAt
//
//  Created by Kj Drougge on 2014-12-30.
//  Copyright (c) 2014 kj. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    var firstName: String! = ""
    var lastName: String! = ""
    var email: String! = ""
    var profilePictureID: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PFUser.currentUser() != nil {
            var u = PFUser.currentUser()
            
            self.email = u.email
            self.firstName = u["firstname"] as String
            self.lastName = u["lastname"] as String
            
            if u["profilePictureID"] != nil {
                self.profilePictureID = u["profilePictureID"] as String
            } else {
                self.profilePictureID = "ca.abernathy"
            }
            
            self.performSegueWithIdentifier("moveToMessages", sender: self)
        }
        
        let tapScrollViewGesture = UITapGestureRecognizer(target: self, action: "didTapScrollView")
        tapScrollViewGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapScrollViewGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.hidesBackButton = true
        usernameText.text = ""
        passwordText.text = ""
    }

    func didTapScrollView(){
        self.view.endEditing(true)
    }

    @IBOutlet weak var buttonLogin: UIButton!
    
    @IBAction func signupButton(sender: AnyObject) {
        performSegueWithIdentifier("moveToSignup", sender: self)
    }
    
    @IBAction func loginNormal(sender: AnyObject) {
        
        // Normal login with username + password created with the apps signup.
        PFUser.logInWithUsernameInBackground(usernameText.text, password: passwordText.text) {
            (user: PFUser!, loginError: NSError!) -> Void in
            
            if loginError == nil {
                println("Log in")
                
                self.email = user.email
                self.firstName = user["firstname"] as String
                self.lastName = user["lastname"] as String
                
                // Install and register the current user to be able to receive push notifications.
                var installation: PFInstallation = PFInstallation.currentInstallation()
                installation["user"] = PFUser.currentUser()
                // If exist, do nothing.
                installation.saveInBackground()
                
                self.performSegueWithIdentifier("moveToMessages", sender: self)
                
            } else {
                println("Can't log in")
            }
        }
    }
    
    @IBAction func buttonClick(sender: AnyObject) {
        // Set permissions for what the app is able to use from the users facebook page.
        var permissions: NSArray = ["public_profile", "email", "user_friends"]
        
        // Login with facebook.
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
                
                var currentUser = PFUser.currentUser()
            
                // If the user is new in the Parse DB, save all the info needed to create an 
                // account and then move to the messages.
                
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
                        
                        var installation: PFInstallation = PFInstallation.currentInstallation()
                        installation["user"] = PFUser.currentUser()
                        installation.saveInBackground()
                        
                        self.performSegueWithIdentifier("moveToMessages", sender: self)
                    }
                }
            } else {
                println("User logged in via Facebook")
                var currentUser = PFUser.currentUser()
                self.firstName = currentUser["firstname"] as String
                self.lastName = currentUser["lastname"] as String
                self.email = currentUser.email
                self.profilePictureID = currentUser["profilePictureID"] as String
                
                var installation: PFInstallation = PFInstallation.currentInstallation()
                installation["user"] = PFUser.currentUser()
                installation.saveInBackground()
                
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

