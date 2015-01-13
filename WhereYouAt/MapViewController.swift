//
//  MapViewController.swift
//  WhereYouAt
//
//  Created by Kj Drougge on 2015-01-06.
//  Copyright (c) 2015 kj. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var routeOverlay: MKPolyline!
    var currentRoute: MKRoute!
    let locationManager: CLLocationManager! = CLLocationManager()
    
    var isCenterMe: Bool! = true
    
    var destLatitude: Double!
    var destLongitude: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Request to use the locationmanager.
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // If the service is enabled start update the location and create route between the two points.
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            
            self.handleRoute()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Stop udating location when view disappear.
        self.locationManager.stopUpdatingLocation()
    }
    
    func handleRoute(){
        var directionsRequest = MKDirectionsRequest()
        
        // Get the coords for my current location.
        var source: MKMapItem = MKMapItem.mapItemForCurrentLocation()
        directionsRequest.setSource(source)
        
        //var destinationCoords = CLLocationCoordinate2DMake(59.33296, 17.98035) // Alvik koordinationer för test.
        
        // The coords for the destination.
        var destinationCoords = CLLocationCoordinate2DMake(destLatitude, destLongitude)
        var destinationPlacemark = MKPlacemark(coordinate: destinationCoords, addressDictionary: nil)
        var destination: MKMapItem = MKMapItem(placemark: destinationPlacemark)
        directionsRequest.setDestination(destination)
        
        // Select which type of transport.
        directionsRequest.transportType = MKDirectionsTransportType.Automobile
        
        var directions = MKDirections(request: directionsRequest)
        
        directions.calculateDirectionsWithCompletionHandler ({
            (response: MKDirectionsResponse?, error: NSError?) in
            
            if error != nil {
                return
            }
            
            self.currentRoute = response?.routes.first as MKRoute
            self.plotRouteOnMap(self.currentRoute)
        })
    }
    
    func plotRouteOnMap(route: MKRoute){
        println("Plot")
        
        // If route already there, remove it.
        if routeOverlay != nil{
            self.mapView.removeOverlay(routeOverlay)
        }
        
        // Create the route between the points.
        routeOverlay = route.polyline
        self.mapView.addOverlay(routeOverlay)
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline{
            var pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
            pr.lineWidth = 5
            return pr
        }
        
        return nil
    }
    
    var latitude: Double! = 0.0
    var longitude: Double! = 0.0
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as CLLocation
        var coord = locationObj.coordinate
        
        var span = MKCoordinateSpanMake(0.005, 0.005)
        var region = MKCoordinateRegionMake(locationObj.coordinate, span)
    
        // Center at my location
        if isCenterMe.boolValue{
            mapView.region = region
            mapView.setCenterCoordinate(coord, animated: true)
            isCenterMe = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func findMeBtn_clicked(sender: AnyObject) {
        isCenterMe = true
    }
}