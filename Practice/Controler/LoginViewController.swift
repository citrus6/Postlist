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
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //GIDSignIn.sharedInstance().signInSilently()
        
        var error: NSError?
        if error != nil {
            print(error)
            return
        }
        
        GIDSignIn.sharedInstance().uiDelegate = self

        signInButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        signInButton.center = view.center
    }
    
   
    func showTableView(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "listViewController") as! TableViewController
        self.present(viewController, animated: true, completion: nil)
    }
}
