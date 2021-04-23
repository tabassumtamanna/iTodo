//
//  LoginViewController.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 4/18/21.
//

import UIKit
import Firebase
import FirebaseUI
import GoogleSignIn

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
        configureAuth()
    }
    

    // MARK: -  Show Login View
    @IBAction func showLoginView(_ sender: Any) {
        loginSession()
    }
    
    
    // MARK: - Configure Auth
    func configureAuth() {
        
        let provider: [FUIAuthProvider] = [FUIGoogleAuth(), FUIEmailAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        
        // listen for changes in the authorization state
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            
            // check if there is a current user
            if let activeUser = user {
                
                // check if the current app user is the current FIRUser
                if self.user != activeUser {
                    self.user = activeUser
                    self.signedInStatus(isSignedIn: true)
                    //let name = user!.email!.components(separatedBy: "@")[0]
                    
                }
            } else {
                // user must sign in
                self.signedInStatus(isSignedIn: false)
                self.loginSession()
            }
        }
    }
    
    // MARK: - Deinit
    deinit {
        
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
    // MARK: - Signed In Status
    
    func signedInStatus(isSignedIn: Bool) {
        
        print("signedInStatus: \(isSignedIn)")
        self.signInButton.isHidden = isSignedIn
        
        if (isSignedIn) {
            
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
            self.navigationController?.pushViewController(nextViewController, animated: true)
            
        }
    }
    
    // MARK: - Login Session
    func loginSession() {
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
}
