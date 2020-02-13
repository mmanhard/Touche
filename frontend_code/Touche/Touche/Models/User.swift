//
//  User.swift
//  Touche
//
//  Created by Michael Manhard on 2/10/20.
//  Copyright © 2020 Michael Manhard. All rights reserved.
//

import Foundation

class User {
    private var cellNumber: String
    private var userID: Int?
    
    static var userDomain = "http://127.0.0.1:5000/users/"
    
    init(cellNumber: String, doOnSuccess: @escaping (Data?)->Void) {
        self.cellNumber = cellNumber
        let params = ["number": cellNumber]
        
        Utility.performDataTask(urlDomain: User.userDomain, httpMethod: "POST", args: [:], parameters: params) { data in
            self.userID = Int.init(String.init(data: data!, encoding: String.Encoding.utf8) ?? "")
            UserDefaults.standard.set(NSString(), forKey: "userID")
            UserDefaults.standard.setValue(self.userID!, forKey:"userID")
            doOnSuccess(data)
        }
    }
    
    class func signUp(cellNumber: String, doOnSuccess: @escaping (Data?)->Void) {
        let _ = User(cellNumber: cellNumber, doOnSuccess: doOnSuccess)
    }
    
    class func getQuestionsAskedByUser(userID: String, doOnSuccess: @escaping (Data?)->Void)->Void {
        let urlDomain = userDomain + "\(UserDefaults.standard.string(forKey: "userID")!)/asked"
        
        Utility.performDataTask(urlDomain: urlDomain, httpMethod: "GET", args: [:], parameters: [:]) { data in
            doOnSuccess(data)
        }
    }
    
    class func getQuestionsAnsweredByUser(userID: String, doOnSuccess: @escaping (Data?)->Void)->Void {
        let urlDomain = userDomain + "\(UserDefaults.standard.string(forKey: "userID")!)/answered"
        
        Utility.performDataTask(urlDomain: urlDomain, httpMethod: "GET", args: [:], parameters: [:]) { data in
            doOnSuccess(data)
        }
    }
}
