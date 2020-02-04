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
    
    var Answers: NSMutableArray = NSMutableArray()
    var answersNum: NSMutableArray = NSMutableArray()
    var Question_passed: String = "Hello"
    var passed_array:NSArray = []
    var prevView:String!
    var quid:Int!
    var totVote:Int!
    var ansNum:Int!
    var category:String!
    var selectedIndex = -1
    var voteBool = 0
    var voteChange = 0
    var uuid:String = UserDefaults.standard.string(forKey: "uuid")!
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
        
        // Do any additional setup after loading the view, typically from a nib.
        Question.text = Question_passed
        CategorySlot.text = category
        for answer in passed_array {
            if let ans = answer as? NSDictionary {
                let answerVotes = ans.value(forKey: "text")! as! String
                self.Answers.add(answerVotes)
                
                let answerNum = ans.value(forKey: "numvotes")! as! Float
                self.answersNum.add(answerNum)
            }
        }
        
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
        return self.Answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row != 0) {
            let cell:TableViewCell_Voting = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell_Voting;
            let q2text = self.Answers.object(at: indexPath.row) as! String
            let qtext = q2text.replacingOccurrences(of: "_", with: " ")
            cell.textLabel!.text = qtext
            self.ansNum = self.answersNum.object(at: indexPath.row) as? Int
            if (self.voteBool == 1)
            {
                let scaling = CGFloat(self.ansNum * 100) / CGFloat(self.totVote)
                cell.Label.backgroundColor =  UIColor(red:CGFloat(1.0),green: CGFloat(0.0),blue: CGFloat(0.0), alpha:CGFloat(1.0));
                cell.Label.backgroundColor = UIColor(hue: 1.0, saturation: scaling, brightness: 1.0, alpha: 1.0)
                let scaling3 = Int(round(scaling))
                cell.Percentage.isHidden = false
                cell.Percentage.text = "\(scaling3)%"
            } else {
                cell.Percentage.isHidden = true
                cell.Label.backgroundColor = UIColor.white
            }
            return cell
        } else {
            let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "otherCell") as! TableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row != 0) {
            let quidPost = quid
            let anidPost = indexPath.row
            let getString1 =  "https://proj-333.herokuapp.com/vote?question_id=" + String(quidPost!)
            let getString2 = "&answer_id=" + String(anidPost)
            let getString3 = "&user_id="+UserDefaults.standard.string(forKey: "iuid")!
            let getString = getString1+getString2+getString3
            let url = NSURL(string: getString)
            let session = URLSession.shared
            let dataTask = session.dataTaskWithURL(url!, completionHandler: { (data: NSData!, response:URLResponse!, error: NSError!) -> Void in
                print("Task completed")
                if(error != nil) {
                
                    // If there is an error in the web request, print it to the console
                
                    print(error.localizedDescription)
                
                }
                print(NSString(data: data, encoding: NSUTF8StringEncoding)!)
                if (NSString(data: data, encoding: NSUTF8StringEncoding) == "success")
                {
                    let oldVoteCount = self.answersNum.objectAtIndex(indexPath.row) as! Int
                    self.answersNum.replaceObjectAtIndex(indexPath.row, withObject: oldVoteCount + 1)
                    self.totVote = self.totVote + 1
                }
                    self.voteBool = 1
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                }
            })
            dataTask.resume()
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    // MARK: Methods to transition to another view controller.
    
    @IBAction func cancelVote(sender: UIButton) {
        if (prevScreen != nil) {
            self.performSegue(withIdentifier: "noVoteGoProfile", sender: self)
        } else {
            self.performSegue(withIdentifier: "noVoteGoHome", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "noVoteGoHome")
        {
            var upcoming: ViewController = segue.destination as! ViewController
        }
        
        if (segue.identifier == "noVoteGoProfile")
        {
            var upcoming: ViewController_Profile = segue.destination as! ViewController_Profile
        }
    }
    
}
