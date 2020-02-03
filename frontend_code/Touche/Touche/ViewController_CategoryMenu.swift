//
//  ViewController_CategoryMenu.swift
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

class ViewController_CategoryMenu: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bar: UIView!
    @IBOutlet weak var homeButton: UIButton!
    
    
    let categories = ["Academics", "Business", "Food", "Health", "Humor", "Movies", "Music", "Sex", "Social", "Sports", "Miscellaneous", "All Categories"]
    var oldCategory: String?
    
    let minRowHeight: CGFloat = 36.0
    
    // MARK: Methods to setup current view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named:"touche_icon.png") as UIImage?
        let size = CGSize(width: 36, height: 36)
        self.homeButton.setImage(RBResizeImage(image!, targetSize: size), forState: .Normal)
        
        self.tableView.reloadData()
    }
    
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // MARK: UITableViewDataSource and UITableViewDelegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) as! TableViewCell
        
        cell.titleLabel.text = self.categories[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let barHeight = Float(self.bar.frame.size.height)
        let viewHeight = Float(self.view.frame.height)
        let rowHeight = (viewHeight - barHeight) / Float(categories.count)

        if (CGFloat(rowHeight) < minRowHeight) {
            return minRowHeight
        } else {
            return CGFloat(rowHeight)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.performSegueWithIdentifier("categorySelected", sender: self)
    }
    
    // MARK: Methods to transition to another view controller
    
    @IBAction func cancelCategorySelection(sender: UIButton) {
        self.performSegueWithIdentifier("categoryNotSelected", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "categoryNotSelected")
        {
            var upcoming: ViewController = segue.destinationViewController as! ViewController
            
            upcoming.categoryString = oldCategory!
        }
        if (segue.identifier == "categorySelected")
        {
            var upcoming: ViewController = segue.destinationViewController as! ViewController
            
            let indexPath = self.tableView.indexPathForSelectedRow()!
            
            upcoming.categoryString = self.categories[indexPath.row]
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }

}
