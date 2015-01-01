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
        
        let predicate = NSPredicate(format: "email != '\(self.email)'")
        var query = PFQuery(className: "_User", predicate: predicate)
        var objects = query.findObjects()
        
        for object in objects{
            var s = "profilePictureID"
            println("self.email: \(self.email) email: \(object.email)")
            self.resultsEmail.append(object.email)
            if object.objectForKey(s) == nil {
                self.resultsProfilePicture.append("ca.abernathy")
            } else {
                self.resultsProfilePicture.append(object[s] as String)
            }
            
        }
        
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
        }
    }
    
    // MARK: TableView DELEGATE AND DATASOURCE

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath) as UserCell
        
        otherUsername = self.resultsEmail[indexPath.row]
        otherProfilePictureID = self.resultsProfilePicture[indexPath.row]
        
        self.performSegueWithIdentifier("moveToMessage", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsEmail.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UserCell = tableView.dequeueReusableCellWithIdentifier("Cell") as UserCell
    
        cell.username.text = self.resultsEmail[indexPath.row]
    
        cell.profileImage.profileID = self.resultsProfilePicture[indexPath.row]

        
        cell.newImage.hidden = false
        
        return cell
    }
}