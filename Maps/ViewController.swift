//
//  ViewController.swift
//  Maps
//
//  Created by Sheetal Kumar on 10/7/14.
//  Copyright (c) 2014 edu.self. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    let startRouteSubtitle = "Start"
    let stopRouteSubtitle = "Finish"
    
    @IBOutlet weak var mapView: MKMapView!
    var manager:CLLocationManager!
    var location: CLLocationCoordinate2D!
    var prevLocations: [CLLocation] = []
    var startMarkingRoute = false;
    var saveRoute = false;
    var routes: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        location = CLLocationCoordinate2D (
            latitude: manager.location.coordinate.latitude,
            longitude: manager.location.coordinate.longitude
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startRoute() {
        location = getCurrentLocationForUser()
        markLocation(location, subtitle: startRouteSubtitle)
        startMarkingRoute = true
        
    }

    @IBAction func stopRoute() {
        location = getCurrentLocationForUser()
        markLocation(location, subtitle: stopRouteSubtitle)
        routes.append(prevLocations)
        startMarkingRoute = false;
        println(routes[routes.count - 1])
    }
    
    func getCurrentLocationForUser() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D (
            latitude: mapView.userLocation.coordinate.latitude,
            longitude: mapView.userLocation.coordinate.longitude
        )
    }
    
    func markLocation(location: CLLocationCoordinate2D, subtitle: String) {
        
        let annotation = MKPointAnnotation()
        annotation.setCoordinate(location)
        annotation.title = location.latitude.description + "&" + location.longitude.description
        annotation.subtitle = subtitle
        mapView.addAnnotation(annotation)
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        var currentLocation: CLLocation = locations[locations.count - 1] as CLLocation
        
        if (startMarkingRoute) {
            prevLocations.append(currentLocation)
            if (prevLocations.count > 1) {
                var src = prevLocations[prevLocations.count - 2].coordinate
                var dst = currentLocation.coordinate
                var a = [src, dst]
                var polyline = MKPolyline(coordinates: &a, count: a.count)
                mapView.addOverlay(polyline)
            }
        } else {
            prevLocations.removeAll(keepCapacity: true)
        }
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return nil
    }
}
