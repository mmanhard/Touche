//
//  ViewController_Voting.swift
//  Prototype
//
//
//  View controller to view and vote on questions.
//
//
//  Created by Paimon Pakzad on 4/15/15.
//  Copyright (c) 2015 cos333. All rights reserved.
//
import UIKit

class ViewController_Voting: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var Question:UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var CategorySlot: UILabel!
    
    var question: Question!
    var prevView:String!
    var selectedIndex = -1
    var voteBool: Bool!
    var voteChange = 0
    var firstClick = 0
    
    var prevScreen: String?
    
    // MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Determine the appropriate icon to display in the header.
        // Profile icon if coming from profile page (prev screen will not be nil).
        // Touche icon otherwise.
        if (prevScreen != nil) {
            let image = UIImage(named:"profile.png") as UIImage?
            let size = CGSize(width: 22, height: 22)
            self.backButton.setImage(Utility.RBResizeImage(image: image!, targetSize: size), for: UIControl.State.normal)
        } else {
            let image = UIImage(named:"touche_icon.png") as UIImage?
            let size = CGSize(width: 36, height: 36)
            self.backButton.setImage(Utility.RBResizeImage(image: image!, targetSize: size), for: UIControl.State.normal)
        }
        
        // Determine and format the question and its category.
        self.Question.text = self.question.question
        self.Question.sizeToFit()
        self.CategorySlot.text = self.question.category
        
        // Determine if the user has voted on this question before.
        if let currentUser = User.getCurrentUser() {
            let userID = currentUser.userID
            if (userID != nil) {
                for responder in self.question.responders {
                    if (responder == userID) {
                        self.voteBool = true
                        break
                    }
                }
            }
        }
        
        self.collectionView.reloadData()
    }

    // MARK: Collection View methods
    
    // Determine the total number of sections. Always 2.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    // Determine the number of items in a section.
    // If 4 total answers, all sections have 2 items.
    // If 3 total answers, first section has 2 items, second has 1.
    // If 2 total answers, 1 item per section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.question.answers.count {
        case 2:
            return 1
        case 3:
            return 2 - section
        case 4:
            return 2
        default:
            return 1
        }
    }
    
    // Populate each item of the answers collection.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCell", for: indexPath) as! CollectionViewCell_Voting
        var answerID : Int
        
        if self.question.answers.count == 2 {
            answerID = indexPath.section
        } else {
            answerID = indexPath.section * 2 + indexPath.row
        }
        
        // If the user has voted, show the percentage of total votes for the current answer and modify the background color based
        // on that percentage.
        // Otherwise, hide the percentages for the answer and make the cell white.
        if (self.voteBool == true)
        {
            // Determine the ratio (and percentage) of votes for the current answer out of all votes.
            let scaling = CGFloat(self.question.answers[answerID].numvotes) / CGFloat(self.question.total_votes)
            let scalingPercentage = Int(round(scaling * 100))
            
            // Determine the background color of the cell.
            cell.backgroundColor =  UIColor(red:CGFloat(1.0),green: CGFloat(0.0),blue: CGFloat(0.0), alpha:CGFloat(0.7*scaling))
            cell.Label.backgroundColor =  UIColor(red:CGFloat(0.0),green: CGFloat(0.0),blue: CGFloat(0.0), alpha:CGFloat(0))
            
            // Show the percentage.
            cell.Percentage.isHidden = false
            cell.Percentage.text = "\(scalingPercentage)%"
        } else {
            cell.Percentage.isHidden = true
            cell.Label.backgroundColor = UIColor.white
        }
        
        cell.Label.text = self.question.answers[answerID].text
        
        // Add styles to the cell.
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.7)
        cell.layer.borderWidth = 5
        
        return cell
    }
    
    // Handler for selecting a given answer. On success, updates the display with the new number of votes. On failure, displays
    // an alert with information about the error.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Determine the selected answer id.
        var answerID = indexPath.row
        if (self.question.answers.count == 2) {
            answerID += indexPath.section
        } else {
            answerID += indexPath.section * 2
        }
        
        // Send a request to the backend indicating the user has voted on the question.
        QuestionData.voteOnQuestion(questionId: self.question.id, answerID: answerID, doOnSuccess: { data in
            
            // Update the number of votes displayed and toggle the flag indicating the user has voted.
            self.question.total_votes = self.question.total_votes + 1
            self.question.answers[answerID].numvotes = self.question.answers[answerID].numvotes + 1
            self.voteBool = true
            
            DispatchQueue.main.async {
                collectionView.deselectItem(at: indexPath, animated: false)
                self.collectionView.reloadData()
            }
        }, doOnFailure: { data, response, error in
            // On failure, display an alert about the failure.
            DispatchQueue.main.async {
                let message = String(decoding: data!, as: UTF8.self)
                let alert = UIAlertController(title: "Please try again.", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in }))
                self.present(alert, animated: true, completion: nil)
                self.voteBool = true
                DispatchQueue.main.async {
                    collectionView.deselectItem(at: indexPath, animated: false)
                    self.collectionView.reloadData()
                }
            }
        })
    }
    
    // Determine the size of the collection view item at the given index path.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Determine the width of the item.
        let numItemsInSection = CGFloat(collectionView.numberOfItems(inSection: indexPath.section))
        let paddingSpaceX = Constants.typSectionInsets.left * (numItemsInSection+1)
        let availableWidth = collectionView.frame.width - paddingSpaceX
        let widthPerItem = availableWidth / numItemsInSection
        
        // Determine the height of the item.
        let numSections = CGFloat(collectionView.numberOfSections)
        let paddingSpaceY = (Constants.typSectionInsets.bottom + Constants.typSectionInsets.top) * numSections
        let availableHeight = collectionView.frame.height - paddingSpaceY
        let heightPerItem = availableHeight / numSections
      
        return CGSize(width: widthPerItem, height: heightPerItem)
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
    
    
    // MARK: Transition Methods
    
    // Handler for selecting cancel button. Transitions back to the most recent view controller.
    @IBAction func cancelVote(with sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}
