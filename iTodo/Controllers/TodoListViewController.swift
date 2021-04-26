//
//  TodoListViewController.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 4/16/21.
//

import UIKit
import Firebase

// MARK: - TodoListViewController
class TodoListViewController: UIViewController {

    
    // MARK: - Outlets
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var taskTableView: UITableView!
   
    
    // MARK: - Properties
    var ref: DatabaseReference!
    var taskList: [DataSnapshot]! = []
    
    fileprivate var _refHandle: DatabaseHandle!
    
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        self.taskTableView.delegate = self
        self.taskTableView.dataSource = self
        self.taskTextField.delegate = self
        self.taskTextField.text = ""
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        
        configureDatabase()
        
       // self.displayName.title = String(Auth.auth().currentUser?.email?.components(separatedBy: "@")[0] ?? "")
       
    }
    
    
   
    // MARK: - Actions Add Task Tapped
    @IBAction func addTaskTapped(_ sender: Any) {
        let _ = textFieldShouldReturn(taskTextField)
        self.taskTextField.text = ""
    }
    
    
   
    // MARK: - configure Database
    func configureDatabase() {
        
        TodoListUser.getTaskList(completion: handleTaskList(taskSnapshot:))
        
        /*
        _refHandle = ref.child("Tasks").queryOrdered(byChild: "userId").queryStarting(atValue: userID).queryEnding(atValue: userID).observe(.childAdded) { ( snapshot: DataSnapshot) in
            
            let task = snapshot.value as! [String: String]
            
            if let taskCreated = task[Tasks.taskCreated], taskCreated >= endDate {
        
                self.taskList.append(snapshot)
                self.taskTableView.insertRows(at: [IndexPath(row: self.taskList.count - 1, section: 0)], with: .automatic)
            }
        }
        */
        
      
    }
    
    func handleTaskList(taskSnapshot: DataSnapshot){
       
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let endDate = getFormattedDate(date: yesterday, format: "yyyy-MM-dd HH:mm:ss")
        
        let task = taskSnapshot.value as! [String: String]
        
        if let taskCreated = task[Tasks.taskCreated], taskCreated >= endDate {
    
            self.taskList.append(taskSnapshot)
            self.taskTableView.insertRows(at: [IndexPath(row: self.taskList.count - 1, section: 0)], with: .automatic)
        }
    }
    
   /*
    deinit {
        self.ref.child("Tasks").removeObserver(withHandle: _refHandle)
    }
    */

    // MARK: - Add Task
    func addTask(taskTitle: String){
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let taskCreated = dateFormatter.string(from: date)
        
        TodoListUser.addTask(taskTitle: taskTitle, taskCreated: taskCreated, completion: handleAddTask(status:error:))
        
    }
    
    func handleAddTask(status: Bool, error: Error?){
        
        if let error = error {
            print("Task could not be saved: \(error).")
            self.showFailureMessage(title: "Task Not Saved", message: "\(error.localizedDescription)")
        } else {
            print("Task saved successfully!")
        }
    }
    
    
    // MARK:- Update Task
    func updateTaskStatus(at indexPath: IndexPath, status: Bool){
        
        let taskSnapshot: DataSnapshot! = taskList[indexPath.row]
        let key = taskSnapshot.key
        
        var task: [String: String] = [:]
        
        task[Tasks.status] = status ? "1" : "0"
        
        if status {
            task[Tasks.taskCompleted] = getFormattedDate(date: Date(), format: "yyyy-MM-dd HH:mm:ss")
        } else {
            task[Tasks.taskCompleted] = ""
        }
    
        self.ref.child("Tasks").child(key).updateChildValues(task){ (error:Error?, ref:DatabaseReference) in
            
            if let error = error {
                print("Task could not be updated: \(error).")
                self.showFailureMessage(title: "Task Not Updated", message: "\(error.localizedDescription)")
            }
            else {
                print("Task updated successfully!")
            }
        }
    }
    
    // MARK:- Delete Task
    func deleteTask(at indexPath: IndexPath){
        
        let taskSnapshot: DataSnapshot! = taskList[indexPath.row]
        let key = taskSnapshot.key
        
        self.ref.child("Tasks").child(key).removeValue() { error, arr  in
            if error != nil {
                print("error \(error?.localizedDescription ?? "")")
                self.showFailureMessage(title: "Task Not Deleted", message: (error?.localizedDescription) ?? "")
            }
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
        let status = task[Tasks.status]
        
        if status == "1" {
            cell.checkboxImage.image = UIImage(named: "checked")
            cell.taskLabel.textColor = .gray
        } else {
            cell.checkboxImage.image = UIImage(named: "unchecked")
            cell.taskLabel.textColor = .black
        }
        
        cell.taskLabel.text = task[Tasks.taskTitle]
        
        return cell
    }
    
    // MARK: - Did Select Row At
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TaskListViewCell else { return }
        
        var status = false
        
        if cell.checkboxImage.image == UIImage(named: "checked"){
            cell.checkboxImage.image = UIImage(named: "unchecked")
            cell.taskLabel.textColor = .black
            
        } else {
        
            cell.checkboxImage.image = UIImage(named: "checked")
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !textField.text!.isEmpty {
            addTask(taskTitle: textField.text!)
            textField.resignFirstResponder()
            textField.text = ""
        }
        return true
    }
}
