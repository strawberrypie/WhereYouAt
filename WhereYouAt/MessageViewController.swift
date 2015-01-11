//
//  MessageViewController.swift
//  WhereYouAt
//
//  Created by Kj Drougge on 2014-12-31.
//  Copyright (c) 2014 kj. All rights reserved.
//

import UIKit
import MapKit

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate {

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
    var theLocations: [CLLocation] = []
    
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
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getMessagesFunc", name: "getMessages", object: nil)
    }
    
    func getMessagesFunc(){
        getMessages()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation() 
        
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
    }
    
    func getMessages(){
        self.senderMessages.removeAll(keepCapacity: false)
        self.theMessages.removeAll(keepCapacity: false)
        self.theLocations.removeAll(keepCapacity: false)
        
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
                    
                    if object.objectForKey("message") as String == "" && object.objectForKey("location") != nil{
                        self.senderMessages.insert(object.objectForKey("sender") as String, atIndex: 0)
                        self.theMessages.insert("My location", atIndex: 0)
                        var g: PFGeoPoint = object.objectForKey("location") as PFGeoPoint
                        self.theLocations.insert(CLLocation(latitude: g.latitude, longitude: g.longitude), atIndex: 0)
                    } else {
                        self.senderMessages.insert(object.objectForKey("sender") as String, atIndex: 0)
                        self.theMessages.insert(object.objectForKey("message") as String, atIndex: 0)
                        self.theLocations.insert(CLLocation(latitude: 0.0, longitude: 0.0), atIndex: 0)
                    }
                }
                
                self.messageTable.setContentOffset(CGPointMake(0, self.messageTable.contentSize.height - self.messageTable.bounds.size.height), animated: false)
                self.messageTable.reloadData()
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
                    
                    var uQuery: PFQuery = PFUser.query()
                    uQuery.whereKey("email", equalTo: self.otherUsername)
                    
                    var pushQuery: PFQuery = PFInstallation.query()
                    pushQuery.whereKey("user", matchesQuery: uQuery)
                    
                    var push: PFPush = PFPush()
                    push.setQuery(pushQuery)
                    push.setMessage("New message from \(self.username)")
                    push.sendPush(nil)
                    println("Push sent")
                    
                    self.senderMessages.append(self.username)
                    self.theMessages.append(self.messageTextField.text)
                    self.theLocations.append(CLLocation(latitude: 0.0, longitude: 0.0))
                    
                    self.messageTable.reloadData()
                    
                    self.messageTable.setContentOffset(CGPointMake(0, self.messageTable.contentSize.height - self.messageTable.bounds.size.height), animated: false)
                    
                    self.messageTextField.text = ""
                }
            }
        }
    }
    
    func startLocating(notification: NSNotification){
        var d: Dictionary = notification.userInfo!
        println("test: \(d)")
        
        var messageDBTable = PFObject(className: "Messages")
        messageDBTable["sender"] = username
        messageDBTable["receiver"] = otherUsername
        messageDBTable["message"] = ""
        messageDBTable["location"] = PFGeoPoint(location: CLLocation(latitude: d["latitude"] as Double, longitude: d["longitude"] as Double))
        messageDBTable.saveInBackgroundWithBlock{
            (success: Bool!, error: NSError!) -> Void in
            
            if success.boolValue{
                self.senderMessages.append(self.username)
                self.theMessages.append("<- My location")
                self.theLocations.append(CLLocation(latitude: d["latitude"] as Double, longitude: d["longitude"] as Double))
                
                self.messageTable.setContentOffset(CGPointMake(0, self.messageTable.contentSize.height - self.messageTable.bounds.size.height), animated: false)
                
                self.messageTable.reloadData()
                
                NSNotificationCenter.defaultCenter().removeObserver(self, name: "ForceUpdateLocation", object: nil)
            }
        }
    }
    
    @IBAction func sendLocation_click(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: ("startLocating:"), name: "ForceUpdateLocation", object: nil)
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()

        self.startUpdatingLocation()
    }
    
    let locationManager = CLLocationManager()
    var latitude: Double! = 0.0
    var longitude: Double! = 0.0
    
    func startUpdatingLocation(){
        if CLLocationManager.locationServicesEnabled(){
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func recieverBtn_clicked(sender: AnyObject) {
        var button = sender as UIButton
        var index = button.tag
        
        sendLatitude = theLocations[index].coordinate.latitude
        sendLongitude = theLocations[index].coordinate.longitude
        
        performSegueWithIdentifier("moveToMap", sender: self)
    }
    
    @IBAction func senderBtn_clicked(sender: AnyObject) {
        // Self, put UIActionController to say something funny
        
        var titleOnAlert = ""
        var messageOnAlert = "You already know where you are... right?"
        
        var alert = UIAlertController(title: nil, message: messageOnAlert, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "...Ok :<", style: .Default, handler: nil)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    var sendLatitude: Double! = 0.0
    var sendLongitude: Double! = 0.0
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "moveToMap" {
            var mapVC: MapViewController = segue.destinationViewController as MapViewController
            mapVC.destLatitude = sendLatitude
            mapVC.destLongitude = sendLongitude
        }
    }
    
    // MARK: LocationManager DELEGATE
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as CLLocation
        var coord = locationObj.coordinate
        
        var span = MKCoordinateSpanMake(0.005, 0.005)
        var region = MKCoordinateRegionMake(locationObj.coordinate, span)
        
        latitude = coord.latitude
        longitude = coord.longitude
        
        if latitude != 0.0 && longitude != 0.0{
            var p: [String: Double] = [:]
            p["latitude"] = latitude
            p["longitude"] = longitude
            NSNotificationCenter.defaultCenter().postNotificationName("ForceUpdateLocation", object: self, userInfo: p)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    // MARK: TableView DELEGATE AND DATASOURCE
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: MessageCell!
        
        if self.senderMessages[indexPath.row] == self.username {
            cell = self.messageTable.dequeueReusableCellWithIdentifier("senderCell") as MessageCell
            cell.senderTextView.text = theMessages[indexPath.row]
            if theLocations[indexPath.row].coordinate.latitude == 0.0 && theLocations[indexPath.row].coordinate.longitude == 0.0{
                cell.senderBtn.hidden = true
            } else {
                cell.senderBtn.hidden = false
                cell.senderBtn.tag = indexPath.row
            }
        } else {
            cell = self.messageTable.dequeueReusableCellWithIdentifier("receiverCell") as MessageCell
            cell.receiverTextView.text = theMessages[indexPath.row]
            if theLocations[indexPath.row].coordinate.latitude == 0.0 && theLocations[indexPath.row].coordinate.longitude == 0.0{
                cell.receiverBtn.hidden = true
                
            } else {
                cell.receiverBtn.hidden = false
                cell.receiverBtn.tag = indexPath.row
            }
        }

        return cell
    }
}