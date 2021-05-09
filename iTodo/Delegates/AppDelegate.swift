//
//  AppDelegate.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 3/10/21.
//

import UIKit
import Firebase
import FirebaseUI
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        //1001252183616-m62jc2f83icc4q6qm9kino54c133tarv.apps.googleusercontent.com
       
        
        return true
      }
    
    
    // MARK: Handle OAuth Callback
     func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("------------ Host --------")
        print(url.host)
         if url.host == "oauth-callback" {
            print("callback hit")
            OAuthSwift.handle(url: url)
         }
        return true
     }
   
}



