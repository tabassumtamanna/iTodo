//
//  AppDelegate.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 3/10/21.
//

import UIKit
import Firebase
import FirebaseUI


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        return true
      }
    
}



