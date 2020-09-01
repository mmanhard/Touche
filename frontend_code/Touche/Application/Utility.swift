//
//  Utility.swift
//  Touche
//
//  Utility functions used throughout the application.
//
//  Created by Michael Manhard on 2/12/20.
//  Copyright © 2020 Michael Manhard. All rights reserved.
//

import Foundation
import UIKit

class Utility {

    // MARK: HTTP Utility Functions
    
    // Given a domain, HTTP method (e.g. GET), args, parameters, and basic authorization info (i.e. username and password), returns a formatted HTTP request with type URLRequest.
    class func formatHTTPRequest(urlDomain: String, httpMethod: String, args: [String: String], parameters: [String: Any], auth: [String: String]) -> URLRequest {
        
        // Create the full url.
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
        
        // Create the request, add headers, configure the method, and encode the parameters into the body.
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        request.httpBody = parameters.percentEncoded()
        
        // Encode the basic authentication.
        if (auth["username"] != nil) && (auth["password"] != nil) {
            let loginString = String(format: "%@:%@", auth["username"]!, auth["password"]!)
            let loginData = loginString.data(using: String.Encoding.utf8)!
            let base64LoginString = loginData.base64EncodedString()
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    // Given a domain, HTTP method (e.g. GET), args, parameters, basic authorization info (i.e. username and password), and callbacks for HTTP request success and failure, submits an HTTP request.
    class func performDataTask(urlDomain: String, httpMethod: String, args: [String: String], parameters: [String: Any], auth: [String: String], doOnSuccess: @escaping (Data?)->Void, doOnFailure: @escaping (Data?, URLResponse?, Error?)->Void) -> Void {
        
        // Format the request.
        let request = Utility.formatHTTPRequest(urlDomain: urlDomain, httpMethod: httpMethod, args: args, parameters: parameters, auth: auth)
        
        // Complete the request.
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data,
            let response = response as? HTTPURLResponse,
            error == nil else { // Check for fundamental networking error
            doOnFailure(data, nil, error)
            return
            }

            guard (200 ... 299) ~= response.statusCode else { // Check for http errors (i.e. status code not between 200 and 299).
                doOnFailure(data, response, error)
                return
            }
            
            doOnSuccess(data)
        }
        
        task.resume()
    }

    // Identical method to original performDataTask but does not include a callback for HTTP request failure.
    class func performDataTask(urlDomain: String, httpMethod: String, args: [String: String], parameters: [String: Any], auth: [String: String], doOnSuccess: @escaping (Data?)->Void) {
        performDataTask(urlDomain: urlDomain, httpMethod: httpMethod, args: args, parameters: parameters, auth: auth, doOnSuccess: doOnSuccess) { _,_,_  in }
    }
    
    // MARK: Other Methods
    
    // Auxiliary function to resize an image given a target size.
    // Adapted from: https://gist.github.com/hcatlin/180e81cd961573e3c54d
    class func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle.
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // Create a rectangle from the calculated size.
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext.
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }}

// MARK: Dictionary Extension

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

// MARK: CharacterSet Extension

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
