//
//  TodoListUser.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 4/26/21.
//

import Foundation
import Firebase
import FirebaseUI
import GoogleSignIn

class TodoListUser {
    
    struct TodoAuth {
        static var ref: DatabaseReference!
        static var _authHandle: AuthStateDidChangeListenerHandle!
        static var _refHandle: DatabaseHandle!
        
        static var user: User?
    }
    
    enum TodoList {
        static let tableName = "TodoList"
        
    }
    
    class func login(completion: @escaping (Bool) -> Void) {
        let provider: [FUIAuthProvider] = [FUIGoogleAuth(), FUIEmailAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        
        // listen for changes in the authorization state
        TodoAuth._authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            
            // check if there is a current user
            if let activeUser = user {
                
                TodoAuth.user = activeUser
                completion(true)
                
            } else {
                completion(false)
            }
        }
        
    }
    
    class func getTaskList(completion: @escaping (DataSnapshot) -> Void) {
        TodoAuth.ref = Database.database().reference()
        
        let userId = TodoAuth.user?.uid
        
        
        TodoAuth._refHandle = TodoAuth.ref.child(TodoList.tableName).queryOrdered(byChild: "userId").queryStarting(atValue: userId).queryEnding(atValue: userId).observe(.childAdded) { ( snapshot: DataSnapshot) in
            
            
            completion(snapshot)
        }
    }
    
    class func addTask(taskTitle: String, taskCreated: String, completion: @escaping (Bool, Error?) -> Void) {
        
        let userId = TodoAuth.user?.uid
        
        let task = ["taskTitle": taskTitle,
                    "status": "0",
                    "taskCreated": taskCreated,
                    "taskCompleted": "",
                    "userId": userId]
        
        TodoAuth.ref.child(TodoList.tableName).childByAutoId().setValue(task) { (error:Error?, ref:DatabaseReference) in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    class func updateTask(status: Bool, taskCompleted: String, key: String, completion: @escaping (Bool, Error?) -> Void){
        
        let task = ["status": status ? "1" : "0",
                    "taskCompleted": taskCompleted]
        
        TodoAuth.ref.child(TodoList.tableName).child(key).updateChildValues(task){ (error:Error?, ref:DatabaseReference) in
            
            if let error = error {
                completion(false, error)
            }
            else {
                completion(true, nil)
            }
        }
    }
    
    // MARK: - Deinit
    deinit {
        
        Auth.auth().removeStateDidChangeListener(TodoAuth._authHandle)
        TodoAuth.ref.child("Tasks").removeObserver(withHandle: TodoAuth._refHandle)
    }
    
    
}
