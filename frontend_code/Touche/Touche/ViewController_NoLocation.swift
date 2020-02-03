//
//  ViewController_NoLocation.swift
//  Touché
//
//
//  View Controller for when loctation services are disabled.
//
//
//  Created by Michael Manhard on 5/11/15.
//  Copyright (c) 2015 Michael Manhard. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController_NoLocation: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        // Configure the location manager.
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    // MARK: CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Failed to get location")
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.performSegueWithIdentifier("gotLocation", sender: self)
    }
    
    // MARK: Method to transition to another view controller
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "gotLocation") {
            var upcoming: ViewController = segue.destinationViewController as! ViewController
            self.locationManager.stopUpdatingLocation()
        }
    }

}
