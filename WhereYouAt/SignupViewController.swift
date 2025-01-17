//
//  SignupViewController.swift
//  WhereYouAt
//
//  Created by Kj Drougge on 2014-12-31.
//  Copyright (c) 2014 kj. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signupBtn_clicked(sender: AnyObject) {
        var user = PFUser()
        
        user.username = self.emailTextField.text
        user.email = self.emailTextField.text
        user["firstname"] = self.firstnameTextField.text
        user["lastname"] = self.lastnameTextField.text
        user.password = self.passwordTextField.text
    
        user.signUpInBackgroundWithBlock {
            (succeded: Bool!, signupError: NSError!) -> Void in
            
            if signupError == nil{
                println("Signup")
                
                var installation: PFInstallation = PFInstallation.currentInstallation()
                installation["user"] = PFUser.currentUser()
                installation.saveInBackground()
                
                self.performSegueWithIdentifier("moveToMessages2", sender: self)
            } else {
                println("Can't signup")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "moveToMessages2" {
            var messagesVC: MessagesViewController = segue.destinationViewController as MessagesViewController
            messagesVC.firstName = self.firstnameTextField.text
            messagesVC.lastName = self.lastnameTextField.text
            messagesVC.email = self.emailTextField.text
            messagesVC.profilePictureID = "ca.abernathy"
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        firstnameTextField.resignFirstResponder()
        lastnameTextField.resignFirstResponder()
        
        return true
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
}
