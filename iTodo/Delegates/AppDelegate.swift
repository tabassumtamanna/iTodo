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
    
    //let dataController = DataController(modelName: "iTodo")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        return true
      }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication ?? "") ?? false
    }
}

