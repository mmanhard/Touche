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

    @IBOutlet weak var visitSettingsButton: UIButton!

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        self.locationManager.delegate = self
        
        visitSettingsButton.layer.cornerRadius = 10
    }
    
    // Listen for changes to location services authorization. If authorized, go back to the main view.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse ){
            self.navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // Visits the settings page.
    @IBAction func visitSettings() {
        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
    }

}
