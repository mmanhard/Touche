//
//  ViewController_chooseCategory.swift
//  Touche
//
//
//  View Controller for the view where a user selects a category for a question they are about to post.
//
//
//  Created by Michael Manhard on 5/6/15.
//  Copyright (c) 2015 Michael Manhard. All rights reserved.
//

import UIKit

class ViewController_chooseCategory: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bar: UIView!
    
    var categoryArray = ["Academics", "Business", "Food", "Health", "Humor", "Movies", "Music", "Sex", "Social", "Sports", "Miscellaneous"]
    var questionText: String?
    var answerArray: Array<String>?
    var oldCategory: String?
    
    let minRowHeight: CGFloat = 36.0
    
    // MARK: UITableViewDataSource and UITableViewDelegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int{
            return self.categoryArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:TableViewCell = self.tableView.dequeueReusableCellWithIdentifier("categoryCell") as! TableViewCell;
        cell.titleLabel.text = self.categoryArray[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let barHeight = Float(self.bar.frame.size.height)
        let viewHeight = Float(self.view.frame.height)
        let rowHeight = (viewHeight - barHeight) / Float(categoryArray.count)
        
        if (CGFloat(rowHeight) < minRowHeight) {
            return minRowHeight
        } else {
            return CGFloat(rowHeight)
        }
    }
    
    // MARK: Methods to transition to another view controller
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("chosen", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    @IBAction func cancel(sender: UIButton) {
        self.performSegueWithIdentifier("chosen", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "chosen") {
            var upcoming: ViewController_Post = segue.destinationViewController as! ViewController_Post
            if (self.tableView.indexPathForSelectedRow() != nil) {
                let indexPath = self.tableView.indexPathForSelectedRow()!
                
                let title = self.categoryArray[indexPath.row]
                
                upcoming.chosenCategory = title
                
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            } else {
                upcoming.chosenCategory = self.oldCategory!
            }
            
            upcoming.qTextSegue = self.questionText!
            upcoming.answerArray = self.answerArray!
        }
    }

}
