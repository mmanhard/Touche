//
//  ViewController_Login.swift
//  Touche
//
//  Created by Michael Manhard on 2/10/20.
//  Copyright © 2020 Michael Manhard. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class ViewController_Login: UIViewController {
    

    @IBOutlet weak var loginButtonFB: FBLoginButton!
    @IBOutlet weak var usernameFieldText: UITextField!
    @IBOutlet weak var passwordFieldText: UITextField!
    @IBOutlet weak var cellFieldText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButtonFB.permissions = ["public_profile", "email"];
        loginButtonFB.delegate = self
    }
    
    private func logInOrSignUpFailed(data: Data?, response: URLResponse?, error: Error?) {
        DispatchQueue.main.async {
            let message = String(decoding: data!, as: UTF8.self)
            let alert = UIAlertController(title: "Please try again.", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapSignUp(sender: AnyObject) {
        User.signUp(username: self.usernameFieldText.text!, password: self.passwordFieldText.text!, cellNumber: self.cellFieldText.text!, doOnSuccess: { data in
                if let user = User.getCurrentUser() {
                    print("SUCCESS - NEW USER w/ USERNAME: \(user.username)")
                } else {
                    print("COULD NOT RETRIEVE USER")
                }
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
        }, doOnFailure: logInOrSignUpFailed(data:response:error:))
    }
    
    @IBAction func didTapLogIn(sender: AnyObject) {
        User.logIn(username: self.usernameFieldText.text!, password: self.passwordFieldText.text!, cellNumber: self.cellFieldText.text!, doOnSuccess: { data in
            
            if let user = User.getCurrentUser() {
                print("SUCCESS - USER SIGNED IN w/ USERNAME: \(user.username)")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                print("COULD NOT RETRIEVE USER")
            }
        }, doOnFailure: logInOrSignUpFailed(data:response:error:))
    }
}

extension ViewController_Login: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let e = error {
            print(e.localizedDescription)
        } else {
            if (result!.isCancelled) {
                print("DID NOT LOG IN!")
            } else {
                navigationController?.popViewController(animated: true)

                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("LOGGED OUT")
    }
}
