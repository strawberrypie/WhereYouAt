//
//  MessagesViewController.swift
//  WhereYouAt
//
//  Created by Kj Drougge on 2014-12-30.
//  Copyright (c) 2014 kj. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var usersTable: UITableView!
    
    var firstName: String!
    var lastName: String!
    var email: String!
    var profilePictureID: String!
    
    var otherUsername: String!
    var otherProfilePictureID: String!
    
    var resultsEmail: [String]! = []
    var resultsProfilePicture: [String]! = []
    //var resultsFirstname: [String]! = []
    //var resultsLastname: [String]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultsEmail.removeAll(keepCapacity: false)
        self.resultsProfilePicture.removeAll(keepCapacity: false)
        
        
        /*
        let predicate = NSPredicate(format: "username == '\(self.email)'")
        var query = PFQuery(className: "Friends", predicate: predicate)
        var objects = query.findObjects()
        
        for object in objects{
            self.resultsEmail.append(object["isFriendWith"] as String)
            if object.objectForKey("isFriendWithProfileID") == nil{
                self.resultsProfilePicture.append("ca.abernathy")
            } else {
                self.resultsProfilePicture.append(object["isFriendWithProfileID"] as String)
            }
        }
        
        */
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showNewMessageImage", name: "showNewImage", object: nil)
        
        let predicate = NSPredicate(format: "email != '\(self.email)'")
        var query = PFQuery(className: "_User", predicate: predicate)
        var objects = query.findObjects()
        for object in objects{
            self.resultsEmail.append(object.email)
            if object.objectForKey("profilePictureID") == nil {
                self.resultsProfilePicture.append("ca.abernathy")
            } else {
                self.resultsProfilePicture.append(object["profilePictureID"] as String)
            }
        }
        
        
        
        self.usersTable.reloadData()
    }
    
    func showNewMessageImage(){
        isNewMessage = true
        self.usersTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "moveToMessage" {
            var messageVC: MessageViewController = segue.destinationViewController as MessageViewController
            
            messageVC.otherUsername = self.otherUsername
            messageVC.otherProfilePictureID = self.otherProfilePictureID
            messageVC.username = self.email
            messageVC.profilePictureID = self.profilePictureID
        } else if segue.identifier == "moveToSearchVC" {
            var search: SearchTableViewController = segue.destinationViewController as SearchTableViewController
            search.email = self.email
            search.profilePictureID = self.profilePictureID
        }
    }
    
    @IBAction func searchBtn_clicked(sender: AnyObject) {
         //self.performSegueWithIdentifier("moveToSearchVC", sender: self)
    }
        
    @IBAction func logoutBtn_clicked(sender: AnyObject) {
        PFUser.logOut()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: TableView DELEGATE AND DATASOURCE

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath) as UserCell
        
        otherUsername = self.resultsEmail[indexPath.row]
        otherProfilePictureID = self.resultsProfilePicture[indexPath.row]
        
        cell.newImage.hidden = true
        
        self.performSegueWithIdentifier("moveToMessage", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsEmail.count
    }
    
    var isNewMessage: Bool! = false
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UserCell = tableView.dequeueReusableCellWithIdentifier("Cell") as UserCell
    
        cell.username.text = self.resultsEmail[indexPath.row]
        cell.profileImage.profileID = self.resultsProfilePicture[indexPath.row]
        
        if isNewMessage.boolValue {
            cell.newImage.hidden = false
        } else {
            cell.newImage.hidden = true
        }
        
        return cell
    }
}