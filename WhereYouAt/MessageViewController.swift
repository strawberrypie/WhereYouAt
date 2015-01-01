//
//  MessageViewController.swift
//  WhereYouAt
//
//  Created by Kj Drougge on 2014-12-31.
//  Copyright (c) 2014 kj. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var otherUsername: String!
    var otherProfilePictureID: String!
    
    @IBOutlet weak var messageTable: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendLocationBtn: UIBarButtonItem!
    
    var messages: [String] = ["test", "kul" ,"jul"]
    
    var t: Bool! = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = otherUsername
        
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
    

    
    // MARK: TableView DELEGATE AND DATASOURCE
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //var cell:UITableViewCell = self.messageTable.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        //cell.textLabel?.text = self.messages[indexPath.row]
        var cell: MessageCell!
        
        if t.boolValue {
            cell = self.messageTable.dequeueReusableCellWithIdentifier("receiverCell") as MessageCell
            cell.receiverTextView.text = "Test"
            cell.receiverBtn.hidden = true
            t = false
        } else {
            cell = self.messageTable.dequeueReusableCellWithIdentifier("senderCell") as MessageCell
            cell.senderTextView.text = "textkjasndkjasn kdan ksdnal sjdna skjdnal jsndlaksdnkasndkansd asndk amsldkm alksm dlak mldskaml skdmal aksmd lamdl amsl"
            
            t = true
        }
        
        
        return cell
    }

}
