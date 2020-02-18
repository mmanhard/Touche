//
//  ViewController.swift
//  Prototype
//
//  Created by Paimon Pakzad on 4/7/15.
//  Copyright (c) 2015 cos333. All rights reserved.
//

import UIKit

class ViewController_Profile: UIViewController,  UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView:UITableView!
    @IBOutlet weak var homeButton: UIButton!
    var selectedIndex = -1
    
    var questions_asked: [Question] = []
    var questions_answered: [Question] = []
    
    var questionPass : Question!
    
    var asked: Bool = true
    
    // MARK: Methods to set up current view.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let image = UIImage(named:"touche_icon.png") as UIImage?
        let size = CGSize(width: 36, height: 36)
        self.homeButton.setImage(RBResizeImage(image: image!, targetSize: size), for: .normal)
        
        updateTable()
        
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
        if let user = User.getCurrentUser() {
            user.getQuestionsAsked() { data in
                self.questions_asked = QuestionData(data: data!).questionData!
                
                user.getQuestionsAnswered() { data in
                    self.questions_answered = QuestionData(data: data!).questionData!

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        } else {
            // ******************
            // MUST ADD EXCEPTION CASE!!!!
            // ********
            print("SHOULD HANDLE ERROR")
        }
    }
    
    // MARK: UITableViewDataSource and UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (asked)
        {
            return self.questions_asked.count
        }
        else
        {
            return self.questions_answered.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as! TableViewCell_Question
        
        var question : Question
        if (asked) {
            question = self.questions_asked[indexPath.row]
        } else {
            question = self.questions_answered[indexPath.row]
        }
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if asked {
            self.questionPass = self.questions_asked[indexPath.row]
        } else {
            self.questionPass = self.questions_answered[indexPath.row]
        }
        
        self.performSegue(withIdentifier: "viewQuestionFromProfile", sender: self)
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    // MARK: Methods to transition to another view controller.
    
    @IBAction func postQuestion(with sender: UIButton) {
        self.performSegue(withIdentifier: "postFromProfile", sender: self)
    }
    
    @IBAction func goHome(with sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "viewQuestionFromProfile")
        {
            let upcoming: ViewController_Voting = segue.destination as! ViewController_Voting
            upcoming.question = self.questionPass
            upcoming.prevScreen = "Profile"
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
    
    @IBAction func askedOrAnswered(with sender: AnyObject) {
        asked = !asked
        self.tableView.reloadData()
    }
    
}


