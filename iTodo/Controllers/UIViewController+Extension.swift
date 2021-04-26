//
//  UIViewController+Extension.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 4/18/21.
//

import UIKit
import Firebase

extension  UIViewController {

    
    // MARK: - signOutTapped
    @IBAction func signOutTapped(_ sender: Any) {
        
        do {
            
            try Auth.auth().signOut()
            
            let parentNav = self.navigationController?.navigationController
            if let vcB = parentNav?.viewControllers.first(where: { $0 is LoginViewController }) {
                parentNav?.popToViewController(vcB, animated: false)
            }
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            showFailureMessage(title: "SignOut Failure!", message: signOutError as! String)
        }
        
    }
    
    // MARK: - Get Formatted Date
    func getFormattedDate(date: Date, format: String) -> String {
            let dateformat = DateFormatter()
            dateformat.dateFormat = format
            return dateformat.string(from: date)
    }
    
    
    // MARK: -  Show Failure Message
    func showFailureMessage(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }

}
