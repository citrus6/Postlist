//
//  Function.swift
//  Practice
//
//  Created by Виктор on 31.07.2018.
//  Copyright © 2018 Victor Yanuchkov. All rights reserved.
//

import Foundation
import Dispatch

func afterDelay(_ seconds: Double, clousure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds , execute: clousure)
}

let MyFailInternetSessionNotification = Notification.Name(rawValue: "MyFailInternetSessionNotification")

func fatalInternetError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(name: MyFailInternetSessionNotification, object: nil)
}
