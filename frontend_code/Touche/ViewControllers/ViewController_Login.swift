//
//  ViewController_Login.swift
//  Touche
//
//  Created by Michael Manhard on 2/10/20.
//  Copyright © 2020 Michael Manhard. All rights reserved.
//

import UIKit

class ViewController_Login: UIViewController {
    

   // @IBOutlet weak var loginButtonFB: FBLoginButton!
    @IBOutlet weak var usernameFieldText: UITextField!
    @IBOutlet weak var passwordFieldText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.layer.cornerRadius = 10
        self.passwordFieldText.isSecureTextEntry = true
    }
    
    // On login failure, displays an alert given the response from the backend.
    private func logInFailed(data: Data?, response: URLResponse?, error: Error?) {
        DispatchQueue.main.async {
            let message = String(decoding: data!, as: UTF8.self)
            let alert = UIAlertController(title: "Please try again.", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Handler for selecting login. Creates a new User instance from the user details returned from the backend. On success, goes to the main screen. On failure, displays an alert.
    @IBAction func didTapLogIn(sender: AnyObject) {
        User.logIn(username: self.usernameFieldText.text!, password: self.passwordFieldText.text!, doOnSuccess: { data in
            
            if let user = User.getCurrentUser() {
                print("SUCCESS - USER SIGNED IN w/ USERNAME: \(user.username)")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                print("COULD NOT RETRIEVE USER")
            }
        }, doOnFailure: logInFailed(data:response:error:))
    }
}
