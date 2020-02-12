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
    @IBOutlet weak var cellFieldText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButtonFB.permissions = ["public_profile", "email"];
        loginButtonFB.delegate = self
    }
    
    @IBAction func didTapSignUp(sender: AnyObject) {
        User.signUp(cellNumber: self.cellFieldText.text!) { data in
            print("SUCCESS - NEW USER w/ ID: \(UserDefaults.standard.string(forKey: "userID")!)")
            
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
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
