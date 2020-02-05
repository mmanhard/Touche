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
        self.homeButton.setImage(RBResizeImage(image: image!, targetSize: size), for: UIControl.State.normal)
        
        self.tableView.reloadData()
    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! TableViewCell
        
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
            print(CGFloat(rowHeight))
            return CGFloat(rowHeight)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("HELLO")
        self.performSegue(withIdentifier: "categorySelected", sender: self)
    }
    
    // MARK: Methods to transition to another view controller
    
    @IBAction func cancelCategorySelection(sender: UIButton) {
        self.performSegue(withIdentifier: "categoryNotSelected", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "categoryNotSelected")
        {
            let upcoming: ViewController = segue.destination as! ViewController
            
            upcoming.categoryString = oldCategory!
        }
        if (segue.identifier == "categorySelected")
        {
            let upcoming: ViewController = segue.destination as! ViewController
            
            let indexPath = self.tableView.indexPathForSelectedRow!
            
            upcoming.categoryString = self.categories[indexPath.row]
            
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }

}
