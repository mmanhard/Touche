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
        
        
        Utility.performDataTask(urlDomain: QuestionData.questionDomain, httpMethod: "GET", args: args, parameters: [:], auth: User.getUserAuthorization()) { data in
            doOnSuccess(data)
        }
    }
        
    class func createNewQuestion(question: String, answers: String, latitude: Double, longitude: Double, category: String, doOnSuccess: @escaping (Data?)->Void) {
        if let user = User.getCurrentUser() {
            let parameters : [String : Any] = ["user" : user.userID!,
                                               "question" : question,
                                               "answers" : answers,
                                               "lat" : latitude,
                                               "lng" : longitude,
                                               "category" : category]
            
            Utility.performDataTask(urlDomain: QuestionData.questionDomain, httpMethod: "POST", args: [:], parameters: parameters, auth: User.getUserAuthorization()) { data in
                doOnSuccess(data)
            }
        } else {
            print("NO USER - MUST HANDLE CASE")
        }
    }
    
    class func voteOnQuestion(questionId: Int, answerID: Int, doOnSuccess: @escaping (Data?)->Void) {
        if let user = User.getCurrentUser() {
            let parameters : [String : Any] = ["user_id" : user.userID!,
                                               "answer_id" : answerID]
            
            let urlDomain = "\(QuestionData.questionDomain)\(questionId)/vote"
            Utility.performDataTask(urlDomain: urlDomain, httpMethod: "PATCH", args: [:], parameters: parameters, auth: User.getUserAuthorization()) { data in
                doOnSuccess(data)
            }
        } else {
            print("NO USER - MUST HANDLE CASE")
        }

    } 

}

