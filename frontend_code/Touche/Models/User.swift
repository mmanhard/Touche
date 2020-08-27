//
//  User.swift
//  Touche
//
//  Created by Michael Manhard on 2/10/20.
//  Copyright © 2020 Michael Manhard. All rights reserved.
//

import Foundation

class User : Codable {
    var username: String
    var password: String
    private var cellNumber: String?
    var userID: Int?
    
    private var userDomain = "http://127.0.0.1:5000/users/"
    static var userDomain = "http://127.0.0.1:5000/users/"
    
    init(username: String, password: String, cellNumber: String?, signUp: Bool, doOnSuccess: @escaping (Data?)->Void, doOnFailure: @escaping (Data?, URLResponse?, Error?)->Void) {
        self.cellNumber = cellNumber
        self.username = username
        self.password = password
        
        var auth : [String : String] = [:]
        var params : [String : String] = [:]
        var urlDomain = self.userDomain
        var httpMethod = "POST"
        if signUp {
            params = ["number": cellNumber!,
                      "username": username,
                      "password": password]
        } else {
            urlDomain += "login"
            auth = ["username": username,
                    "password": password]
            httpMethod = "GET"
        }
        
        Utility.performDataTask(urlDomain: urlDomain, httpMethod: httpMethod, args: [:], parameters: params, auth: auth, doOnSuccess: { data in
            self.userID = Int.init(String.init(data: data!, encoding: String.Encoding.utf8) ?? "")
            
            if (self.userID != nil) {
                UserDefaults.standard.set(try? PropertyListEncoder().encode(self), forKey: "CurrentUser")
                
                doOnSuccess(data)
            }
        }, doOnFailure: doOnFailure)
    }
    
    // MARK: Static methods
    
    class func signUp(username: String, password: String, cellNumber: String, doOnSuccess: @escaping (Data?)->Void, doOnFailure: @escaping (Data?, URLResponse?, Error?)->Void) {
        let _ = User(username: username, password: password, cellNumber: cellNumber, signUp: true, doOnSuccess: doOnSuccess, doOnFailure: doOnFailure)
    }
    
    class func logIn(username: String, password: String, doOnSuccess: @escaping (Data?)->Void, doOnFailure: @escaping (Data?, URLResponse?, Error?)->Void) {
        let _ = User(username: username, password: password, cellNumber: nil, signUp: false, doOnSuccess: doOnSuccess, doOnFailure: doOnFailure)
    }
    
    class func logOut() {
        UserDefaults.standard.removeObject(forKey: "CurrentUser")
    }
    
    class func getCurrentUser() -> User? {
        do {
            if let data = UserDefaults.standard.value(forKey: "CurrentUser") as? Data {
                let user = try PropertyListDecoder().decode(User.self, from: data)
                return user
            }
        } catch {
            print("Could not decode user")
        }
        return nil
    }
    
    class func getUserAuthorization() -> [String : String] {
        if let user = getCurrentUser() {
            let auth = ["username": user.username,
                        "password": user.password]
            return auth
        } else {
            return [:]
        }
    }
    
    // MARK: Instance methods
    
    func getQuestionsAsked(doOnSuccess: @escaping (Data?)->Void)->Void {
        let urlDomain = self.userDomain + "\(String(describing: self.userID!))/asked"
        
        let auth = ["username": self.username,
                    "password": self.password]
        
        Utility.performDataTask(urlDomain: urlDomain, httpMethod: "GET", args: [:], parameters: [:], auth: auth) { data in
            doOnSuccess(data)
        }
    }
    
    func getQuestionsAnswered(doOnSuccess: @escaping (Data?)->Void)->Void {
        let urlDomain = self.userDomain + "\(String(describing: self.userID!))/answered"
        
        let auth = ["username": self.username,
                    "password": self.password]
        
        Utility.performDataTask(urlDomain: urlDomain, httpMethod: "GET", args: [:], parameters: [:], auth: auth) { data in
            doOnSuccess(data)
        }
    }
}
