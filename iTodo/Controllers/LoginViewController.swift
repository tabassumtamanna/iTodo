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
    

    // MARK: -  Actions
    
    @IBAction func showLoginView(_ sender: Any) {
        loginSession()
    }
    
    
    // MARK: Config
    
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
    
    deinit {
        
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
    // MARK: - Sign In and Out
    
    func signedInStatus(isSignedIn: Bool) {
        
        self.signInButton.isHidden = isSignedIn
        
        if (isSignedIn) {
            
            let todoListTabBarVC = self.storyboard?.instantiateViewController(withIdentifier:  "TodoListTabBarViewController")
            
            todoListTabBarVC?.modalPresentationStyle = .fullScreen
            self.present(todoListTabBarVC!, animated:true, completion:nil)

        }
    }
    
    
    
    func loginSession() {
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
}
