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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int{
            return self.categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! TableViewCell;
        cell.titleLabel.text = self.categoryArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let barHeight = Float(self.bar.frame.size.height)
        let viewHeight = Float(self.view.frame.height)
        let rowHeight = (viewHeight - barHeight) / Float(categoryArray.count)
        
        if (CGFloat(rowHeight) < minRowHeight) {
            return minRowHeight
        } else {
            return CGFloat(rowHeight)
        }
    }
    
    // MARK: Transition to Other VC
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "chosen", sender: self)
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }

    @IBAction func cancel(with sender: UIButton) {
        self.performSegue(withIdentifier: "chosen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "chosen") {
            let upcoming: ViewController_Post = segue.destination as! ViewController_Post
            if (self.tableView.indexPathForSelectedRow != nil) {
                let indexPath = self.tableView.indexPathForSelectedRow!
                
                let title = self.categoryArray[indexPath.row]
                
                upcoming.chosenCategory = title
                
                self.tableView.deselectRow(at: indexPath, animated: true)
            } else {
                upcoming.chosenCategory = self.oldCategory!
            }
            
            upcoming.qTextSegue = self.questionText!
            upcoming.answerArray = self.answerArray!
        }
    }

}
