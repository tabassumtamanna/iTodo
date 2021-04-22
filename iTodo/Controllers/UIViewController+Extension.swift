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
            
            print("signOutTapped: List \(self.view.window?.rootViewController)")
            
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            
        } catch {
            print("unable to sign out: \(error)")
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
