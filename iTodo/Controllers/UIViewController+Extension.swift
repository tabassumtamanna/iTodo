//
//  UIViewController+Extension.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 4/18/21.
//

import UIKit
import Firebase

// MARK: - Extension : UIViewController
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
    
    // MARK: - Get Profile Picture
    func getProfilePic(){
        
        if let photoUrl = TodoListUser.TodoAuth.user?.photoURL {
            
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.layer.cornerRadius = 15
            button.clipsToBounds = true
            button.imageView?.contentMode = .scaleAspectFit

            let imageData = try? Data(contentsOf: photoUrl)
            
            if let imageData = imageData , let image =  UIImage(data: imageData)?.resizeImage(to: button.frame.size) {
                button.setBackgroundImage(image, for: .normal)
            }
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
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

// MARK: - Extension: UIImage
extension UIImage {
    func resizeImage(to size: CGSize) -> UIImage {
       return UIGraphicsImageRenderer(size: size).image { _ in
           draw(in: CGRect(origin: .zero, size: size))
    }
}}
