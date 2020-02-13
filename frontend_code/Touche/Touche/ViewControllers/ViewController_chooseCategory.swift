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
    
    var categories = ["Academics", "Business", "Food", "Health", "Humor", "Movies", "Music", "Sex", "Social", "Sports", "Miscellaneous"]
    var oldCategory: String?
    
    let minRowHeight: CGFloat = 36.0
    
    // MARK: UITableViewDataSource and UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int{
            return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! TableViewCell;
        cell.titleLabel.text = self.categories[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let barHeight = Float(self.bar.frame.size.height)
        let viewHeight = Float(self.view.frame.height)
        let rowHeight = (viewHeight - barHeight) / Float(categories.count)
        
        if (CGFloat(rowHeight) < minRowHeight) {
            return minRowHeight
        } else {
            return CGFloat(rowHeight)
        }
    }
    
    // MARK: Transition to Other VC
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let numVCs = self.navigationController?.viewControllers.count
        let nextVC = self.navigationController?.viewControllers[numVCs! - 2] as! ViewController_Post
        nextVC.chosenCategory = self.self.categories[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancel(with sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
}
