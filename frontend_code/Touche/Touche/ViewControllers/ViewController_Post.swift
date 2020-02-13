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
    
    var keyboardFrame: CGRect = CGRect.null
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
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.chosenCategory != nil) {
            self.Category.setTitle(self.chosenCategory!, for: .normal)
        }
    }
    
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
            self.backButton.setImage(RBResizeImage(image: image!, targetSize: size), for: .normal)
        } else {
            let image = UIImage(named:"touche_icon.png") as UIImage?
            let size = CGSize(width: 36, height: 36)
            self.backButton.setImage(RBResizeImage(image: image!, targetSize: size), for: .normal)
        }
        
        // Change the category label title if there was already one chosen.
        if (self.chosenCategory != nil) {
            self.Category.setTitle(self.chosenCategory!, for: .normal)
        }
        
        // Change the question text to be the old question text if there was already one.
        Question.delegate = self
        if (self.qTextSegue != nil) {
            Question.text = self.qTextSegue
        }
        
        textCount.text = "\(Question.text.count) / 160"
        placeholder.isHidden = Question.text.count > 0
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        for subview in self.view.subviews
        {
            if (subview is TableViewCell_AnswerCell)
            {
                
                let cell = subview as! TableViewCell_AnswerCell
                let textField = cell.Answer!
                textField.delegate = self
                
                textField.addTarget(self, action: Selector(("textFieldDidReturn:")), for: UIControl.Event.editingDidEndOnExit)
                textField.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)), for: UIControl.Event.editingDidBegin)
                
            }
            
        }
        
        Category.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
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
    
    // MARK: UITextViewDelegate Methods
    
    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = (textView.text.count != 0)
        textCount.text = "\(textView.text.count) / 160"
    }
    
    
    // Restrict the question text to 160 characters.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text.contains("\n")) {
            textView.resignFirstResponder()
            return false
        } else {
            let oldString = textView.text as NSString
            let newString = oldString.replacingCharacters(in: range, with: text)
        
            return newString.count <= maxQuestionLength
        }
    }
    
    // MARK: UITableViewDataSource and UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int{
            let numCells = self.answerArray.count + 1
            resizeTable(numCells: numCells)
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row < self.answerArray.count) {
            let cell: TableViewCell_AnswerCell = tableView.dequeueReusableCell(withIdentifier: "answerCell") as! TableViewCell_AnswerCell
            cell.Answer.text = answerArray[indexPath.row]
            return cell
        } else {
            let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "addAnswerCell") as! TableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == self.answerArray.count) {
            if (self.answerArray.count < maxNumAnswers) {
                self.answerArray = getAnswerArray()
                self.answerArray.append("Answer \(indexPath.row + 1)")
            } else {
                let alertController = UIAlertController(title: "Cannot Add Answer", message: "Max Number of Answers Reached", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Must have 2 answers and cannot delete final cell.
        if (self.answerArray.count > 2 && indexPath.row < self.answerArray.count) {
            if (editingStyle == UITableViewCell.EditingStyle.delete) {
                answerArray = getAnswerArray()
                answerArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [(indexPath as IndexPath)], with: UITableView.RowAnimation.automatic)
            }
            tableView.reloadData()
        } else if (self.answerArray.count <= 2 && indexPath.row < self.answerArray.count) {
            let alertController = UIAlertController(title: "Cannot Delete Answer", message: "Must have at least 2 answers", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Method to post a question.
    
    @IBAction func postQuestion(with sender: UIButton) {
        
        let (isValid, ErrorMessage) = validQuestion()
        if isValid {
            
            let latitude = currentLocation.coordinate.latitude
            let longitude = currentLocation.coordinate.longitude
            let userID = UserDefaults.standard.string(forKey: "userID")!
        
            // Get the category text.
            var categoryText: String = "Miscellaneous"
            if (Category.currentTitle! != "Select a Category") {
                categoryText = Category.currentTitle!
            }
        
            // Get the answer text.
            var ansText: String = ""
            
            print("HELLO")
            for i in 0...(self.Answers.numberOfRows(inSection: 0) - 2) {
                let ind = NSIndexPath(row: i, section: 0)
                let cell = self.Answers.cellForRow(at: ind as IndexPath) as! TableViewCell_AnswerCell
                if i == 0 {
                    ansText = ansText + cell.Answer.text!
                } else {
                    ansText = ansText + "," + cell.Answer.text!
                }
            }
        
            let qText: String = self.Question.text

            QuestionData.createNewQuestion(userID: userID, question: qText, answers: ansText, latitude: latitude, longitude: longitude, category: categoryText) { data in
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "postedQuestion", sender: self)
                }
            }
        } else {
            let alertController = UIAlertController(title: "Not a Valid Question!", message:
                ErrorMessage, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (self.activeTextField != nil) {
            self.activeTextField!.resignFirstResponder()
            self.activeTextField = nil
        }
        self.activeTextField = textField
        
        if(self.keyboardIsShowing)
        {
            self.animateTextField(up: true)
        }
        
        return true
    }
    
    func animateTextField(up: Bool) {
        if (self.activeTextField != nil) {
            let movement = (up ? -kbHeight : kbHeight)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement!)
            })
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.count + string.count - range.length
        return newLength <= maxAnswerLength
    }
    
    // MARK: Methods to deal with keyboard popping up.
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification)
    {
        self.keyboardIsShowing = true
        
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                kbHeight = keyboardSize.height / 2
                self.animateTextField(up: true)
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        self.keyboardIsShowing = false
        
        self.animateTextField(up: false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if (self.activeTextField != nil)
        {
            self.activeTextField!.resignFirstResponder()
            self.activeTextField = nil
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.activeTextField = nil
        
        return true
    }
    
    // MARK: CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.performSegue(withIdentifier: "locationServicesDisabled", sender: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: NSArray) {
        let newLocation = locations[0] as? CLLocation
        currentLocation = newLocation
    }

    // MARK: Methods to transition to another view controller.
    
    @IBAction func getCategory(with sender: UIButton) {
        self.performSegue(withIdentifier: "chooseCategory", sender: self)
    }
    
    @IBAction func cancelPost(with sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "chooseCategory") {
            let upcoming: ViewController_chooseCategory = segue.destination as! ViewController_chooseCategory
            
            upcoming.oldCategory = Category.currentTitle!
        }
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Miscellaneous methods
    
    func getAnswerArray() -> Array<String> {
        var answers: Array<String> = []
        for i in 0...(self.Answers.numberOfRows(inSection: 0) - 2) {
            let ind = NSIndexPath(row: i, section: 0)
            let cell = self.Answers.cellForRow(at: ind as IndexPath) as! TableViewCell_AnswerCell
            answers.append(cell.Answer.text!)
        }
        return answers
    }
    
    func validQuestion() -> (Bool, String?) {
        if (Question.text.count <= 0) {
            return (false, "Question left blank")
        } else {
            let currentAnswers = getAnswerArray()
            if currentAnswers.contains("") {
                return (false, "Answer left blank")
            } else if (currentLocation == nil) {
                return (false, "Location services must be enabled to post")
            }
        }
        return (true, nil)
    }

}
