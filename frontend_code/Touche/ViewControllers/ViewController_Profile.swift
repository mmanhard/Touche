//
//  ViewController_Profile.swift
//  Prototype
//
//  View controller for the profile view.
//
//  Updated by Michael Manhard on 9/1/20.
//

import UIKit

class ViewController_Profile: UIViewController,  UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView:UITableView!
    @IBOutlet weak var homeButton: UIButton!
    
    var questions_asked: [Question] = []
    var questions_answered: [Question] = []
    var questionPass : Question!
    var asked: Bool = true
    
    // MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the touche icon as the header button and resize it.
        let image = UIImage(named:"touche_icon.png") as UIImage?
        let size = CGSize(width: 36, height: 36)
        self.homeButton.setImage(Utility.RBResizeImage(image: image!, targetSize: size), for: .normal)
        
        // Configure the table.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTable()
    }
    
    // MARK: TableView Methods
    
    // Updates the table after get questions from the backend for the current user.
    func updateTable() {
        // Get the current user.
        if let user = User.getCurrentUser() {
            // If there is a current user, get questions asked by that user.
            user.getQuestionsAsked() { data in
                self.questions_asked = QuestionData(data: data!).questionData!
                
                // After getting questions asked, get questions answer by the user and reload the table.
                user.getQuestionsAnswered() { data in
                    self.questions_answered = QuestionData(data: data!).questionData!

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        } else {
            // If unsuccesful, log out as the user needs to re enter credentials.
            self.logOut()
        }
    }
    
    // Determine the number of rows in the table.
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
    
    // Determine the row for the given index.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as! TableViewCell_Question
        
        // Get the appropriate question.
        var question : Question
        if (asked) {
            question = self.questions_asked[indexPath.row]
        } else {
            question = self.questions_answered[indexPath.row]
        }
        
        // Extract all display information from the question.
        cell.questionLabel.text = question.question
        cell.timeLabel.text = Utility.getTime(timeDifference: question.datetime)
        cell.Answers = question.answers as NSArray
        cell.QUID = question.id
        cell.numVote = question.total_votes
        cell.qCategory = question.category
        
        // Determine the number of votes and format the string for it.
        let numVotes = question.total_votes
        if numVotes == 1 {
            cell.voteCountLabel.text = "\(numVotes) vote"
        } else {
            cell.voteCountLabel.text = "\(numVotes) votes"
        }
        
        return cell
    }
    
    // Handler for selecting the row at the given index. Transition to the voting view controller for that item.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        // Get the appropriate question.
        if asked {
            self.questionPass = self.questions_asked[indexPath.row]
        } else {
            self.questionPass = self.questions_answered[indexPath.row]
        }
        
        // Transition to the view for the chosen question and deselect the item.
        self.performSegue(withIdentifier: "viewQuestionFromProfile", sender: self)
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    // MARK: Transition Methods
    
    // Handler for selecting post question. Transitions to the post view controller.
    @IBAction func postQuestion(with sender: UIButton) {
        self.performSegue(withIdentifier: "postFromProfile", sender: self)
    }
    
    // Handler for selecting the go home button. Transitions back to the most recent view.
    @IBAction func goHome(with sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // Handler for selecting log out. Logs the user out and goes to the login view.
    @IBAction func logOut(with sender: UIButton) {
        self.logOut()
    }
    
    // Handler for preparing for segues. Primarily deals with passing data to the next view.
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
    
    // Logs the user out and goes to the login view.
    private func logOut() {
        User.logOut()
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // Handler for toggling the asked or answered toggle. Reloads the table with data based on the toggle.
    @IBAction func askedOrAnswered(with sender: AnyObject) {
        asked = !asked
        self.tableView.reloadData()
    }
    
}


