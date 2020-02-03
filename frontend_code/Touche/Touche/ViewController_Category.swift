//
//  ViewController_Category.swift
//  Prototype
//
//  Created by Michael Manhard on 4/28/15.
//  Copyright (c) 2015 cos333. All rights reserved.
//

import UIKit

class ViewController_Category: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var titleString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = self.titleString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "viewQuestionFromHome")
        {
            var upcoming: ViewController_Voting = segue.destinationViewController as! ViewController_Voting
            var svc = segue.destinationViewController as! ViewController_Voting;
            //        svc.passed_array = ANSWERS_pass
            //        svc.Question_passed = questionPass
            svc.prevView = "Category"
            /* let indexPath = self.tableView.indexPathForSelectedRow()!
            
            let titleString = self.categories.objectAtIndex(indexPath.row) as? String
            
            upcoming.titleString = titleString
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)*/
        }
        
    }
}
