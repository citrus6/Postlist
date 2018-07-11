//
//  LoginViewController.swift
//  Practice
//
//  Created by Victor Yanuchkov on 10/07/2018.
//  Copyright © 2018 Victor Yanuchkov. All rights reserved.
//

import UIKit
import GoogleSignIn
class LoginViewController: UIViewController, GIDSignInUIDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
        //GIDSignIn.sharedInstance().signInSilently()
        
        var error: NSError?
        if error != nil {
            print(error)
            return
        }
        
    
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        let signInButton = GIDSignInButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        signInButton.center = view.center
        view.addSubview(signInButton)
    }
    
    
}
