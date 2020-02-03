//
//  ViewController_Post.swift
//  Touche
//
//
//  View controller for the posting page.
//
//
//  Created by Michael Manhard on 5/6/15.
//  Copyright (c) 2015 Michael Manhard. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController_Post: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    @IBOutlet var Answers : UITableView!
    @IBOutlet weak var Category: UIButton!
    @IBOutlet weak var placeholder: UILabel!
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var Question: UITextView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    var keyboardFrame: CGRect = CGRect.nullRect
    var keyboardIsShowing: Bool = false
    weak var activeTextField: UITextField?
    weak var activeTextView: UITextView?
    
    var chosenCategory: String?
    var qTextSegue: String?
    var prevScreen: String?
    
    var answerArray = ["Yes", "No"]
    var maxQuestionLength = 160
    var maxAnswerLength = 30
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    let rowHeight = 44
    let maxNumAnswers = 4
    var kbHeight: CGFloat!
    
    // MARK: Methods to set up current view.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the location manager delegate.
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        currentLocation = self.locationManager.location
        
        
        // Set the top left button to be the right image.
        if (prevScreen != nil) {
            let image = UIImage(named:"profile.png") as UIImage?
            let size = CGSize(width: 22, height: 22)
            self.backButton.setImage(RBResizeImage(image!, targetSize: size), forState: .Normal)
        } else {
            let image = UIImage(named:"touche_icon.png") as UIImage?
            let size = CGSize(width: 36, height: 36)
            self.backButton.setImage(RBResizeImage(image!, targetSize: size), forState: .Normal)
        }
        
        // Change the category label title if there was already one chosen.
        if (self.chosenCategory != nil) {
            self.Category.setTitle(self.chosenCategory!, forState: UIControlState.Normal)
        }
        
        // Change the question text to be the old question text if there was already one.
        Question.delegate = self
        if (self.qTextSegue != nil) {
            Question.text = self.qTextSegue
        }
        
        textCount.text = "\(count(Question.text)) / 160"
        placeholder.hidden = count(Question.text) > 0
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        for subview in self.view.subviews
        {
            if (subview.isKindOfClass(TableViewCell_AnswerCell))
            {
                
                var cell = subview as! TableViewCell_AnswerCell
                var textField = cell.Answer
                textField.delegate = self
                
                textField.addTarget(self, action: "textFieldDidReturn:", forControlEvents: UIControlEvents.EditingDidEndOnExit)
                textField.addTarget(self, action: "textFieldDidBeginEditing:", forControlEvents: UIControlEvents.EditingDidBegin)
                
            }
            
        }
        
        Category.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        
        self.Answers.reloadData()
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
    
    // MARK: UITextViewDelegate Methods
    
    func textViewDidChange(textView: UITextView) {
        placeholder.hidden = (count(textView.text) != 0)
        textCount.text = "\(count(textView.text)) / 160"
    }
    
    
    // Restrict the question text to 160 characters.
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (contains(text,"\n")) {
            textView.resignFirstResponder()
            return false
        } else {
            let oldString = textView.text as NSString
            let newString = oldString.stringByReplacingCharactersInRange(range, withString: text)
        
            return count(newString) <= maxQuestionLength
        }
    }
    
    // MARK: UITableViewDataSource and UITableViewDelegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int{
            let numCells = self.answerArray.count + 1
            resizeTable(numCells)
            return numCells
    }
    
    func resizeTable(numCells: Int) {
        let suggestedTableHeight = CGFloat(numCells  * rowHeight)
        let availableHeight = self.view.frame.height - self.Answers.frame.origin.y
        
        if (suggestedTableHeight < availableHeight) {
            self.tableHeight.constant = suggestedTableHeight
        } else {
            self.tableHeight.constant = availableHeight
        }
    }
    
    // Populate each cell in the answer table view.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row < self.answerArray.count) {
            var cell: TableViewCell_AnswerCell = tableView.dequeueReusableCellWithIdentifier("answerCell") as! TableViewCell_AnswerCell
            cell.Answer.text = answerArray[indexPath.row]
            return cell
        } else {
            var cell: TableViewCell = tableView.dequeueReusableCellWithIdentifier("addAnswerCell") as! TableViewCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == self.answerArray.count) {
            if (self.answerArray.count < maxNumAnswers) {
                self.answerArray = getAnswerArray()
                self.answerArray.append("Answer \(indexPath.row + 1)")
            } else {
                let alertController = UIAlertController(title: "Cannot Add Answer", message: "Max Number of Answers Reached", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // Must have 2 answers and cannot delete final cell.
        if (self.answerArray.count > 2 && indexPath.row < self.answerArray.count) {
            if (editingStyle == UITableViewCellEditingStyle.Delete) {
                answerArray = getAnswerArray()
                answerArray.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            tableView.reloadData()
        } else if (self.answerArray.count <= 2 && indexPath.row < self.answerArray.count) {
            let alertController = UIAlertController(title: "Cannot Delete Answer", message: "Must have at least 2 answers", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Method to post a question.
    
    @IBAction func postQuestion(sender: UIButton) {
        
        let (isValid, ErrorMessage) = validQuestion()
        if isValid {
            
            let latitude = String(format: "&lat=%.8f", currentLocation.coordinate.latitude)
            let longitude = String(format: "&lng=%.8f", currentLocation.coordinate.longitude)
            
            // Get the user ID.
            /*** Needs updatings ***/
            let userID = NSUserDefaults.standardUserDefaults().stringForKey("iuid")!
        
            // Get the category text.
            var categoryText: String = "Miscellaneous"
            if (Category.currentTitle! != "Select a Category") {
                categoryText = Category.currentTitle!
            }
        
            // Get the answer text.
            var ansText: String = ""
            for i in 0...(self.Answers.numberOfRowsInSection(0) - 2) {
                let ind = NSIndexPath(forRow: i, inSection: 0)
                let cell = self.Answers.cellForRowAtIndexPath(ind) as! TableViewCell_AnswerCell
                ansText = ansText + "," + cell.Answer.text
            }
            ansText = ansText.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
            // Get the question text.
            var qText: String = self.Question.text
            qText = qText.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        
            // Create the URL string
            var postString =  "https://proj-333.herokuapp.com/questions/new?user=" + userID + "&category=" + categoryText + "&question=" + qText + "&answers=" + ansText + latitude + longitude;
        
            println(postString)
            let url = NSURL(string: postString)
            println("here")
            let session = NSURLSession.sharedSession()
            println(session)

            let dataTask = session.dataTaskWithURL(url!, completionHandler: { (data: NSData!, response:NSURLResponse!, error: NSError!) -> Void in
                println("Task completed")
                if(error != nil) {
                
                    // If there is an error in the web request, print it to the console
                
                    println(error.localizedDescription)
                
                }
            
                let s = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            
            })
            dataTask.resume()
            self.performSegueWithIdentifier("postedQuestion", sender: self)
        } else {
            let alertController = UIAlertController(title: "Not a Valid Question!", message:
                ErrorMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (self.activeTextField != nil) {
            self.activeTextField!.resignFirstResponder()
            self.activeTextField = nil
        }
        self.activeTextField = textField
        
        if(self.keyboardIsShowing)
        {
            self.animateTextField(true)
        }
        
        return true
    }
    
    func animateTextField(up: Bool) {
        if (self.activeTextField != nil) {
            var movement = (up ? -kbHeight : kbHeight)
            
            UIView.animateWithDuration(0.3, animations: {
                self.view.frame = CGRectOffset(self.view.frame, 0, movement)
            })
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = count(textField.text) + count(string) - range.length
        return newLength <= maxAnswerLength
    }
    
    // MARK: Methods to deal with keyboard popping up.
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        self.keyboardIsShowing = true
        
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height / 2
                self.animateTextField(true)
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.keyboardIsShowing = false
        
        self.animateTextField(false)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if (self.activeTextField != nil)
        {
            self.activeTextField!.resignFirstResponder()
            self.activeTextField = nil
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.activeTextField = nil
        
        return true
    }
    
    // MARK: CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Failed to get location")
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        currentLocation = newLocation
    }

    // MARK: Methods to transition to another view controller.
    
    @IBAction func getCategory(sender: UIButton) {
        self.performSegueWithIdentifier("chooseCategory", sender: self)
    }
    
    @IBAction func cancelPost(sender: UIButton) {
        if (prevScreen != nil) {
            self.performSegueWithIdentifier("noPostGoProfile", sender: self)
        } else {
            self.performSegueWithIdentifier("noPostGoHome", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "chooseCategory") {
            var upcoming: ViewController_chooseCategory = segue.destinationViewController as! ViewController_chooseCategory
            
            upcoming.questionText = Question.text
            upcoming.answerArray = getAnswerArray()
            upcoming.oldCategory = Category.currentTitle!
        } else if (segue.identifier == "noPostGoHome") {
            var upcoming: ViewController = segue.destinationViewController as! ViewController
        } else if (segue.identifier == "noPostGoProfile") {
            var upcoming: ViewController_Profile = segue.destinationViewController as! ViewController_Profile
        }
        else if (segue.identifier == "postedQuestion") {
            var upcoming: ViewController = segue.destinationViewController as! ViewController
        }
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Miscellaneous methods
    
    func getAnswerArray() -> Array<String> {
        var answers: Array<String> = []
        for i in 0...(self.Answers.numberOfRowsInSection(0) - 2) {
            let ind = NSIndexPath(forRow: i, inSection: 0)
            let cell = self.Answers.cellForRowAtIndexPath(ind) as! TableViewCell_AnswerCell
            answers.append(cell.Answer.text)
        }
        return answers
    }
    
    func validQuestion() -> (Bool, String?) {
        if (count(Question.text) <= 0) {
            return (false, "Question left blank")
        } else {
            let currentAnswers = getAnswerArray()
            if contains(currentAnswers,"") {
                return (false, "Answer left blank")
            } else if (currentLocation == nil) {
                return (false, "Location services must be enabled to post")
            }
        }
        return (true, nil)
    }

}