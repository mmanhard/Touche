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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButtonFB.permissions = ["public_profile", "email"];
        loginButtonFB.delegate = self
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
