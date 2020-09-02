//
//  User.swift
//  Touche
//
//
//  Model for the User resource.
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
    
    static var userURL = Constants.host + Constants.userPath
    
    // MARK: Initializer
    
    init(username: String, password: String, cellNumber: String?, signUp: Bool, doOnSuccess: @escaping (Data?)->Void, doOnFailure: @escaping (Data?, URLResponse?, Error?)->Void) {
        
        self.cellNumber = cellNumber
        self.username = username
        self.password = password
        
        var auth : [String : String] = [:]
        
        // Setup variables for HTTP request based on whether this instance of user is being created from sign up or by logging in.
        var params : [String : String] = [:]
        var urlDomain = User.userURL
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
        
        // Perform the HTTP request.
        Utility.performDataTask(urlDomain: urlDomain, httpMethod: httpMethod, args: [:], parameters: params, auth: auth, doOnSuccess: { data in
            self.userID = Int.init(String.init(data: data!, encoding: String.Encoding.utf8) ?? "")
            
            if (self.userID != nil) {
                UserDefaults.standard.set(try? PropertyListEncoder().encode(self), forKey: "CurrentUser")
                
                doOnSuccess(data)
            }
        }, doOnFailure: doOnFailure)
    }
    
    // MARK: Static methods
    
    // Given a username, password, cell phone number, and callbacks for success and failure, send an HTTP request to sign up a user.
    class func signUp(username: String, password: String, cellNumber: String, doOnSuccess: @escaping (Data?)->Void, doOnFailure: @escaping (Data?, URLResponse?, Error?)->Void) {
        let _ = User(username: username, password: password, cellNumber: cellNumber, signUp: true, doOnSuccess: doOnSuccess, doOnFailure: doOnFailure)
    }
    
    // Given a username, password, and callbacks for success and failure, send an HTTP request to login the user.
    class func logIn(username: String, password: String, doOnSuccess: @escaping (Data?)->Void, doOnFailure: @escaping (Data?, URLResponse?, Error?)->Void) {
        let _ = User(username: username, password: password, cellNumber: nil, signUp: false, doOnSuccess: doOnSuccess, doOnFailure: doOnFailure)
    }
    
    // Log out the user by removing the current user from storage.
    class func logOut() {
        UserDefaults.standard.removeObject(forKey: "CurrentUser")
    }
    
    // Gets the current user stored in user defaults if it exists. Otherwise, return nil.
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
    
    // Gets the credentials for authorization if there is a current user.
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
    
    // Get all questions asked by the user. If successfull, performs the given callback.
    func getQuestionsAsked(doOnSuccess: @escaping (Data?)->Void)->Void {
        let urlDomain = User.userURL + "\(String(describing: self.userID!))/asked"
        
        let auth = ["username": self.username,
                    "password": self.password]
        
        Utility.performDataTask(urlDomain: urlDomain, httpMethod: "GET", args: [:], parameters: [:], auth: auth) { data in
            doOnSuccess(data)
        }
    }
    
    // Get all questions answered by the user. If successfull, performs the given callback.
    func getQuestionsAnswered(doOnSuccess: @escaping (Data?)->Void)->Void {
        let urlDomain = User.userURL + "\(String(describing: self.userID!))/answered"
        
        let auth = ["username": self.username,
                    "password": self.password]
        
        Utility.performDataTask(urlDomain: urlDomain, httpMethod: "GET", args: [:], parameters: [:], auth: auth) { data in
            doOnSuccess(data)
        }
    }
}
