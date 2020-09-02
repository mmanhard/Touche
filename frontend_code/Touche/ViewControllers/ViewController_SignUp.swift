//
//  ViewController_Login.swift
//  Touche
//
//  Created by Michael Manhard on 2/10/20.
//  Copyright © 2020 Michael Manhard. All rights reserved.
//

import UIKit

class ViewController_SignUp: UIViewController {
    
    @IBOutlet weak var usernameFieldText: UITextField!
    @IBOutlet weak var passwordFieldText: UITextField!
    @IBOutlet weak var cellFieldText: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.signUpButton.layer.cornerRadius = 10
        self.passwordFieldText.isSecureTextEntry = true
    }
    
    // On sign up failure, displays an alert given the response from the backend.
    private func signUpFailed(data: Data?, response: URLResponse?, error: Error?) {
        DispatchQueue.main.async {
            let message = String(decoding: data!, as: UTF8.self)
            let alert = UIAlertController(title: "Please try again.", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Handler for selecting sign up. Creates a new user. On success, goes to the main screen. On failure, displays an alert.
    @IBAction func didTapSignUp(sender: AnyObject) {
        User.signUp(username: self.usernameFieldText.text!, password: self.passwordFieldText.text!, cellNumber: self.cellFieldText.text!, doOnSuccess: { data in
                if let user = User.getCurrentUser() {
                    print("SUCCESS - NEW USER w/ USERNAME: \(user.username)")
                } else {
                    print("COULD NOT RETRIEVE USER")
                }
                
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
        }, doOnFailure: signUpFailed(data:response:error:))
    }
    
    // Handler for selecting log in. Goes back to the login view.
    @IBAction func didTapLogIn(sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}
