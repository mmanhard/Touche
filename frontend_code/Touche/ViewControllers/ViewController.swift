//
//  ViewController.swift
//  Touche
//
//  View Controller for the home page.
//
//  Created by Michael Manhard on 5/6/15.
//  Copyright (c) 2015 Michael Manhard. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profile: UIButton!
    @IBOutlet weak var currentCategory: UILabel!
    @IBOutlet weak var categoryRectangle: UIView!
    
    var questions: [Question] = []
    var hot: Bool = false
    var categoryString = "All Categories"
    var questionToPass: Question!
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var currentUser: User?
    
    // MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentCategory.text = self.categoryString
        
        // Set the profile image and resize it.
        let image = UIImage(named:"profile.png") as UIImage?
        let size = CGSize(width: 22, height: 22)
        self.profile.setImage(Utility.RBResizeImage(image: image!, targetSize: size), for: .normal)
        
        // Configure the location manage delegate.
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = Constants.desiredLocAccuracy
        self.locationManager.requestWhenInUseAuthorization()
        
        // Configure the table view.
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 160.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Make sure there is a user. Otherwise, go to login view.
        self.currentUser = User.getCurrentUser()
        if self.currentUser == nil {
            self.performSegue(withIdentifier: "needsLogin", sender: self)
            return
        }
        
        self.currentCategory.text = self.categoryString
        
        // Check if we are authorized to monitor the user's location. If so, listen for updates to the location, set the current location, and update the table.
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) {
            self.locationManager.startUpdatingLocation()
            self.currentLocation = self.locationManager.location
            if (self.currentLocation != nil) {
                updateTable()
            }
        } else {
            self.performSegue(withIdentifier: "locationServicesDisabled", sender: self)
        }
    }
    
    // MARK: Location Manager Methods
    
    // Listen for changes to the location services authorization status. If authorized, start updating locations, set the current location, and update the table view.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedWhenInUse) {
            self.locationManager.startUpdatingLocation()
            currentLocation = self.locationManager.location
            updateTable()
        }
    }
    
    // Listen for location errors. If error is of type CLError.denied, the user has disabled location services, so we segue to the no location services view.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clErr = error as? CLError {
            switch clErr {
                case CLError.denied:
                    self.performSegue(withIdentifier: "locationServicesDisabled", sender: self)
                default:
                    print("other Core Location error")
            }
        }
    }
    
    // Listen for updates to the current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
    }

    // MARK: TableView Methods
    
    // Updates the table by reloading questions from the backend and reloading the table view.
    func updateTable() {
        var lat: Double?
        var lng: Double?
        var sortBy: String?
        var category: String?
        
        if (currentLocation != nil) {
            lat = currentLocation.coordinate.latitude
            lng = currentLocation.coordinate.longitude
        }
        
        if hot {
            sortBy = "hot"
        }

        if (categoryString != "All Categories") {
            category = categoryString
        }
        
        // Get all questions, store them, and reload the table view.
        QuestionData.getAllQuestions(latitude: lat, longitude: lng, sortBy: sortBy, category: category) { data in
            do {
                self.questions = QuestionData(data: data!).questionData!
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // Determine the number of questions.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questions.count
    }
    
    // Populate each row of the question table.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as! TableViewCell_Question
        let question = self.questions[indexPath.row]
        
        // Get all display information from the question object.
        cell.questionLabel.text = question.question
        cell.timeLabel.text = getTime(timeDifference: question.datetime)
        cell.Answers = question.answers as NSArray
        cell.QUID = question.id
        cell.numVote = question.total_votes
        cell.qCategory = question.category
        
        // Get the number of votes and format the votes string.
        let numVotes = question.total_votes
        if numVotes == 1 {
            cell.voteCountLabel.text = "\(numVotes) vote"
        } else {
            cell.voteCountLabel.text = "\(numVotes) votes"
        }
        
        return cell
    }

    // MARK: View Transition Methods
    
    // Handler for selecting select category. Shows the select category view.
    @IBAction func selectCategory(with sender: UIButton) {
        self.performSegue(withIdentifier: "selectCategory", sender: self)
    }
    
    // Handler for selecting a row of the question table. Shows the view for the corresponding question.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.questionToPass = self.questions[indexPath.row]
        self.performSegue(withIdentifier: "viewQuestionFromHome", sender: self)
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    // Handler for preparing to segue to another view. Primarily used to pass data between view controllers.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "selectCategory") {
            let upcoming: ViewController_CategoryMenu = segue.destination as! ViewController_CategoryMenu
            
            upcoming.oldCategory = categoryString
        }
        if (segue.identifier == "viewQuestionFromHome") {
            let upcoming: ViewController_Voting = segue.destination as! ViewController_Voting
            upcoming.question = self.questionToPass
            upcoming.voteBool = self.questionToPass.responders.contains(self.currentUser!.userID!)
        }

        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: Misc. methods

    // Changes the table to either be sorted by how recent they are or how popular they are.
    @IBAction func changeSorting(with sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {
            hot = false
            updateTable()
        } else {
            hot = true
            updateTable()
        }
    }
    
    // Given a beginning index and a length, returns the substring of a string.
    func getSubstring(str: String, beginOffset: Int, endOffset: Int) -> String {
        let start = str.index(str.startIndex, offsetBy: beginOffset)
        let end = str.index(str.endIndex, offsetBy: endOffset)
        let range = start..<end

        let mySubstring = str[range]
        return String(mySubstring)
    }
    
    // Convert the time to a string representation.
    func getTime(timeDifference: Float) -> String {
        if timeDifference < 60 {
            return "\(Int(timeDifference))s"
        } else if timeDifference < 3600 {
            let timeDifference = Int(round(timeDifference/60))
            return "\(timeDifference)m"
        } else if timeDifference < 86400 {
            let timeDifference = Int(round(timeDifference/3600))
            return "\(timeDifference)h"
        } else {
            let timeDifference = Int(round(timeDifference/86400))
            return "\(timeDifference)d"
        }
    }
    
}

