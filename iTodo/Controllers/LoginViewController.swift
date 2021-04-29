//
//  LoginViewController.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 4/18/21.
//

import UIKit
import Firebase
import FirebaseUI


// MARK: - LoginViewController
class LoginViewController: UIViewController {

    // MARK:-  Properties
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
   
    
    // MARK: - Outlets
    @IBOutlet weak var signInButton: UIButton!
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureAuth()
    }
    

    // MARK: -  Show Login View
    @IBAction func showLoginView(_ sender: Any) {
        loginSession()
    }
    
    
    // MARK: - Configure Auth
    func configureAuth() {
        TodoListUser.login(completion:signedInStatus(isSignedIn:))
    }
    
    
    // MARK: - Signed In Status
    func signedInStatus(isSignedIn: Bool) {
        
        self.signInButton.isHidden = isSignedIn
        
        if (isSignedIn) {
            
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
            self.navigationController?.pushViewController(nextViewController, animated: true)
            
        } else {
            self.loginSession()
        }
    }
    
    // MARK: - Login Session
    func loginSession() {
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
    
}
