//
//  User.swift
//  Touche
//
//  Created by Michael Manhard on 2/10/20.
//  Copyright © 2020 Michael Manhard. All rights reserved.
//

import Foundation

class User {
    let userDomain = "http://127.0.0.1:5000/users/"
    
    
    /* NOT IMPLEMENTED */
//    func getAllUsers()->Void {
//
//    }
    
    func createNewUser()->Void {
        
    }
    
    func getQuestionsAskedByUser()->Void {
        
    }
    
    func getQuestionsAnsweredByUser()->Void {
        
    }
    
    private func getUser()->Void {
        
    }
    
    private func userDataTask(with URLString: String, doOnCompletion: @escaping () -> Void) -> Data? {
        let url = URL(string: URLString)
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url!, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if(error != nil) {
                print(error!.localizedDescription)
                
            } else {
                doOnCompletion()
            }
        })
        dataTask.resume()
        
        return nil
    }
}
