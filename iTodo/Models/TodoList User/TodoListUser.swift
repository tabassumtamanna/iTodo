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
    
    enum Endpoints{
        
        static let base = "https://tasks.googleapis.com/tasks/v1/users"
        
        
        case getTaskListFromApi
        case insertTasklists(String)
        case uploadMyTask
        
        var stringValue: String{
            switch self{
            
            case .getTaskListFromApi:
                return Endpoints.base + "/\(TodoAuth.user?.uid)/lists?key=AIzaSyAJPus5nQYDg0eM06WSI1vRoAm7S08tHVA"
            
            case .insertTasklists(let userId):
                return Endpoints.base + "/\(userId)/lists?key=AIzaSyAJPus5nQYDg0eM06WSI1vRoAm7S08tHVA"
                
            case .uploadMyTask:
                return Endpoints.base + ""
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // MARK: - Task For Post Request
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType,  completion: @escaping (ResponseType?, Error?) -> Void){
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        
        let encoder = JSONEncoder()
        if let json = try? encoder.encode(body) {
            print(String(data: json, encoding: .utf8)!)
        }
        
        let task = URLSession.shared.dataTask(with: request)  {(data, response, error) in
           
            guard let data = data else {
               
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            var newData = data
            let docoder = JSONDecoder()
           
            do {
                let requestObject = try docoder.decode(ResponseType.self, from: newData)
               
                DispatchQueue.main.async {
                    completion(requestObject, nil)
                }
                
            } catch {
                
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        
    }
    
    // MARK: -  Google API
    
    class func getTaskListFromApi(){
        
        
    }
    
    class func insertTasklists(completion: @escaping (String?, Error?) -> Void){
        
        print("insertTasklists")
        
        let userId = TodoAuth.user?.uid ?? ""

        let body = TaskListResponse(kind: "", id: "", etag: "", title: "aaaa", updated: "", selfLink: "")
        print("URL: \(Endpoints.insertTasklists(userId).url)")
        taskForPOSTRequest(url: Endpoints.insertTasklists(userId).url, responseType: TaskListResponse.self, body: body) {( response, error) in
            
            if let response = response {
                print("response: \(response)")
                completion(response.id, nil)
            } else {
                print("error: \(error)")
                completion(nil, error)
            }
        }
        
    }
    
    
    
    
    
    // MARK: -   Firebase
    
    // MARK: - login
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
    
    
    // MARK: - Get Task list Id To User Table
    class func getTasklistId( completion: @escaping (String?, Error?) -> Void){
        
        TodoAuth.ref = Database.database().reference()
        
        let userId = TodoAuth.user?.uid
        
        TodoAuth.ref.child(TodoList.usersTable).child(userId!).observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
            //let value = snapshot.value as! [String: String]
            print("snapshot: \(snapshot)")
            
            completion("", nil)
          // ...
          }) { (error) in
            print(error.localizedDescription)
            completion(nil, error)
        }
        
        
    }
    
    // MARK: - Add Task list Id To User Table
    class func addTasklistId(tasklistId: String, completion: @escaping (Bool, Error?) -> Void) {
        
        let userId = TodoAuth.user?.uid
        
        let todolistUser = ["tasklistId": tasklistId,
                            "userId": userId
                            ]
        
        TodoAuth.ref.child(TodoList.usersTable).childByAutoId().setValue(todolistUser) { (error:Error?, ref:DatabaseReference) in
            if let error = error {
                completion(false, error)
            } else {
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
