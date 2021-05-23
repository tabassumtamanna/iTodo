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
        static var cconnectedRef: DatabaseReference!
        
        static var user: User?
    }
    
    enum TodoList {
        static let TodoListTable = "TodoList"
        static let usersTable = "Users"
        
    }
    
    enum Endpoints{
        
        case getRandomJokes
        
        var stringValue: String{
            switch self{
                
            case .getRandomJokes:
                return "https://official-joke-api.appspot.com/random_joke"
            }
           
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // MARK: - Task For GET Request
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
       
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let err = error{
                print(err.localizedDescription)
                completion(nil, err)
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    // MARK: - API
    // MARK: - Get Random Jokes
    class func getRandomJokes(completion: @escaping (String?, String?, Error?) -> Void){
        
        taskForGETRequest(url: Endpoints.getRandomJokes.url, responseType: OfficialJokesApiResponse.self) { (response, error) in
            
            if let response = response {
                completion(response.setup, response.punchline, nil)
            } else {
                completion(nil, nil,  error)
            }
        }
    }
    
    
    // MARK: -   Firebase
    
    // MARK: - login
    class func login(completion: @escaping (Bool) -> Void) {
        
        // listen for changes in the authorization state
        TodoAuth._authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
           
            print(auth)
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
        TodoAuth.cconnectedRef.removeAllObservers()
    }
    
    
    
    
}
