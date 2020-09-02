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

class ViewController_chooseCategory: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bar: UIView!
    
    var oldCategory: String?
    
    // MARK: Collection View Methods
    
    // Determine the number of sections (2 categories per section).
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (Constants.availCategories.count / 2 + Constants.availCategories.count % 2)
    }
    
    // Determine the number of items in a section (2 unless at less section and number of sections is odd).
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section < (Constants.availCategories.count / 2) {
            return 2
        } else {
            return 2 - (Constants.availCategories.count % 2)
        }
    }
    
    // Populate each row of the category table.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CollectionViewCell
    
        // Set the category text.
        let categoryNum = 2 * (indexPath.section) + indexPath.row
        cell.titleLabel.text = Constants.availCategories[categoryNum]
        
        // Update display of the cell.
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.7)
        cell.layer.borderWidth = 5
        return cell
    }
    
    // Determine the size of the collection view item at the given index path.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Determine the width of the item.
        let numItemsInSection = CGFloat(collectionView.numberOfItems(inSection: indexPath.section))
        let paddingSpaceX = Constants.typSectionInsets.left * (numItemsInSection + 1)
        let availableWidth = collectionView.frame.width - paddingSpaceX
        print(availableWidth)
        let widthPerItem = availableWidth / numItemsInSection
        
        // Determine the height of the item.
        let numSections = CGFloat(collectionView.numberOfSections)
        let paddingSpaceY = Constants.typSectionInsets.bottom * (numSections+1)
        let availableHeight = collectionView.frame.height - paddingSpaceY
        let heightPerItem = availableHeight / numSections
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    // Determine the insets for each section.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
      return Constants.typSectionInsets
    }
    
    // Determine the minimum line spacing for each section.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return Constants.typSectionInsets.left
    }
    
    // Handler for selecting a given category.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let numVCs = self.navigationController?.viewControllers.count
        let nextVC = self.navigationController?.viewControllers[numVCs! - 2] as! ViewController_Post
        
        // Get the category of the selected cell, set the category string of the root
        // view controller equal to it, and deselect the cell.
        let categoryNum = 2 * (indexPath.section) + indexPath.row
        nextVC.chosenCategory = Constants.availCategories[categoryNum]
        collectionView.deselectItem(at: indexPath, animated: true)
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: Transition Methods
    
    // Handler for selecting cancel button. Transitions back to the most recent view controller.
    @IBAction func cancel(with sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
}
