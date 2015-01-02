//
//  MessageViewController.swift
//  WhereYouAt
//
//  Created by Kj Drougge on 2014-12-31.
//  Copyright (c) 2014 kj. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var username: String!
    var profilePictureID: String!
    var otherUsername: String!
    var otherProfilePictureID: String!
    
    @IBOutlet weak var messageTable: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
  
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendLocationBtn: UIBarButtonItem!
    @IBOutlet weak var messageView: UIView!
    
    var senderMessages: [String] = []
    var theMessages: [String] = []

    var messageTableOriginalY: CGFloat = 0
    var messageTextFieldOriginalY: CGFloat = 0
    var sendBtnOriginalY: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = otherUsername
        
        messageTable.delegate = self
        messageTable.dataSource = self
        
        getMessages()
        
        messageTableOriginalY = self.messageTable.frame.origin.y
        
        messageTextFieldOriginalY = self.messageTextField.frame.origin.y
        sendBtnOriginalY = self.sendBtn.frame.origin.y
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        let tapScrollViewGesture = UITapGestureRecognizer(target: self, action: "didTapScrollView")
        tapScrollViewGesture.numberOfTapsRequired = 1
        messageTable.addGestureRecognizer(tapScrollViewGesture)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func didTapScrollView(){
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        messageTextField.resignFirstResponder()
        return true
    }
    
    func keyboardWasShown(notification: NSNotification){
        let dict: NSDictionary = notification.userInfo!
        let s: NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as NSValue
        let rect: CGRect = s.CGRectValue()
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
            
            self.messageTable.frame.origin.y = self.messageTableOriginalY - rect.height
            self.messageTextField.frame.origin.y = self.messageTextFieldOriginalY - rect.height
            self.sendBtn.frame.origin.y = self.sendBtnOriginalY - rect.height
            
            var bottomOffset: CGPoint = CGPointMake(0, self.messageTable.contentSize.height - self.messageTable.bounds.size.height)
            self.messageTable.setContentOffset(bottomOffset, animated: false)
            
            }, completion: {
                (finished: Bool!) in
                //
        })
    }
    
    func keyboardWillHide(notification: NSNotification){
        let dict: NSDictionary = notification.userInfo!
        let s: NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as NSValue
        let rect: CGRect = s.CGRectValue()
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
            
            self.messageTable.frame.origin.y = self.messageTableOriginalY
            self.messageTextField.frame.origin.y = self.messageTextFieldOriginalY
            self.sendBtn.frame.origin.y = self.sendBtnOriginalY
            
            var bottomOffset: CGPoint = CGPointMake(0, self.messageTable.contentSize.height - self.messageTable.bounds.size.height)
            self.messageTable.setContentOffset(bottomOffset, animated: false)
            
            }, completion: {
                (finished: Bool!) in
                //
        })
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
        var cell: MessageCell!
        
        if self.senderMessages[indexPath.row] == self.username {
            cell = self.messageTable.dequeueReusableCellWithIdentifier("receiverCell") as MessageCell
            cell.receiverTextView.text = theMessages[indexPath.row]
            cell.receiverBtn.hidden = true
            
        } else {
            cell = self.messageTable.dequeueReusableCellWithIdentifier("senderCell") as MessageCell
            cell.senderTextView.text = theMessages[indexPath.row]
            cell.senderBtn.hidden = true
        }
        
        return cell
    }

}
