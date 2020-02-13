//
//  QuestionData.swift
//  Touche
//
//  Created by Michael Manhard on 2/11/20.
//  Copyright © 2020 Michael Manhard. All rights reserved.
//

import Foundation

class QuestionData  {
    static var questionDomain = "http://127.0.0.1:5000/questions/"
    
    var questionData: [Question]?
    
    init(data: Data) {
        let decoder = JSONDecoder()
        do {
            self.questionData = try decoder.decode([Question].self, from: data)
        } catch {
            print("JSON error: \(error.localizedDescription)")
            self.questionData = nil
        }
    }
    
    class func getAllQuestions(latitude: Double?, longitude: Double?, sortBy: String?, category: String?, doOnSuccess: @escaping (Data?)->Void) {
        var args : [String : String]  = [:]
        if latitude != nil {
            args["lat"] = String(format: "%.8f", latitude!)
        }
        if longitude != nil {
            args["lng"] = String(format: "%.8f", longitude!)
        }
        if sortBy != nil {
            args["sort"] = sortBy!
        }
        if category != nil {
            args["category"] = category!
        }
        
        Utility.performDataTask(urlDomain: QuestionData.questionDomain, httpMethod: "GET", args: args, parameters: [:]) { data in
            doOnSuccess(data)
        }
    }
        
    class func createNewQuestion(userID: String, question: String, answers: String, latitude: Double, longitude: Double, category: String, doOnSuccess: @escaping (Data?)->Void) {
        let parameters : [String : Any] = ["user" : userID,
                                           "question" : question,
                                           "answers" : answers,
                                           "lat" : latitude,
                                           "lng" : longitude,
                                           "category" : category]
        
        Utility.performDataTask(urlDomain: QuestionData.questionDomain, httpMethod: "POST", args: [:], parameters: parameters) { data in
            doOnSuccess(data)
        }
    }
    
    class func voteOnQuestion(userID: String, questionId: Int, answerID: Int, doOnSuccess: @escaping (Data?)->Void) {
        let parameters : [String : Any] = ["user_id" : userID,
                                           "answer_id" : answerID]
        let urlDomain = "\(QuestionData.questionDomain)\(questionId)/vote"
        Utility.performDataTask(urlDomain: urlDomain, httpMethod: "PATCH", args: [:], parameters: parameters) { data in
            doOnSuccess(data)
        }
    } 

}

