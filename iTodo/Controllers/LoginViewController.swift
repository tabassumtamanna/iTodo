//
//  LoginViewController.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 4/18/21.
//

import UIKit
import Firebase
import GoogleSignIn


// MARK: - LoginViewController
class LoginViewController: UIViewController, GIDSignInDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        configureAuth()
    }
    
    // MARK: - Sign In Button Tapped
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        self.signInButton.isEnabled = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    // MARK: - Configure Auth
    func configureAuth() {
        TodoListUser.login(completion:signedInStatus(isSignedIn:))
    }
    
    // MARK: - Signed In Status
    func signedInStatus(isSignedIn: Bool) {
        
        if (isSignedIn) {
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
            self.navigationController?.pushViewController(nextViewController, animated: true)
            
        }
    }
    
    // MARK: - SignIn Did Sign In for User
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("ERROR: \(error.localizedDescription)")
            
            self.activityIndicator.stopAnimating()
            self.signInButton.isEnabled = true
            
            showFailureMessage(title: "Sign In Error", message: error.localizedDescription)
            return
        }
        
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        // Authenticate with Firebase using the credential object
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Error occurs when authenticate with Firebase: \(error.localizedDescription)")
                
                self.showFailureMessage(title: "Sign In Error", message: error.localizedDescription)
            }
            
            TodoListUser.TodoAuth.user = authResult?.user
            
            self.activityIndicator.stopAnimating()
            self.signInButton.isEnabled = true
            
        }
    }
    
    // MARK: - SignIn Did Disconnect With User
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            self.showFailureMessage(title: "Sign In Error", message: error.localizedDescription)
        }
    }
    
    
   
    
    
}
