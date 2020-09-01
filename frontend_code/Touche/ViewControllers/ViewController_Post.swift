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

class ViewController_Post: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var Answers : UICollectionView!
    @IBOutlet weak var Category: UIButton!
    @IBOutlet weak var placeholder: UILabel!
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var Question: UITextView!
    @IBOutlet weak var backButton: UIButton!
    
    var keyboardFrame: CGRect = CGRect.null
    var viewIsUp: Bool = false
    weak var activeTextField: UITextField?
    weak var activeTextView: UITextView?
    
    var chosenCategory: String?
    var qTextSegue: String?
    var prevScreen: String?
    
    var answerArray = ["Yes", "No"] // Default answers are "Yes" and "No"
    var maxQuestionLength = 160
    var maxAnswerLength = 30
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    let rowHeight = 44
    let maxNumAnswers = 4
    var kbHeight: CGFloat!
    
    // MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the location manager delegate.
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = Constants.desiredLocAccuracy
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        currentLocation = self.locationManager.location
        
        // Set the top left button to be the right image.
        if (prevScreen != nil) {
            let image = UIImage(named:"profile.png") as UIImage?
            let size = CGSize(width: 22, height: 22)
            self.backButton.setImage(Utility.RBResizeImage(image: image!, targetSize: size), for: .normal)
        } else {
            let image = UIImage(named:"touche_icon.png") as UIImage?
            let size = CGSize(width: 36, height: 36)
            self.backButton.setImage(Utility.RBResizeImage(image: image!, targetSize: size), for: .normal)
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
        
        // Set the character count for the question and show a placeholder if there are no characters.
        textCount.text = "\(Question.text.count) / 160"
        placeholder.isHidden = Question.text.count > 0
        
        Category.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        self.Answers.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // If we came from the choose category view, set the question title equal to what it was before.
        if (self.chosenCategory != nil) {
            self.Category.setTitle(self.chosenCategory!, for: .normal)
        }
        
        // Add keyboard observers.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove keyboard observers.
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: TextView Methods
    
    // Determine if the text view should begin editining.
    // Always true, but move the view down if it is already up.
    // This is necessary for when the user goes from editing an answer that
    // would have been hidden by the keyboard to this textview.
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if self.viewIsUp {
            self.moveView(up: false)
        }
        
        return true
    }
    
    // Handler for when the text view changes. Updates the text count and toggles the placeholder's visibility.
    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = (textView.text.count != 0)
        textCount.text = "\(textView.text.count) / 160"
    }
    
    
    // Determine if the text view text should change.
    // True if the user does not type enter and if the question length is less than the max question length.
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
    
    // MARK: CollectionView Methods
    
    // Determine the total number of sections. Equal to the number of answers plus one (for the add answer button).
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.answerArray.count + 1
    }
    
    // Determine the number of items in a section. Always 1.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    // Populate each item of the answers collection.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.section < self.answerArray.count) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "answerCell", for: indexPath) as! CollectionViewCell_AnswerCell
            
            // Get the answer text.
            cell.Answer.text = answerArray[indexPath.section]
            
            // Set the cells textfield delegate to this controller.
            cell.Answer.delegate = self
            
            // Add styles to the cell.
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.7)
            cell.layer.borderWidth = 5
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addAnswerCell", for: indexPath)
            cell.layer.cornerRadius = 10
            return cell
        }
    }
    
    // Handler for selecting a given answer. On success, updates the display with the new number of votes. On failure, displays
    // an alert with information about the error.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Check if the last cell was selected (i.e. the add answer button). If so, add another cell to the answer table if we have not reached the max number of answers. Otherwise, display an alert.
        if (indexPath.section == self.answerArray.count) {
            if (self.answerArray.count < maxNumAnswers) {
                self.answerArray = getAnswerArray()
                self.answerArray.append("Answer \(indexPath.section + 1)")
            } else {
                let alertController = UIAlertController(title: "Cannot Add Answer", message: "Max Number of Answers Reached", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default,handler: nil))

                self.present(alertController, animated: true, completion: nil)
            }
        }
        collectionView.deselectItem(at: indexPath, animated: false)
        collectionView.reloadData()
    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        // Must have 2 answers and cannot delete final cell.
//        if (self.answerArray.count > 2 && indexPath.row < self.answerArray.count) {
//            if (editingStyle == UITableViewCell.EditingStyle.delete) {
//                answerArray = getAnswerArray()
//                answerArray.remove(at: indexPath.row)
//                tableView.deleteRows(at: [(indexPath as IndexPath)], with: UITableView.RowAnimation.automatic)
//            }
//            tableView.reloadData()
//        } else if (self.answerArray.count <= 2 && indexPath.row < self.answerArray.count) {
//            let alertController = UIAlertController(title: "Cannot Delete Answer", message: "Must have at least 2 answers", preferredStyle: UIAlertController.Style.alert)
//            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default,handler: nil))
//
//            self.present(alertController, animated: true, completion: nil)
//        }
//    }
    
    // Determine the size of the collection view item at the given index path.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Determine the width of the item.
        let paddingSpaceX = Constants.typSectionInsets.left + Constants.typSectionInsets.right
        let availableWidth = collectionView.frame.width - paddingSpaceX

        // Determine the height of the item.
        let numSections = CGFloat(collectionView.numberOfSections)
        let paddingSpaceY = (Constants.typSectionInsets.bottom + Constants.typSectionInsets.top) * numSections
        let availableHeight = collectionView.frame.height - paddingSpaceY
        let heightPerItem = availableHeight / numSections

        return CGSize(width: availableWidth, height: heightPerItem)
    }

    // Determine the insets for each section.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
      return Constants.typSectionInsets
    }

    // Determine the minimum line spacing for each section.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return Constants.typSectionInsets.left
    }
    
    // MARK: Method to post a question.
    
    // Handler for posting a question. Gets all data together for the question and posts it to the backend.
    // If successful, goes back to the most recent view controller.
    // If not, displays an alert indicating what went wrong.
    @IBAction func postQuestion(with sender: UIButton) {
        
        // Determine if the question is valid.
        let (isValid, ErrorMessage) = validQuestion()
        
        // If valid, post the question.
        if isValid {
            
            let latitude = currentLocation.coordinate.latitude
            let longitude = currentLocation.coordinate.longitude
        
            // Get the category text.
            var categoryText: String = "Miscellaneous"
            if (Category.currentTitle! != "Select a Category") {
                categoryText = Category.currentTitle!
            }
        
            // Format the answer text for the HTTP request. (i.e. concatenates all answers together with ',' as a delimiter).
            var ansText: String = ""
            for i in 0...(self.Answers.numberOfSections - 2) {
                let ind = NSIndexPath(row: 0, section: i)
                let cell = self.Answers.cellForItem(at: ind as IndexPath) as! CollectionViewCell_AnswerCell
                if i == 0 {
                    ansText = ansText + cell.Answer.text!
                } else {
                    ansText = ansText + "," + cell.Answer.text!
                }
            }
        
            let qText: String = self.Question.text

            // Create the question. If succesful, move to the most recent view controller.
            QuestionData.createNewQuestion(question: qText, answers: ansText, latitude: latitude, longitude: longitude, category: categoryText) { data in
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            // Otherwise, display an alert.
            let alertController = UIAlertController(title: "Not a Valid Question!", message:
                ErrorMessage, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Text Field Methods
    
    // Determines if the text field should begin editing.
    // It always does but sets the text field as the active one first.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activeTextField = textField
        return true
    }

    // Handler for when user changes the string in the text field. Allows changes if the replacement string is not longer than maxAnswerLength.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.count + string.count - range.length
        return newLength <= maxAnswerLength
    }
    
    // Determines if the text field should end editing when pressing the return button.
    // It always does but removes the field's responder first.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // Handler for when user stops editing text field.
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
    
    // MARK: Keyboard Handlers

    // Handler for when keyboard will show. Moves the view so the active text field is still in sight after the keyboard has moved up.
    @objc func keyboardWillShow(notification: NSNotification)
    {
        if let userInfo = notification.userInfo {
            
            // Determine the keyboard size.
            if let keyboardSize =  (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                
                // If the view is not already moved up, move it up.
                if (!self.viewIsUp) {
                    self.kbHeight = keyboardSize.height
                    if self.activeTextField != nil {
                        self.kbHeight = self.view.frame.height - keyboardSize.height - self.view.convert(self.activeTextField!.frame, from: self.activeTextField!.superview!).maxY - 100
                        self.moveView(up: true)
                    }
                }
            }
        }
    }

    // Handler for when keyboard will hide. Moves the view back down if it was up.
    @objc func keyboardWillHide(notification: NSNotification)
    {
        if self.viewIsUp {
            self.moveView(up: false)
        }
    }
    
    // Moves the view up to avoid the keyboard if up is true. If it is false, moves the view back down.
    private func moveView(up: Bool) {
        if self.kbHeight < 0 {
            let movement: CGFloat = (up ? self.kbHeight : -self.kbHeight)
            
            UIView.animate(withDuration: 0.3, animations: {
                 self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
             })
             self.viewIsUp = !self.viewIsUp
        }
     }

    // Handler for when user touches begin. If the text field is not active, removes its responder.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if (self.activeTextField != nil)
        {
            self.activeTextField!.resignFirstResponder()
            self.activeTextField = nil
        }
    }

    // MARK: Location Manager Methods
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.performSegue(withIdentifier: "locationServicesDisabled", sender: self)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: NSArray) {
        let newLocation = locations[0] as? CLLocation
        currentLocation = newLocation
    }

    // MARK: Transition Methods
    
    // Handler for selecting choose category. Transitions to the choose category view controller.
    @IBAction func getCategory(with sender: UIButton) {
        self.performSegue(withIdentifier: "chooseCategory", sender: self)
    }
    
    // Handler for selectingt the cancel button. Transitions to the most recent view controller.
    @IBAction func cancelPost(with sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // Handler for preparing for a segue. Primarily used for passing data to the next view controller.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "chooseCategory") {
            let upcoming: ViewController_chooseCategory = segue.destination as! ViewController_chooseCategory
            
            upcoming.oldCategory = Category.currentTitle!
        }
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Misc. methods
    
    // Get the answers from the display.
    func getAnswerArray() -> Array<String> {
        var answers: Array<String> = []
        
        // Go through each section in the answers collection and extract the answer string.
        for i in 0...(self.Answers.numberOfSections - 2) {
            let ind = NSIndexPath(row: 0, section: i)
            let cell = self.Answers.cellForItem(at: ind as IndexPath) as! CollectionViewCell_AnswerCell
            answers.append(cell.Answer.text!)
        }
        return answers
    }
    
    // Determines if the question is valid.
    // The question string and all answer strings must not be empty.
    // The current location must also not be nil.
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
