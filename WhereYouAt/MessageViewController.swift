//
//  MessageViewController.swift
//  WhereYouAt
//
//  Created by Kj Drougge on 2014-12-31.
//  Copyright (c) 2014 kj. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var username: String!
    var profilePictureID: String!
    var otherUsername: String!
    var otherProfilePictureID: String!
    
    @IBOutlet weak var messageTable: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
  
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendLocationBtn: UIBarButtonItem!
    
    var messages: [String] = ["test", "kul" ,"jul"]
    var senderMessages: [String] = []
    var theMessages: [String] = []
    
    var t: Bool! = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = otherUsername
        
        messageTable.delegate = self
        messageTable.dataSource = self
        
        getMessages()
        
        //self.messageTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        /*
        for var i = 3; i < 20; i++ {
            //messages.append("asd")
            
            messages.insert("asd", atIndex: 0)
            self.messageTable.reloadData()
        }
        */
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMessages(){
        
        let innerP1 = NSPredicate(format: "sender = '\(username)' AND receiver = '\(otherUsername)'")
        var innerQ1: PFQuery = PFQuery(className: "Messages", predicate: innerP1)
        
        let innerP2 = NSPredicate(format: "sender = '\(otherUsername)' AND receiver = '\(username)'")
        var innerQ2: PFQuery = PFQuery(className: "Messages", predicate: innerP2)
        
        var query = PFQuery.orQueryWithSubqueries([innerQ1, innerQ2])
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if error == nil {
                for object in objects {
                    self.senderMessages.insert(object.objectForKey("sender") as String, atIndex: 0)
                    self.theMessages.insert(object.objectForKey("message") as String, atIndex: 0)
                    
                    //self.senderMessages.append(object.objectForKey("sender") as String)
                    //self.theMessages.append(object.objectForKey("message") as String)
                    
                }
                self.messageTable.reloadData()
                
                
                /*
                for var i = 0; i < self.theMessages.count; i++ {
                //for var i = 10; i >= 0; i-- {
                    if self.senderMessages[i] == self.username {
                        
                    } else {
                        
                    }
                }*/
            }
            
            
        }
        
        
        
    }

    @IBAction func sendBtn_click(sender: AnyObject) {
        
        if messageTextField.text == ""{
            println("No text")
        } else {
            
            
            
            var messageDBTable = PFObject(className: "Messages")
            messageDBTable["sender"] = username
            messageDBTable["receiver"] = otherUsername
            messageDBTable["message"] = self.messageTextField.text
            messageDBTable.saveInBackgroundWithBlock{
                (success: Bool!, error: NSError!) -> Void in
                
                if success.boolValue{
                    self.senderMessages.append(self.username)
                    self.theMessages.append(self.messageTextField.text)
                    
                    self.messageTable.reloadData()
                    
                    self.messageTable.setContentOffset(CGPointMake(0, self.messageTable.contentSize.height - self.messageTable.bounds.size.height), animated: false)
                    
                    self.messageTextField.text = ""
                }
            }
            
            
            
            //println("msg: \(messageTextField.text)")
            //senderMessages.insert(username, atIndex: 0)
            //theMessages.insert(messageTextField.text, atIndex: 0)
            
        }
        
    }
    
    // MARK: TableView DELEGATE AND DATASOURCE
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //var cell:UITableViewCell = self.messageTable.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        //cell.textLabel?.text = self.messages[indexPath.row]
        var cell: MessageCell!
        
        if self.senderMessages[indexPath.row] == self.username {
            cell = self.messageTable.dequeueReusableCellWithIdentifier("receiverCell") as MessageCell
            cell.receiverTextView.text = theMessages[indexPath.row] //"Test"
            cell.receiverBtn.hidden = true
            //t = false
        } else {
            cell = self.messageTable.dequeueReusableCellWithIdentifier("senderCell") as MessageCell
            cell.senderTextView.text = theMessages[indexPath.row] //"textkjasndkjasn kdan ksdnal sjdna skjdnal jsndlaksdnkasndkansd asndk amsldkm alksm dlak mldskaml skdmal aksmd lamdl amsl"
            cell.senderBtn.hidden = true
            
            //t = true
        }
        
        
        return cell
    }

}
