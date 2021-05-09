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
class LoginViewController: UIViewController, FUIAuthDelegate {

    // MARK:-  Properties
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
   
    
    // MARK: - Outlets
    @IBOutlet weak var signInButton: UIButton!
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        //TodoListUser.checkConnection(completion: handleConnection(status:))
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
        guard let authUI = FUIAuth.defaultAuthUI() else { return }

        authUI.delegate = self
        
        //let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        let authViewController = authUI.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
    
    
    func handleConnection(status: Bool){
        
        if(status == false){
            
            showFailureMessage(title: "Login Failed", message: "Please check your connection")
        }
    }
    
    
}

extension LoginViewController {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
      if let error = error as NSError?,
          error.code == FUIAuthErrorCode.mergeConflict.rawValue {
        // Merge conflict error, discard the anonymous user and login as the existing
        // non-anonymous user.
        guard let credential = error.userInfo[FUIAuthCredentialKey] as? AuthCredential else {
          print("Received merge conflict error without auth credential!")
          return
        }

        
      } else if let error = error {
        // Some non-merge conflict error happened.
        print("Failed to log in: \(error)")
        return
      }

      // Handle successful login
    }
}
