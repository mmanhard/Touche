//
//  ViewController.swift
//  Prototype
//
//  Created by Paimon Pakzad on 4/7/15.
//  Copyright (c) 2015 cos333. All rights reserved.
//

import UIKit

class ViewController_Profile: UIViewController,  UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var asked_tableView:UITableView!
    var askedArray = ["eggs"]
    @IBOutlet var answered_tableView:UITableView!
    @IBOutlet weak var homeButton: UIButton!
    var answeredArray = ["bacon"]
    var selectedIndex = -1;
    var questionPass : String!
    
    var answers_ask: NSMutableArray = NSMutableArray()
    var answers_ans: NSMutableArray = NSMutableArray()
    var questions_ask: NSMutableArray = NSMutableArray()
    var questions_ans: NSMutableArray = NSMutableArray()
    var times_ask: NSMutableArray = NSMutableArray()
    var times_ans: NSMutableArray = NSMutableArray()
    var votes_ask: NSMutableArray = NSMutableArray()
    var votes_ans: NSMutableArray = NSMutableArray()
    var numVote_ask: NSMutableArray = NSMutableArray()
    var numVote_ans: NSMutableArray = NSMutableArray()
    var quids_ask: NSMutableArray = NSMutableArray()
    var quids_ans: NSMutableArray = NSMutableArray()
    var categories_ask: NSMutableArray = NSMutableArray()
    var categories_ans: NSMutableArray = NSMutableArray()
    
    var QUID : Int!
    var totVotes: Int!
    var ANSWERS_pass: NSArray = []
    var qCategory: String!
    
    var asked: Bool = true
    
    // MARK: Methods to set up current view.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let image = UIImage(named:"touche_icon.png") as UIImage?
        let size = CGSize(width: 36, height: 36)
        self.homeButton.setImage(RBResizeImage(image: image!, targetSize: size), for: .normal)
        
        updateTable()
        
        asked_tableView.isHidden = !asked
        answered_tableView.isHidden = asked
        
        asked_tableView.rowHeight = UITableView.automaticDimension
        asked_tableView.estimatedRowHeight = 160.0
        answered_tableView.rowHeight = UITableView.automaticDimension
        answered_tableView.estimatedRowHeight = 160.0
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
        
        self.answers_ask.removeAllObjects()
        self.questions_ask.removeAllObjects()
        self.times_ask.removeAllObjects()
        self.votes_ask.removeAllObjects()
        self.numVote_ask.removeAllObjects()
        self.quids_ask.removeAllObjects()
        self.categories_ask.removeAllObjects()
        
        let getString = "https://proj-333.herokuapp.com/questions/get_user_asked?user=" + UserDefaults.standard.string(forKey: "iuid")!
        let url = URL(string: getString)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
            
            do {
                if let myJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any] {
                    let question = myJSON["question"] as! String
                    
                    let qText = question.replacingOccurrences(of: "_", with: " ")
                    self.questions_ask.add(qText)
                    
                    let quiddle = myJSON["id"] as! Int
                    self.quids_ask.add(quiddle)
                    
                    let time = myJSON["datetime"] as! Float
                    self.times_ask.add(time)
                    
                    let answers3 = myJSON["answers"] as! [String]
                    self.answers_ask.addObjects(from: answers3)
                    
                    let numVotes = myJSON["total_votes"] as! Int
                    self.numVote_ask.add(numVotes)
                    
                    if numVotes == 1 {
                        self.votes_ask.add("\(numVotes) vote")
                    } else {
                        self.votes_ask.add("\(numVotes) votes")
                    }
                    
                    let cat = myJSON["category"] as! String
                    self.categories_ask.add(cat)
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }

            DispatchQueue.main.async {
                self.asked_tableView.reloadData()
            }
            
        })
        dataTask.resume()
        
        self.answers_ans.removeAllObjects()
        self.questions_ans.removeAllObjects()
        self.times_ans.removeAllObjects()
        self.votes_ans.removeAllObjects()
        self.numVote_ans.removeAllObjects()
        self.quids_ans.removeAllObjects()
        self.categories_ans.removeAllObjects()
        
        let getString2 = "https://proj-333.herokuapp.com/questions/get_user_answered?user=" + UserDefaults.standard.string(forKey: "iuid")!
        let url2 = URL(string: getString2)
        let session2 = URLSession.shared
        let dataTask2 = session2.dataTask(with: url2!, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
            
            do {
                if let myJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any] {
                    let question = myJSON["question"] as! String
                    
                    let qText = question.replacingOccurrences(of: "_", with: " ")
                    self.questions_ans.add(qText)
                    
                    let quiddle = myJSON["id"] as! Int
                    self.quids_ans.add(quiddle)
                    
                    let time = myJSON["datetime"] as! Float
                    self.times_ans.add(time)
                    
                    let answers3 = myJSON["answers"] as! [String]
                    self.answers_ans.addObjects(from: answers3)
                    
                    let numVotes = myJSON["total_votes"] as! Int
                    self.numVote_ans.add(numVotes)
                    
                    if numVotes == 1 {
                        self.votes_ans.add("\(numVotes) vote")
                    } else {
                        self.votes_ans.add("\(numVotes) votes")
                    }
                    
                    let cat = myJSON["category"] as! String
                    self.categories_ans.add(cat)
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }

            DispatchQueue.main.async {
                self.answered_tableView.reloadData()
            }

            
        })
        dataTask2.resume()
    }
    
    // MARK: UITableViewDataSource and UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == asked_tableView)
        {
            return self.questions_ask.count
        }
        else
        {
            return self.questions_ans.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == asked_tableView)
        {
            let cell = self.asked_tableView.dequeueReusableCell(withIdentifier: "cell_asked", for: indexPath as IndexPath) as! TableViewCell_Question
            
            cell.questionLabel.text = self.questions_ask.object(at: indexPath.row) as? String
            if let q = self.times_ask.object(at: indexPath.row) as? Float {
                cell.timeLabel.text = getTime(timeDifference: q)
            }
            cell.voteCountLabel.text = self.votes_ask.object(at: indexPath.row) as? String
            cell.Answers = self.answers_ask.object(at: indexPath.row) as? NSArray
            cell.QUID = self.quids_ask.object(at: indexPath.row) as? Int
            cell.numVote = self.numVote_ask.object(at: indexPath.row) as? Int
            cell.qCategory = self.categories_ask.object(at: indexPath.row) as? String
            return cell
        }
        else
        {
            let cell = self.answered_tableView.dequeueReusableCell(withIdentifier: "cell_answered", for: indexPath as IndexPath) as! TableViewCell_Question
            
            cell.questionLabel.text = self.questions_ans.object(at: indexPath.row) as? String
            if let q = self.times_ans.object(at: indexPath.row) as? Float {
                cell.timeLabel.text = getTime(timeDifference: q)
            }
            cell.voteCountLabel.text = self.votes_ans.object(at: indexPath.row) as? String
            cell.Answers = self.answers_ans.object(at: indexPath.row) as? NSArray
            cell.QUID = self.quids_ans.object(at: indexPath.row) as? Int
            cell.numVote = self.numVote_ans.object(at: indexPath.row) as? Int
            cell.qCategory = self.categories_ans.object(at: indexPath.row) as? String
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let currentCell = tableView.cellForRow(at: indexPath as IndexPath) as! TableViewCell_Question;
        self.questionPass = currentCell.questionLabel!.text
        self.ANSWERS_pass = currentCell.Answers
        self.QUID = currentCell.QUID
        self.totVotes = currentCell.numVote
        self.qCategory = currentCell.qCategory
        self.performSegue(withIdentifier: "viewQuestionFromProfile", sender: self)
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    // MARK: Methods to transition to another view controller.
    
    @IBAction func postQuestion(sender: UIButton) {
        self.performSegue(withIdentifier: "postFromProfile", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "viewQuestionFromProfile")
        {
            let upcoming: ViewController_Voting = segue.destination as! ViewController_Voting
            upcoming.passed_array = ANSWERS_pass
            upcoming.Question_passed = questionPass
            upcoming.prevView = "Profile"
            upcoming.quid = QUID
            upcoming.totVote = totVotes
            upcoming.voteBool = 1
            upcoming.prevScreen = "Profile"
            upcoming.category = qCategory
        } else if (segue.identifier == "postFromProfile") {
            let upcoming: ViewController_Post = segue.destination as! ViewController_Post
            upcoming.prevScreen = "Profile"
        }
    }
    
    // MARK: Miscellaneous methods    
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
    
    @IBAction func askedOrAnswered(sender: AnyObject) {
        asked = !asked
        asked_tableView.isHidden = asked
        answered_tableView.isHidden = asked
    }
    
}


