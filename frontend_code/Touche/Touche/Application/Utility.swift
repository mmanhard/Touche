//
//  Utility.swift
//  Touche
//
//  Created by Michael Manhard on 2/12/20.
//  Copyright © 2020 Michael Manhard. All rights reserved.
//

import Foundation
import UIKit

class Utility {

    class func formatHTTPRequest(urlDomain: String, httpMethod: String, args: [String: String], parameters: [String: Any], auth: [String: String]) -> URLRequest {
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
        
        if (auth["username"] != nil) && (auth["password"] != nil) {
            let loginString = String(format: "%@:%@", auth["username"]!, auth["password"]!)
            let loginData = loginString.data(using: String.Encoding.utf8)!
            let base64LoginString = loginData.base64EncodedString()
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    class func performDataTask(urlDomain: String, httpMethod: String, args: [String: String], parameters: [String: Any], auth: [String: String], doOnSuccess: @escaping (Data?)->Void, doOnFailure: @escaping (Data?, URLResponse?, Error?)->Void) -> Void {
        let request = Utility.formatHTTPRequest(urlDomain: urlDomain, httpMethod: httpMethod, args: args, parameters: parameters, auth: auth)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data,
            let response = response as? HTTPURLResponse,
            error == nil else { // check for fundamental networking error
            doOnFailure(data, nil, error)
            return
            }

            guard (200 ... 299) ~= response.statusCode else { // check for http errors
                doOnFailure(data, response, error)
                return
            }
            doOnSuccess(data)
        }
        task.resume()
    }
    
    class func performDataTask(urlDomain: String, httpMethod: String, args: [String: String], parameters: [String: Any], auth: [String: String], doOnSuccess: @escaping (Data?)->Void) {
        performDataTask(urlDomain: urlDomain, httpMethod: httpMethod, args: args, parameters: parameters, auth: auth, doOnSuccess: doOnSuccess) { _,_,_  in }
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
