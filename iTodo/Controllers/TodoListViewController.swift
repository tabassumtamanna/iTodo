//
//  TodoListViewController.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 4/16/21.
//

import UIKit
import Firebase
import OAuthSwift

// MARK: - TodoListViewController
class TodoListViewController: UIViewController {

    
    // MARK: - Outlets
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var uploadMyTaskBarButton: UIBarButtonItem!
    @IBOutlet weak var jokesLabel: UILabel!
    
    
    // MARK: - Properties
    var taskList: [DataSnapshot]! = []
   
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        self.taskTableView.delegate = self
        self.taskTableView.dataSource = self
        self.taskTextField.delegate = self
        self.taskTextField.text = ""
        
        getProfilePic()
        getTodayTaskList()
        getRandomJokes()
    }
   
    
    
    // MARK: - Actions Add Task Tapped
    @IBAction func addTaskTapped(_ sender: Any) {
        let _ = textFieldShouldReturn(taskTextField)
        self.taskTextField.text = ""
    }
    
    
    @IBAction func UploadMyTaskTapped(_ sender: Any) {
        
        print("Upload My Task")
        
        // create an instance and retain it
        let oauthswift = OAuth2Swift(
            consumerKey:    "ca385eebd79d4582bd465e2aaeccaf34",
            consumerSecret: "8b13fc0446e24afc8e358c3256881d82",
            authorizeUrl:   "https://todoist.com/oauth/authorize?client_id=ca385eebd79d4582bd465e2aaeccaf34&scope=data:read,data:delete&state=secretstring",
            responseType:   "token"
        )
        let handle = oauthswift.authorize(
            withCallbackURL: "iTodo://oauth-callback/iTodo",
            scope: "data:read,data:delete", state:"secretstring") { result in
            print("result: \(result)")
            switch result {
            case .success(let (credential, response, parameters)):
              print("------ Succcess--------", response)
              print(credential.oauthToken)
              // Do your request
            case .failure(let error):
              print("------ Failed--------")
              print(error.localizedDescription)
            }
        }
        print("HERE")
        
    }
    
    // MARK: - Get Today Task List
    func getTodayTaskList() {
        TodoListUser.getTaskList(completion: handleTaskList(taskSnapshot:))
        
        //TodoListUser.getTasklistId(completion: handleTaskListId(tasklistId:error:))
    }
    
    // MARK:- Handle Task List
    func handleTaskList(taskSnapshot: DataSnapshot){
       
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let endDate = getFormattedDate(date: yesterday, format: "yyyy-MM-dd HH:mm:ss")
        
        let task = taskSnapshot.value as! [String: String]
        
        if let taskCreated = task[TodoList.taskCreated], taskCreated >= endDate {
    
            self.taskList.append(taskSnapshot)
            self.taskTableView.insertRows(at: [IndexPath(row: self.taskList.count - 1, section: 0)], with: .automatic)
        }
    }
  

    func handleTaskListId(tasklistId: String?, error: Error?){
         
        if error == nil {
            
            if let tasklistId =  tasklistId , !tasklistId.isEmpty{
                print("Yes: \(tasklistId)")
                
            } else {
                print("No")
                
                TodoListUser.insertTasklists(completion: handleTaskListIdAddApi(taskListId:error:))
            }
        }
        
    }
    
    func handleTaskListIdAddApi(taskListId: String?, error: Error?){
        
        if error == nil {
            
            if let tasklistId =  taskListId , !tasklistId.isEmpty{
                print("Yes: \(tasklistId)")
                
                TodoListUser.addTasklistId(tasklistId: tasklistId, completion: handleTaskListIdAddFB(status:error:))
                
            }
        } else {
            print(error?.localizedDescription)
        }
        
    }
    
    func handleTaskListIdAddFB(status: Bool, error: Error?){
        
        if(status){
            print("Successfully add tasklistId")
        }
    }
    
    // MARK: - Add Task
    func addTask(taskTitle: String){
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let taskCreated = dateFormatter.string(from: date)
        
        TodoListUser.addTask(taskTitle: taskTitle, taskCreated: taskCreated, completion: handleTask(handleType:status:error:))
        
    }
    
    // MARK:- Update Task
    func updateTaskStatus(at indexPath: IndexPath, status: Bool){
        
        let taskSnapshot: DataSnapshot! = taskList[indexPath.row]
        let key = taskSnapshot.key
        
        var task: [String: String] = [:]
        
        task[TodoList.status] = status ? "1" : "0"
        
        let taskCompleted = status ? getFormattedDate(date: Date(), format: "yyyy-MM-dd HH:mm:ss") : ""
        
        
        TodoListUser.updateTask(status: status, taskCompleted: taskCompleted, key: key, completion: handleTask(handleType:status:error:))
    }

    
    // MARK:- Delete Task
    func deleteTask(at indexPath: IndexPath){
        
        let taskSnapshot: DataSnapshot! = taskList[indexPath.row]
        let key = taskSnapshot.key
        
        TodoListUser.deleteTask(key: key, completion: handleTask(handleType:status:error:))
        
    }
    
    // MARK:- Handle Task
    func handleTask(handleType: String, status: Bool, error: Error?){
        
        if let error = error {
            print("Task could not be \(handleType): \(error).")
            self.showFailureMessage(title: "Task Not \(handleType)", message: "\(error.localizedDescription)")
        } else {
            print("Task \(handleType) successfully!")
        }
    }
    
    func getRandomJokes(){
        
        TodoListUser.getRandomJokes(completion: handleRandomJokes(setup:punchline:error:))
    }
    
    func handleRandomJokes(setup: String?, punchline: String?, error: Error?){
        
       
        if let setup = setup, let  punchline = punchline {
            print(setup)
            print(punchline)
            
            self.jokesLabel.text = setup + " " + punchline
            
            self.jokesLabel.translatesAutoresizingMaskIntoConstraints = false
            self.jokesLabel.font = .systemFont(ofSize: 17)
            self.jokesLabel.textColor = .blue
           

            UIView.animate(withDuration: 12.0, delay: 1, options: ([.curveLinear, .repeat]), animations: {() -> Void in
                    self.jokesLabel.center = CGPoint(x: 0 - self.jokesLabel.bounds.size.width / 2, y: self.jokesLabel.center.y)
                }, completion:  { _ in })
        }
            
    }
}

// MARK: - TodoListViewController:  UITableViewDataSource, UITableViewDelegate
extension TodoListViewController:  UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  taskList.count
    }
    
    // MARK: - Cell For Row At
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListViewCell", for: indexPath) as! TaskListViewCell
       
        let taskSnapshot: DataSnapshot! = taskList[indexPath.row]
        let task = taskSnapshot.value as! [String: String]
        let status = task[TodoList.status]
        
        if status == "1" {
            cell.checkboxImage.image = UIImage(named: "checkBoxChecked")
            cell.taskLabel.textColor = .gray
        } else {
            cell.checkboxImage.image = UIImage(named: "checkBoxUnChecked")
            cell.taskLabel.textColor = .black
        }
        
        cell.taskLabel.text = task[TodoList.taskTitle]
        
        return cell
    }
    
    // MARK: - Did Select Row At
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TaskListViewCell else { return }
        
        var status = false
        
        if cell.checkboxImage.image == UIImage(named: "checkBoxChecked"){
            cell.checkboxImage.image = UIImage(named: "checkBoxUnChecked")
            cell.taskLabel.textColor = .black
            
        } else {
        
            cell.checkboxImage.image = UIImage(named: "checkBoxChecked")
            cell.taskLabel.textColor = .gray
            
            status = true
        }
        
        updateTaskStatus(at: indexPath, status: status)
    }
    
    // MARK: -  Table View  Commit Editing Style
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            
            deleteTask(at: indexPath)
            self.taskList.remove(at: indexPath.row)
            tableView.reloadData()
            
        }
    }
}

// MARK: - TodoListViewController: UITextFieldDelegate
extension TodoListViewController: UITextFieldDelegate {
    
    // MARK: - TextField Should Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !textField.text!.isEmpty {
            addTask(taskTitle: textField.text!)
            textField.resignFirstResponder()
            textField.text = ""
        }
        return true
    }
}


