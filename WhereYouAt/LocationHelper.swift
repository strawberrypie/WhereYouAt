//
//  LocationHelper.swift
//  WhereYouAt
//
//  Created by Kj Drougge on 2015-01-06.
//  Copyright (c) 2015 kj. All rights reserved.
//

import UIKit
import MapKit

protocol GetCoordinatesDelegate{
    func getCoordinates(latitude: Double, longitude: Double)
}

class LocationHelper: NSObject, CLLocationManagerDelegate {
   
    let locationManager: CLLocationManager = CLLocationManager()
    
    var delegate: GetCoordinatesDelegate?

    var latitude: Double! = 0.0
    var longitude: Double! = 0.0
    
    
    override init() {
        super.init()
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: ("startLocating:"), name: "ForceUpdateLocation", object: nil)

    }
    

    func startUpdatingLocation(){
        if CLLocationManager.locationServicesEnabled(){
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }

    }
    

    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as CLLocation
        var coord = locationObj.coordinate
        
        var span = MKCoordinateSpanMake(0.005, 0.005)
        var region = MKCoordinateRegionMake(locationObj.coordinate, span)
        
        latitude = coord.latitude
        longitude = coord.longitude
        
        if latitude != 0.0 && longitude != 0.0{
            println("Hellow")
            
            var p: [String: Double] = [:]
            p["latitude"] = latitude
            p["longitude"] = longitude
            
            NSNotificationCenter.defaultCenter().postNotificationName("ForceUpdateLocation", object: self, userInfo: p)
        }
    }
}
