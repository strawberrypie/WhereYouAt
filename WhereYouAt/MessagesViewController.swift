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
            self.resultsEmail.append(object.email)
            self.resultsProfilePicture.append(object.profilePictureID)
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
    
        if self.resultsProfilePicture[indexPath.row].isEmpty {
            cell.profileImage.profileID = self.resultsProfilePicture[indexPath.row]
        } else {
            cell.profileImage.profileID = "ca.abernathy"
        }
        
        cell.newImage.hidden = false
        
        return cell
    }
}