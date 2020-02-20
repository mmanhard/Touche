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

class ViewController_Voting: UIViewController,  UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet var tableView:UITableView!
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
        self.CategorySlot.text = self.question.category
        
        self.tableView.reloadData()
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
    
    // MARK: UITableViewDataSource and UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.question.answers.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row != 0) {
            let answerID = indexPath.row - 1
            let cell:TableViewCell_Voting = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell_Voting;
            cell.textLabel!.text = self.question.answers[answerID].text
            if (self.voteBool == true)
            {
                let scaling = CGFloat(self.question.answers[answerID].numvotes) / CGFloat(self.question.total_votes)
                cell.Label.backgroundColor =  UIColor(red:CGFloat(1.0),green: CGFloat(0.0),blue: CGFloat(0.0), alpha:CGFloat(scaling))
                let scalingPercentage = Int(round(scaling * 100))
                cell.Percentage.isHidden = false
                cell.Percentage.text = "\(scalingPercentage)%"
                cell.selectionStyle = .none
            } else {
                cell.Percentage.isHidden = true
                cell.Label.backgroundColor = UIColor.white
            }
            return cell
        } else {
            let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "otherCell") as! TableViewCell
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row != 0) {
            let answerID = indexPath.row-1
            
            QuestionData.voteOnQuestion(questionId: self.question.id, answerID: answerID, doOnSuccess: { data in
                self.question.total_votes = self.question.total_votes + 1
                self.question.answers[answerID].numvotes = self.question.answers[answerID].numvotes + 1
                self.voteBool = true
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }, doOnFailure: { data, response, error in
                DispatchQueue.main.async {
                    let message = String(decoding: data!, as: UTF8.self)
                    let alert = UIAlertController(title: "Please try again.", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in }))
                    self.present(alert, animated: true, completion: nil)
                    self.voteBool = true
                }
            })
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    // MARK: Methods to transition to another view controller.
    
    @IBAction func cancelVote(with sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}
