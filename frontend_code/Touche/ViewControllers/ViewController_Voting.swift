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
    
    private let sectionInsets = UIEdgeInsets(top: 10.0,
    left: 20.0,
    bottom: 10.0,
    right: 20.0)
    
    // MARK: Methods to set up current view.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (prevScreen != nil) {
            let image = UIImage(named:"profile.png") as UIImage?
            let size = CGSize(width: 22, height: 22)
            self.backButton.setImage(RBResizeImage(image: image!, targetSize: size), for: UIControl.State.normal)
        } else {
            let image = UIImage(named:"touche_icon.png") as UIImage?
            let size = CGSize(width: 36, height: 36)
            self.backButton.setImage(RBResizeImage(image: image!, targetSize: size), for: UIControl.State.normal)
        }
        
        self.Question.text = self.question.question
        self.Question.sizeToFit()
        self.CategorySlot.text = self.question.category
        
        self.collectionView.reloadData()
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

    // MARK: Collection view methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCell", for: indexPath) as! CollectionViewCell_Voting
        var answerID : Int
        if self.question.answers.count == 2 {
            answerID = indexPath.section
        } else {
            answerID = indexPath.section * 2 + indexPath.row
        }
        
        if (self.voteBool == true)
        {
            let scaling = CGFloat(self.question.answers[answerID].numvotes) / CGFloat(self.question.total_votes)
            cell.backgroundColor =  UIColor(red:CGFloat(1.0),green: CGFloat(0.0),blue: CGFloat(0.0), alpha:CGFloat(0.7*scaling))
            cell.Label.backgroundColor =  UIColor(red:CGFloat(0.0),green: CGFloat(0.0),blue: CGFloat(0.0), alpha:CGFloat(0))
            let scalingPercentage = Int(round(scaling * 100))
            cell.Percentage.isHidden = false
            cell.Percentage.text = "\(scalingPercentage)%"
        } else {
            cell.Percentage.isHidden = true
            cell.Label.backgroundColor = UIColor.white
        }
        cell.Label.text = self.question.answers[answerID].text
        
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.7)
        cell.layer.borderWidth = 5
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let answerID = indexPath.row + indexPath.section * 2
        
        QuestionData.voteOnQuestion(questionId: self.question.id, answerID: answerID, doOnSuccess: { data in
            self.question.total_votes = self.question.total_votes + 1
            self.question.answers[answerID].numvotes = self.question.answers[answerID].numvotes + 1
            self.voteBool = true
            DispatchQueue.main.async {
                collectionView.deselectItem(at: indexPath, animated: false)
                self.collectionView.reloadData()
            }
        }, doOnFailure: { data, response, error in
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
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numItemsInSection = CGFloat(collectionView.numberOfItems(inSection: indexPath.section))
        let paddingSpaceX = sectionInsets.left * (numItemsInSection+1)
        let availableWidth = collectionView.frame.width - paddingSpaceX
        let widthPerItem = availableWidth / numItemsInSection
        
        let numSections = CGFloat(collectionView.numberOfSections)
        let paddingSpaceY = sectionInsets.bottom * (numSections+1)
        let availableHeight = collectionView.frame.height - paddingSpaceY
        let heightPerItem = availableHeight / numSections
      
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
      return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return sectionInsets.left
    }
    
    
    // MARK: Methods to transition to another view controller.
    
    @IBAction func cancelVote(with sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}
