//
//  Question.swift
//  Touche
//
//
//  Model for the Question resource.
//
//  Created by Michael Manhard on 2/10/20.
//  Copyright © 2020 Michael Manhard. All rights reserved.
//

import Foundation

class Question : Decodable {
    struct Answer : Decodable {
        var numvotes: Int
        var text: String
    }
    var answers: [Answer]
    var asker: Int
    var category: String
    var datetime: Float
    var id: Int
    var lat: Double
    var lng: Double
    var question: String
    var responders: [Int]
    var total_votes: Int
    
    init(answers: [Answer], asker: Int, category: String, datetime: Float, id: Int, lat: Double, lng: Double, question: String, responders: [Int], total_votes: Int) {
        self.answers = answers
        self.asker = asker
        self.category = category
        self.datetime = datetime
        self.id = id
        self.lat = lat
        self.lng = lng
        self.question = question
        self.responders = responders
        self.total_votes = total_votes
        }
}
