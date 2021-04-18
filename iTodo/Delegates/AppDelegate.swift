//
//  AppDelegate.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 3/10/21.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    
    //let dataController = DataController(modelName: "iTodo")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
      }
}

