//
//  TodoListViewController.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 4/16/21.
//

import UIKit
import Firebase
import FirebaseUI

class TodoListViewController: UIViewController {

    
    // MARK: - Properties
    var ref: DatabaseReference!
    var taskList: [DataSnapshot]! = []
    fileprivate var _refHandle: DatabaseHandle!
    
    // MARK: -  TaskFields
    struct TaskFields {
        static let taskName = "task"
        static let status = "status"
        static let taskCreated = "taskCreated"
        static let taskCompleted = "taskCompleted"
        
    }
    
    // MARK: - Outlets
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var taskTableView: UITableView!
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        self.taskTableView.delegate = self
        self.taskTableView.dataSource = self
        self.taskTextField.delegate = self
        self.taskTextField.text = ""
        
        configureDatabase()
        
        
    }
    
    // MARK: - Config
    
    func configureDatabase() {
        self.ref = Database.database().reference()
        _refHandle = ref.child("Tasks").observe(.childAdded){ (snapshot: DataSnapshot) in
            
            self.taskList.append(snapshot)
            self.taskTableView.insertRows(at: [IndexPath(row: self.taskList.count - 1, section: 0)], with: .automatic)
            //self.scrollToBottomMessage()
        }
    }
    
    deinit {
        ref.child("Tasks").removeObserver(withHandle: _refHandle)
        
    }
    

    // MARK: - Add Task
    
    func addTask(data: [String:String]){
        
        var mdata = data
        mdata[TaskFields.status] = "0"
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        mdata[TaskFields.taskCreated] = dateFormatter.string(from: date)
        mdata[TaskFields.taskCompleted] = ""
        
        self.ref.child("Tasks").childByAutoId().setValue(mdata)
    }
    
    
    // MARK:- Update Task
    func updateTaskStatus(at indexPath: IndexPath, status: Bool){
        
        let taskSnapshot: DataSnapshot! = taskList[indexPath.row]
        let key = taskSnapshot.key
        
        var task: [String: String] = [:]
        
        task[TaskFields.status] = status ? "1" : "0"
        
        if status {
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            task[TaskFields.taskCompleted] = dateFormatter.string(from: date)
        } else {
            task[TaskFields.taskCompleted] = ""
        }
    
        self.ref.child("Tasks").child(key).updateChildValues(task)
    }
    
    // MARK:- Delete Task
    func deleteTask(at indexPath: IndexPath){
        
        let taskSnapshot: DataSnapshot! = taskList[indexPath.row]
        let key = taskSnapshot.key
        
        self.ref.child("Tasks").child(key).removeValue() { error, arr  in
            if error != nil {
                print("error \(error)")
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func addTaskTapped(_ sender: Any) {
        let _ = textFieldShouldReturn(taskTextField)
        self.taskTextField.text = ""
    }
    
    
}

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
        let status = task[TaskFields.status]
        
        if status == "1" {
            cell.checkboxImage.image = UIImage(named: "checked")
            cell.taskLabel.textColor = .gray
        } else {
            cell.checkboxImage.image = UIImage(named: "unchecked")
            cell.taskLabel.textColor = .black
        }
        
        cell.taskLabel.text = task[TaskFields.taskName]
        
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
            let data = ["task": textField.text! as String]
            addTask(data: data)
            textField.resignFirstResponder()
            textField.text = ""
        }
        return true
    }
}
