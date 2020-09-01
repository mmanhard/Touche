//
//  QuestionData.swift
//  Touche
//
//  Model for Collections of Questions and handling manipulation of questions.
//
//  Created by Michael Manhard on 2/11/20.
//  Copyright © 2020 Michael Manhard. All rights reserved.
//

import Foundation

class QuestionData  {
    static var questionURL = Constants.host + Constants.questionPath
    
    var questionData: [Question]?
    
    // MARK: Initializer
    // Initialize given JSON data from the backend. Data should be an array of objects corresponding to Questions.
    init(data: Data) {
        let decoder = JSONDecoder()
        do {
            self.questionData = try decoder.decode([Question].self, from: data)
        } catch {
            print("JSON error: \(error.localizedDescription)")
            self.questionData = nil
        }
    }
    
    // MARK: Static methods
    
    // Given a latitude, longitude, sorting flag ('hot' or the default 'recent'), category, and callback for success, send an HTTP request to get all requests that correspond to these parameters.
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
        
        
        Utility.performDataTask(urlDomain: QuestionData.questionURL, httpMethod: "GET", args: args, parameters: [:], auth: User.getUserAuthorization()) { data in
            doOnSuccess(data)
        }
    }
        
    // Given a question string, string of answers, latitude, longitude, category, and callback for success, send an HTTP to create a new question.
    class func createNewQuestion(question: String, answers: String, latitude: Double, longitude: Double, category: String, doOnSuccess: @escaping (Data?)->Void) {
        if let user = User.getCurrentUser() {
            let parameters : [String : Any] = ["user" : user.userID!,
                                               "question" : question,
                                               "answers" : answers,
                                               "lat" : latitude,
                                               "lng" : longitude,
                                               "category" : category]
            
            Utility.performDataTask(urlDomain: QuestionData.questionURL, httpMethod: "POST", args: [:], parameters: parameters, auth: User.getUserAuthorization()) { data in
                doOnSuccess(data)
            }
        }
    }
    
    // Given a questionid, answerid, and callback for success, submits an HTTP request to vote on a question.
    class func voteOnQuestion(questionId: Int, answerID: Int, doOnSuccess: @escaping (Data?)->Void, doOnFailure: @escaping (Data?, URLResponse?, Error?)->Void) {
        if let user = User.getCurrentUser() {
            let parameters : [String : Any] = ["user_id" : user.userID!,
                                               "answer_id" : answerID]
            
            let urlDomain = "\(QuestionData.questionURL)\(questionId)/vote"
            Utility.performDataTask(urlDomain: urlDomain, httpMethod: "PATCH", args: [:], parameters: parameters, auth: User.getUserAuthorization(), doOnSuccess: doOnSuccess, doOnFailure: doOnFailure)
        }

    } 

}

