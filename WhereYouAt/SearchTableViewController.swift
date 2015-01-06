//
//  SearchTableViewController.swift
//  WhereYouAt
//
//  Created by Kj Drougge on 2015-01-02.
//  Copyright (c) 2015 kj. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {

    var email: String!
    var profilePictureID: String!
    var otherEmail: String!
    var otherProfilePictureID: String!
    
    var users: [String] = []
    
    var filteredUsers: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getUsers()
        
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUsers(){
        self.users.removeAll(keepCapacity: false)
        
        let predicate = NSPredicate(format: "email != '\(self.email)'")
        var query = PFQuery(className: "_User", predicate: predicate)
        var objects = query.findObjects()
        
        for object in objects{
            self.users.append(object.email)
        }
    }
    
    func filteredContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        self.filteredUsers = self.users.filter({
            (user: String) -> Bool in
            
            let stringMatch = user.lowercaseString.rangeOfString(searchText.lowercaseString)
            
            
            return stringMatch != nil
        })
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filteredContentForSearchText(searchString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filteredContentForSearchText(self.searchDisplayController!.searchBar.text)
        return true
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredUsers.count
        } else {
            return users.count
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell?
        
        // UIAlertController with popup to add / delete friend.
        let predicate = NSPredicate(format: "email == '\(cell?.textLabel?.text)'")
        var query = PFQuery(className: "Friends", predicate: predicate)
        var objects = query.findObjects()
        
        if objects.count > 0 {
            
            var titleOnAlert = ""
            var messageOnAlert = "Do you want to delete \(cell?.textLabel?.text) as a friend?"
            
            var alert = UIAlertController(title: nil, message: messageOnAlert, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Delete", style: .Destructive) {
                (action) in
                
                
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            alert.addAction(cancelAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            var friendsDBTable = PFObject(className: "Friends")
            friendsDBTable["username"] = self.email
            friendsDBTable["isFriendWith"] = cell?.textLabel?.text
            
            
            
            var userQuery = PFQuery(className: "_User")
           
            userQuery.whereKey("email", equalTo: cell?.textLabel!.text)
            var o = userQuery.findObjects()
            
            friendsDBTable["usernameProfileID"] = PFUser.currentUser()["profilePictureID"] as String
            
            for obj in o{
                if obj.objectForKey("profilePictureID") == nil{
                    friendsDBTable["isFriendWithProfileID"] = "ca.abernathy"
                } else {
                    friendsDBTable["isFriendWithProfileID"] = obj["profilePictureID"] as String
                }
            }
            
            
            friendsDBTable["username"] = cell?.textLabel?.text
            friendsDBTable["isFriendWith"] = self.email
            
            userQuery.whereKey("email", equalTo: self.email)
            o = userQuery.findObjects()
            
            /*
            for obj in o{
                if obj.objectForKey("profilePictureID") == nil{
                    friendsDBTable["isFriendWithProfileID"] =
                    friendsDBTable["usernameProfileID"] =
                } else {
                    friendsDBTable["isFriendWithProfileID"] = obj["profilePictureID"] as String
                    friendsDBTable["usernameProfileID"] = PFUser.currentUser()["profilePictureID"] as String
                }
            }

            
            friendsDBTable.saveInBackgroundWithBlock{
                (success: Bool!, error: NSError!) -> Void in
                
                if success.boolValue{
                    println("success")
                    
                }
            }
            */
        }
        
        for object in objects{
            
        }

        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        var user: String!
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            user = filteredUsers[indexPath.row]
        } else {
            user = self.users[indexPath.row]
        }
    
        cell.textLabel!.text = user
        
        
        return cell
    }
}
