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
    
    var questions: NSMutableArray = NSMutableArray()
    var times: NSMutableArray = NSMutableArray()
    var votes: NSMutableArray = NSMutableArray()
    var quids: NSMutableArray = NSMutableArray()
    var answers: NSMutableArray = NSMutableArray()
    var numVote: NSMutableArray = NSMutableArray()
    var categories: NSMutableArray = NSMutableArray()
    
    var hot: Bool = false
    var categoryString = "All Categories"
    
    var questionPass:String!
    var ANSWERS:NSArray = []
    var QUID : Int!
    var totalVote: Int!
    var qCategory: String!
    
    var did_I: NSMutableArray = NSMutableArray()
    var ddnt_I: Int!
    var myID: Int!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    // MARK: Methods to setup current view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerUser()
        self.currentCategory.text = categoryString
        
        let image = UIImage(named:"profile.png") as UIImage?
        let size = CGSize(width: 22, height: 22)
        self.profile.setImage(RBResizeImage(image: image!, targetSize: size), for: UIControl.State.normal)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        currentLocation = self.locationManager.location
        
        if (currentLocation != nil) {
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
    
    
    func registerUser()
    {
        if let uuid: NSString = UserDefaults.standard.string(forKey: "uuid") as NSString?
        {
            self.myID = Int(UserDefaults.standard.string(forKey: "iuid")!)
        }
        else
        {
            let duid2 = NSUUID().uuidString
            let duid = duid2.substringWithRange(Range<String.Index>(start: advance(duid2.startIndex, 24), end: duid2.endIndex))
            UserDefaults.standard.set(NSString(), forKey: "uuid")
            UserDefaults.standard.setValue(duid, forKey:"uuid")
            UserDefaults.standard.set(NSString(), forKey: "iuid")
            self.myID = Int(UserDefaults.standard.string(forKey: "iuid")!)
            let postString =  "https://proj-333.herokuapp.com/users/new?number=" + (duid as String);
            let url = NSURL(string: postString)
            let session = URLSession.shared
            // Compose a query string
            //let postString2 = "";
            let dataTask = session.dataTaskWithURL(url!, completionHandler: { (data: NSData!, response:URLResponse!, error: NSError!) -> Void in
                println("Task completed")
                if(error != nil) {
                    
                    // If there is an error in the web request, print it to the console
                    
                    println(error.localizedDescription)
                    
                }
                
                let s2 = NSString(data: data, encoding: NSUTF8StringEncoding)!
                NSUserDefaults.standardUserDefaults().setValue(s2, forKey:"iuid")
                NSUserDefaults.standardUserDefaults().synchronize()
                
            })
            dataTask.resume()
            UserDefaults.standard.synchronize()
        }
    }
    
    
    func updateTable() {
        var latitude = ""
        var longitude = ""
        if (currentLocation != nil) {
            latitude = String(format: "&lat=%.8f", currentLocation.coordinate.latitude)
            longitude = String(format: "&lng=%.8f", currentLocation.coordinate.longitude)
        }
        
        self.questions.removeAllObjects()
        self.times.removeAllObjects()
        self.votes.removeAllObjects()
        self.numVote.removeAllObjects()
        self.answers.removeAllObjects()
        self.quids.removeAllObjects()
        self.categories.removeAllObjects()
        
        var getString = "https://proj-333.herokuapp.com/questions/get_all?"
        if hot {
            getString += "sort=hot"
        }
        if (categoryString != "All Categories") {
            getString += "&category=" + categoryString
        }
        
        let latValue = latitude
        let lonValue = longitude
        getString += latValue + lonValue
        
        let url = NSURL(string: getString)
        let session = URLSession.shared
        let dataTask = session.dataTaskWithURL(url!, completionHandler: { (data: NSData!, response:URLResponse!, error: NSError!) -> Void in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            let items = data
            let s = NSString(data: data, encoding: NSUTF8StringEncoding)
            var err: NSError?
            var myJSON:AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            
            if let parseJSON = myJSON as? NSArray {
                for dict in parseJSON {
                    var question = dict.valueForKey("question")! as! String
                    let qText = question.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    self.questions.addObject(qText)
                    let quiddle = dict.valueForKey("id")! as! Int
                    self.quids.addObject(quiddle)
                    let time = dict.valueForKey("datetime")! as! Float
                    self.times.addObject(time)
                    let answers3 = dict.valueForKey("answers")! as! NSArray
                    self.answers.addObject(answers3)
                    let numVotes = dict.valueForKey("total_votes")! as! Int
                    self.numVote.addObject(numVotes)
                    if numVotes == 1 {
                        self.votes.addObject("\(numVotes) vote")
                    } else {
                        self.votes.addObject("\(numVotes) votes")
                    }
                    let responders = dict.valueForKey("responders") as! NSArray
                    var will_I = 0
                    for responder in responders
                    {
                        let responded = responder as! Int
                        if (responded == self.myID)
                        {
                            will_I = 1
                        }
                    }
                    self.did_I.addObject(will_I)
                    let cat = dict.valueForKey("category")! as! String
                    self.categories.addObject(cat)
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
            
        })
        dataTask.resume()
    }
    
    // MARK: CLLocationManagerDelegate Methods
    
    private func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        self.performSegue(withIdentifier: "locationServicesDisabled", sender: self)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
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
        
        cell.questionLabel.text = self.questions.object(at: indexPath.row) as? String
        if let q = self.times.object(at: indexPath.row) as? Float {
            cell.timeLabel.text = getTime(timeDifference: q)
        }
        cell.voteCountLabel.text = self.votes.object(at: indexPath.row) as? String
        cell.Answers = self.answers.object(at: indexPath.row) as? NSArray
        cell.QUID = self.quids.object(at: indexPath.row) as! Int
        cell.numVote = self.numVote.object(at: indexPath.row) as! Int
        cell.qCategory = self.categories.object(at: indexPath.row) as! String
        return cell
    }

    // MARK: Methods to transition to another view controller
    
    @IBAction func selectCategory(sender: UIButton) {
        self.performSegue(withIdentifier: "selectCategory", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentCell = tableView.cellForRow(at: indexPath as IndexPath) as! TableViewCell_Question;
        self.questionPass = currentCell.questionLabel!.text
        self.ANSWERS = currentCell.Answers
        self.QUID = currentCell.QUID
        self.totalVote = currentCell.numVote
        self.qCategory = currentCell.qCategory
        self.ddnt_I = self.did_I.object(at: indexPath.row) as! Int
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
            upcoming.passed_array = self.ANSWERS
            upcoming.Question_passed = self.questionPass
            upcoming.prevView = "Home"
            upcoming.quid = QUID
            upcoming.totVote = totalVote
            upcoming.voteBool = ddnt_I
            upcoming.category = qCategory
        }
        if (segue.identifier == "locationServicesDisabled") {
            var upcoming: ViewController_NoLocation = segue.destination as! ViewController_NoLocation
        }

        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: Miscellaneous methods

    // Changes the table to either be sorted by how recent they are or how popular they are.
    @IBAction func changeSorting(sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {
            hot = false
            updateTable()
        } else {
            hot = true
            updateTable()
        }
    }
    
    // Given a beginning index and a length, returns the substring of a string.
    func getSubstring(str: String, begin: Int, l: Int) -> String {
        return str.substringWithRange(Range<String.Index>(start: advance(str.startIndex, begin), end: advance(str.startIndex, begin + l)))
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

