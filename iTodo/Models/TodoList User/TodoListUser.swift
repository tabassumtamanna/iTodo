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

// MARK: - TodoListUser
class TodoListUser {
    
    struct TodoAuth {
        static var ref: DatabaseReference!
        static var _authHandle: AuthStateDidChangeListenerHandle!
        static var _refHandle: DatabaseHandle!
        
        static var user: User?
    }
    
    enum TodoList {
        static let TodoListTable = "TodoList"
        static let usersTable = "Users"
        
    }

    
    // MARK: - login
    class func login(completion: @escaping (Bool) -> Void) {
        
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
    
    
    
    // MARK: - Get Task List
    class func getTaskList(completion: @escaping (DataSnapshot) -> Void) {
        TodoAuth.ref = Database.database().reference()
        
        let userId = TodoAuth.user?.uid
        
        TodoAuth._refHandle = TodoAuth.ref.child(TodoList.TodoListTable).queryOrdered(byChild: "userId").queryStarting(atValue: userId).queryEnding(atValue: userId).observe(.childAdded) { ( snapshot: DataSnapshot) in
            
            completion(snapshot)
        }
    }
    
    // MARK: - Add Task
    class func addTask(taskTitle: String, taskCreated: String, completion: @escaping (String, Bool, Error?) -> Void) {
        
        let userId = TodoAuth.user?.uid
        
        let task = ["taskTitle": taskTitle,
                    "status": "0",
                    "taskCreated": taskCreated,
                    "taskCompleted": "",
                    "userId": userId]
        
        TodoAuth.ref.child(TodoList.TodoListTable).childByAutoId().setValue(task) { (error:Error?, ref:DatabaseReference) in
            if let error = error {
                completion("added", false, error)
            } else {
                completion("added", true, nil)
            }
        }
    }
    
    // MARK: - Update Task
    class func updateTask(status: Bool, taskCompleted: String, key: String, completion: @escaping (String, Bool, Error?) -> Void){
        
        let task = ["status": status ? "1" : "0",
                    "taskCompleted": taskCompleted]
        
        TodoAuth.ref.child(TodoList.TodoListTable).child(key).updateChildValues(task){ (error:Error?, ref:DatabaseReference) in
            
            if let error = error {
                completion("updated", false, error)
            }
            else {
                completion("updated", true, nil)
            }
        }
    }
    
    // MARK: - Delete Task
    class func deleteTask(key: String, completion: @escaping (String, Bool, Error?) -> Void){
        
        TodoAuth.ref.child(TodoList.TodoListTable).child(key).removeValue() { error, arr  in
            if error != nil {
                completion("deleted", true, nil)
            } else {
                completion("deleted", false, error)
            }
        }
    }
    
    
    // MARK: - Deinit
    deinit {
        
        Auth.auth().removeStateDidChangeListener(TodoAuth._authHandle)
        TodoAuth.ref.child("Tasks").removeObserver(withHandle: TodoAuth._refHandle)
    }
    
    
    
    
}
