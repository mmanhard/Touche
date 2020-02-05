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
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.performSegue(withIdentifier: "locationServicesDisabled", sender: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: NSArray) {
        self.performSegue(withIdentifier: "gotLocation", sender: self)
    }
    
    // MARK: Method to transition to another view controller
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "gotLocation") {
            let upcoming: ViewController = segue.destination as! ViewController
            self.locationManager.stopUpdatingLocation()
        }
    }

}
