//
//  AppDelegate.swift
//  Practice
//
//  Created by Victor Yanuchkov on 27/06/2018.
//  Copyright © 2018 Victor Yanuchkov. All rights reserved.
//

import UIKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    func listenForFatalInternetSessionNotification() {
        NotificationCenter.default.addObserver(forName: MyFailInternetSessionNotification, object: nil, queue: OperationQueue.main, using: { notification in
            let alert = UIAlertController(title: "Inernet error", message: "There was a fatal error in the app and it cannot continue. \n\nBe assured that the Internet connection is active", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal internet session", userInfo: nil)
                exception.raise()
            }
            alert.addAction(action)
            
            self.viewControllerForShowingAlert().present(alert, animated: true)
        })
    }
    
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        
        GIDSignIn.sharedInstance().clientID = "994780559085-fkneab0tuqapnboe37v3ntaol6gju440.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
      
        
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var initialViewController = UIViewController()
        
        User.getUser()?.isLoggedIn = true
        User.getUser()?.email = "yanchukov@outlook.com"
        
        if (User.getUser()?.isLoggedIn)!{
                initialViewController = storyboard.instantiateViewController(withIdentifier: "ItemList")
        } else {
                 initialViewController = storyboard.instantiateViewController(withIdentifier: "Login")
        }
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()

        listenForFatalInternetSessionNotification()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error{
            print("\(error.localizedDescription)")
        } else {
            
            let email = user.profile.email!
            User.getUser()?.email = email
            User.getUser()?.isLoggedIn = true
            saveUserData(user: User.getUser()!)
            if (User.getUser()?.isLoggedIn)! {
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemList")
                self.window?.rootViewController = viewController
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

