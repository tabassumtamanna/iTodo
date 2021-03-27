//
//  SceneDelegate.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 3/10/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    
    
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dataController.load()
        
        let navigationController = window?.rootViewController?.children[0] as! UINavigationController
        
        
        let todoListViewController = navigationController.topViewController as! TodoListViewController
        
        todoListViewController.dataController = appDelegate.dataController
        
       
        let navigationController1 = window?.rootViewController?.children[1] as! UINavigationController
        
        
        let todoArchiveViewController = navigationController1.topViewController as! TodoArchiveViewController
        
        todoArchiveViewController.dataController = appDelegate.dataController
        
    }
}

