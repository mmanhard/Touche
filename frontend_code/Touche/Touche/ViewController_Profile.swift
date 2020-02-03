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
        self.homeButton.setImage(RBResizeImage(image!, targetSize: size), forState: .Normal)
        
        updateTable()
        
        asked_tableView.hidden = !asked
        answered_tableView.hidden = asked
        
        asked_tableView.rowHeight = UITableViewAutomaticDimension
        asked_tableView.estimatedRowHeight = 160.0
        answered_tableView.rowHeight = UITableViewAutomaticDimension
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
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func updateTable() {
        
        self.answers_ask.removeAllObjects()
        self.questions_ask.removeAllObjects()
        self.times_ask.removeAllObjects()
        self.votes_ask.removeAllObjects()
        self.numVote_ask.removeAllObjects()
        self.quids_ask.removeAllObjects()
        self.categories_ask.removeAllObjects()
        
        let getString = "https://proj-333.herokuapp.com/questions/get_user_asked?user=" + NSUserDefaults.standardUserDefaults().stringForKey("iuid")!
        println(getString)
        let url = NSURL(string: getString)
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithURL(url!, completionHandler: { (data: NSData!, response:NSURLResponse!, error: NSError!) -> Void in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            let items = data
            let s = NSString(data: data, encoding: NSUTF8StringEncoding)
            var err: NSError?
            var myJSON:AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            println(myJSON);
            if let parseJSON = myJSON as? NSArray {
                for dict in parseJSON {
                    var question = dict.valueForKey("question")! as! String
                    let qText = question.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    self.questions_ask.addObject(qText)
                    let quiddle = dict.valueForKey("id")! as! Int
                    self.quids_ask.addObject(quiddle)
                    let time = dict.valueForKey("datetime")! as! Float
                    self.times_ask.addObject(time)
                    let answers3 = dict.valueForKey("answers")! as! NSArray
                    self.answers_ask.addObject(answers3)
                    let numVotes = dict.valueForKey("total_votes")! as! Int
                    self.numVote_ask.addObject(numVotes)
                    if numVotes == 1 {
                        self.votes_ask.addObject("\(numVotes) vote")
                    } else {
                        self.votes_ask.addObject("\(numVotes) votes")
                    }
                    let cat = dict.valueForKey("category")! as! String
                    self.categories_ask.addObject(cat)
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
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
        
        let getString2 = "https://proj-333.herokuapp.com/questions/get_user_answered?user=" + NSUserDefaults.standardUserDefaults().stringForKey("iuid")!
        println(getString2)
        let url2 = NSURL(string: getString2)
        let session2 = NSURLSession.sharedSession()
        let dataTask2 = session2.dataTaskWithURL(url2!, completionHandler: { (data: NSData!, response:NSURLResponse!, error: NSError!) -> Void in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            let items2 = data
            let s3 = NSString(data: data, encoding: NSUTF8StringEncoding)
            var err: NSError?
            var myJSON2:AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            println("myJSON2: ")
            println(myJSON2);
            if let parseJSON2 = myJSON2 as? NSArray {
                for dict2 in parseJSON2 {
                    var question2 = dict2.valueForKey("question")! as! String
                    let qText2 = question2.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    self.questions_ans.addObject(qText2)
                    let quiddle2 = dict2.valueForKey("id")! as! Int
                    self.quids_ans.addObject(quiddle2)
                    let time2 = dict2.valueForKey("datetime")! as! Float
                    self.times_ans.addObject(time2)
                    let answers2 = dict2.valueForKey("answers")! as! NSArray
                    self.answers_ans.addObject(answers2)
                    let numVotes2 = dict2.valueForKey("total_votes")! as! Int
                    self.numVote_ans.addObject(numVotes2)
                    if numVotes2 == 1 {
                        self.votes_ans.addObject("\(numVotes2) vote")
                    } else {
                        self.votes_ans.addObject("\(numVotes2) votes")
                    }
                    let cat2 = dict2.valueForKey("category")! as! String
                    self.categories_ans.addObject(cat2)
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.answered_tableView.reloadData()
            }
            
        })
        dataTask2.resume()
    }
    
    // MARK: UITableViewDataSource and UITableViewDelegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == asked_tableView)
        {
            return self.questions_ask.count
        }
        else
        {
            return self.questions_ans.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (tableView == asked_tableView)
        {
            let cell = self.asked_tableView.dequeueReusableCellWithIdentifier("cell_asked", forIndexPath: indexPath) as! TableViewCell_Question
            
            cell.questionLabel.text = self.questions_ask.objectAtIndex(indexPath.row) as? String
            if let q = self.times_ask.objectAtIndex(indexPath.row) as? Float {
                cell.timeLabel.text = getTime(q)
            }
            cell.voteCountLabel.text = self.votes_ask.objectAtIndex(indexPath.row) as? String
            cell.Answers = self.answers_ask.objectAtIndex(indexPath.row) as? NSArray
            cell.QUID = self.quids_ask.objectAtIndex(indexPath.row) as! Int
            cell.numVote = self.numVote_ask.objectAtIndex(indexPath.row) as! Int
            cell.qCategory = self.categories_ask.objectAtIndex(indexPath.row) as! String
            println("ask cells are fine")
            return cell
        }
        else
        {
            let cell = self.answered_tableView.dequeueReusableCellWithIdentifier("cell_answered", forIndexPath: indexPath) as! TableViewCell_Question
            
            cell.questionLabel.text = self.questions_ans.objectAtIndex(indexPath.row) as? String
            if let q = self.times_ans.objectAtIndex(indexPath.row) as? Float {
                cell.timeLabel.text = getTime(q)
            }
            cell.voteCountLabel.text = self.votes_ans.objectAtIndex(indexPath.row) as? String
            cell.Answers = self.answers_ans.objectAtIndex(indexPath.row) as? NSArray
            cell.QUID = self.quids_ans.objectAtIndex(indexPath.row) as! Int
            cell.numVote = self.numVote_ans.objectAtIndex(indexPath.row) as! Int
            cell.qCategory = self.categories_ans.objectAtIndex(indexPath.row) as! String
            println("answer cells are fine")
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell_Question;
        self.questionPass = currentCell.questionLabel!.text
        self.ANSWERS_pass = currentCell.Answers
        self.QUID = currentCell.QUID
        self.totVotes = currentCell.numVote
        self.qCategory = currentCell.qCategory
        self.performSegueWithIdentifier("viewQuestionFromProfile", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    // MARK: Methods to transition to another view controller.
    
    @IBAction func postQuestion(sender: UIButton) {
        self.performSegueWithIdentifier("postFromProfile", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "viewQuestionFromProfile")
        {
            var upcoming: ViewController_Voting = segue.destinationViewController as! ViewController_Voting
            upcoming.passed_array = ANSWERS_pass
            upcoming.Question_passed = questionPass
            upcoming.prevView = "Profile"
            upcoming.quid = QUID
            upcoming.totVote = totVotes
            upcoming.voteBool = 1
            upcoming.prevScreen = "Profile"
            upcoming.category = qCategory
        } else if (segue.identifier == "postFromProfile") {
            var upcoming: ViewController_Post = segue.destinationViewController as! ViewController_Post
            upcoming.prevScreen = "Profile"
        }
    }
    
    // MARK: Miscellaneous methods
    
    func getSubstring(str: String, begin: Int, l: Int) -> String {
        return str.substringWithRange(Range<String.Index>(start: advance(str.startIndex, begin), end: advance(str.startIndex, begin + l)))
    }
    
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
        asked_tableView.hidden = !asked
        answered_tableView.hidden = asked
    }
    
}


