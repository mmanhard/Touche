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
    
    var questionPass: Question!
    
    var did_I: NSMutableArray = NSMutableArray()
    var ddnt_I: Int!
    var myID: Int!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var currentUser: User?
    
    // MARK: Methods to setup current view
    
    override func viewWillAppear(_ animated: Bool) {
        self.currentUser = User.getCurrentUser()
        if self.currentUser != nil {
            print("Logged In")
        } else {
            self.performSegue(withIdentifier: "needsLogin", sender: self)
        }
        
        self.currentCategory.text = self.categoryString
        if (currentLocation != nil) {
            updateTable()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentCategory.text = self.categoryString
        
        let image = UIImage(named:"profile.png") as UIImage?
        let size = CGSize(width: 22, height: 22)
        self.profile.setImage(RBResizeImage(image: image!, targetSize: size), for: .normal)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        currentLocation = self.locationManager.location
        
        if (currentLocation != nil) && (User.getCurrentUser() != nil) {
            updateTable()
        }
        
        self.locationManager.startUpdatingLocation()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160.0
    }
    
    // Auxiliary function to resize an image.
    // Adapted from: https://gist.github.com/hcatlin/180e81cd961573e3c54d
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // ******************
        // MUST ADD EXCEPTION CASE!!!!
        //
        // ********
        return newImage!
    }
    
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
        
        QuestionData.getAllQuestions(latitude: lat, longitude: lng, sortBy: sortBy, category: category) { data in
            do {
                self.questions = QuestionData(data: data!).questionData!
                
                for question in self.questions {
                    var will_I = 0
                    for responder in question.responders
                    {
                        let responded = responder
                        if (responded == self.myID)
                        {
                            will_I = 1
                        }
                    }
                    self.did_I.add(will_I)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.performSegue(withIdentifier: "locationServicesDisabled", sender: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: NSArray) {
        let newLocation = locations[0] as? CLLocation
        currentLocation = newLocation
    }
    
    // MARK: UITableViewDataSource Methods
    // Determine the number of questions.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questions.count
    }
    
    // Populate each row of the question table.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as! TableViewCell_Question
        let question = self.questions[indexPath.row]
        
        cell.questionLabel.text = question.question
        cell.timeLabel.text = getTime(timeDifference: question.datetime)
        cell.Answers = question.answers as NSArray
        cell.QUID = question.id
        cell.numVote = question.total_votes
        cell.qCategory = question.category
        
        let numVotes = question.total_votes
        if numVotes == 1 {
            cell.voteCountLabel.text = "\(numVotes) vote"
        } else {
            cell.voteCountLabel.text = "\(numVotes) votes"
        }
        
        return cell
    }

    // MARK: Methods to transition to another view controller
    
    @IBAction func selectCategory(with sender: UIButton) {
        self.performSegue(withIdentifier: "selectCategory", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.questionPass = self.questions[indexPath.row]
        self.performSegue(withIdentifier: "viewQuestionFromHome", sender: self)
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "selectCategory") {
            let upcoming: ViewController_CategoryMenu = segue.destination as! ViewController_CategoryMenu
            
            upcoming.oldCategory = categoryString
        }
        if (segue.identifier == "viewQuestionFromHome") {
            let upcoming: ViewController_Voting = segue.destination as! ViewController_Voting
            upcoming.question = self.questionPass
            upcoming.voteBool = self.questionPass.responders.contains(self.currentUser!.userID!)
        }

        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: Miscellaneous methods

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

