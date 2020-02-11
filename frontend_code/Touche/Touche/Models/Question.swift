//
//  Question.swift
//  Touche
//
//  Created by Michael Manhard on 2/10/20.
//  Copyright © 2020 Michael Manhard. All rights reserved.
//

import Foundation

class Question {
    private var quid: Int?
    private var qText: String?
    private var time: Float?
    private var answers: [String]?
    private var numVotes: [Int]?
    private var category: String?
    private var lat: Float?
    private var long: Float?
    
    let questionDomain = "http://127.0.0.1:5000/question"
    
    init() {
    }

    class func getAllQuestions(latitude: Double, longitude: Double, sortBy: String) {
        //let args = ["lat": String(format: "%.8f", latitude),
//                    "lng": String(format: "%.8f", longitude)]
        let request = formatHTTPRequest(urlDomain: "http://127.0.0.1:5000/questions", httpMethod: "GET", args: [:], parameters: [:])
        print(request)
        questionDataTask(with: request)
    }
    
    func createNewQuestion()->Void {
        
    }
    
    func getQuestionInfo()->Void {
        
    }
    
    func voteOnQuestion()->Void {
        
    }

    class func formatHTTPRequest(urlDomain: String, httpMethod: String, args: [String: String], parameters: [String: Any]) -> URLRequest {
        var urlString = urlDomain
        var count = 0
        for arg in args {
            if (count != 0) {
                urlString += "&" + arg.key + "=" + arg.value
            } else {
                urlString += "?" + arg.key + "=" + arg.value
            }
            count = count + 1
        }
            
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        request.httpBody = parameters.percentEncoded()
        
        return request
    }
    
    class func questionDataTask(with request: URLRequest) {
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
