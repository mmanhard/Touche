//
//  AppConstants.swift
//  Touche
//
//  Created by Michael Manhard on 8/27/20.
//  Copyright © 2020 Michael Manhard. All rights reserved.
//

import Foundation
import CoreLocation

struct Constants {
    static let host = "http://127.0.0.1:5000/"
    
    static let userPath = "users/"
    static let questionPath = "questions/"
    
    static let availCategories = ["All Categories", "Academics", "Business", "Food", "Health", "Humor", "Movies", "Music", "Sex", "Social", "Sports", "Miscellaneous"]
    
    static let desiredLocAccuracy = kCLLocationAccuracyHundredMeters
}

