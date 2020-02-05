//
//  TableViewCell_Question.swift
//  Touche
//
//  Class used for table view cells in the ViewController and ViewController_Profile views.
//
//
//  Created by Michael Manhard on 5/6/15.
//  Copyright (c) 2015 Michael Manhard. All rights reserved.
//

import UIKit

class TableViewCell_Question: UITableViewCell {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var Answers:NSArray!
    var QUID:Int!
    var numVote:Int!
    var qCategory:String!
    

}
