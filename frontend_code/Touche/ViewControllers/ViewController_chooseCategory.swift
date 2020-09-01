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
    
    let minRowHeight: CGFloat = 36.0
    
    private let sectionInsets = UIEdgeInsets(top: 10.0,
    left: 20.0,
    bottom: 10.0,
    right: 20.0)
    
    // MARK: UITableViewDataSource and UITableViewDelegate Methods

    
    // MARK: Transition to Other VC
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (Constants.availCategories.count / 2 + Constants.availCategories.count % 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section < (Constants.availCategories.count / 2) {
            return 2
        } else {
            return 2 - (Constants.availCategories.count % 2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CollectionViewCell
    
        let categoryNum = 2 * (indexPath.section) + indexPath.row
        cell.titleLabel.text = Constants.availCategories[categoryNum]
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.7)
        cell.layer.borderWidth = 5
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numItemsInSection = CGFloat(collectionView.numberOfItems(inSection: indexPath.section))
        let paddingSpaceX = sectionInsets.left * (numItemsInSection + 1)
        let availableWidth = collectionView.frame.width - paddingSpaceX
        print(availableWidth)
        let widthPerItem = availableWidth / numItemsInSection
        
        let numSections = CGFloat(collectionView.numberOfSections)
        let paddingSpaceY = sectionInsets.bottom * (numSections+1)
        let availableHeight = collectionView.frame.height - paddingSpaceY
        let heightPerItem = availableHeight / numSections
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
      return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let numVCs = self.navigationController?.viewControllers.count
        let nextVC = self.navigationController?.viewControllers[numVCs! - 2] as! ViewController_Post
        let categoryNum = 2 * (indexPath.section) + indexPath.row
        nextVC.chosenCategory = Constants.availCategories[categoryNum]
        collectionView.deselectItem(at: indexPath, animated: true)
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancel(with sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
}
