//
//  Utility.swift
//  Touche
//
//  Created by Michael Manhard on 2/12/20.
//  Copyright © 2020 Michael Manhard. All rights reserved.
//

import Foundation

class Utility {

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
    
    class func performDataTask(urlDomain: String, httpMethod: String, args: [String: String], parameters: [String: Any], doOnSuccess: @escaping (Data?)->Void) -> Void {
        let request = Utility.formatHTTPRequest(urlDomain: urlDomain, httpMethod: httpMethod, args: args, parameters: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data,
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
            doOnSuccess(data)
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
