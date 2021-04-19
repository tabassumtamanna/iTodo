//
//  TodoListViewController.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 4/16/21.
//

import UIKit
import Firebase


class TodoListViewController: UIViewController {

    
    // MARK: - Outlets
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var taskTableView: UITableView!
    
    
    // MARK: - Properties
    var ref: DatabaseReference!
    var taskList: [DataSnapshot]! = []
    var displayName = ""
    
    fileprivate var _refHandle: DatabaseHandle!
    
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        self.taskTableView.delegate = self
        self.taskTableView.dataSource = self
        self.taskTextField.delegate = self
        self.taskTextField.text = ""
        
        configureDatabase()
        
        self.displayName = String(Auth.auth().currentUser?.displayName ?? "") 
       
    }
    
    // MARK: - Actions
    
    @IBAction func addTaskTapped(_ sender: Any) {
        let _ = textFieldShouldReturn(taskTextField)
        self.taskTextField.text = ""
    }
    
    // MARK: - signOutTapped
    @IBAction func signOutTapped(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            
            self.dismiss(animated: true, completion: nil)
            
        } catch {
            print("unable to sign out: \(error)")
        }
    }
    
    
    // MARK: - Config
    
    func configureDatabase() {
        self.ref = Database.database().reference()
        
        //let currentDate = getFormattedDate(date: Date(), format: "yyyy-MM-dd HH:mm:ss")
        let userID : String = (Auth.auth().currentUser?.uid)!
        print("userID: \(userID)")
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let endDate = getFormattedDate(date: yesterday, format: "yyyy-MM-dd HH:mm:ss")
        
        _refHandle = ref.child("Tasks").queryOrdered(byChild: "taskCreated").queryStarting(atValue: endDate).observe(.childAdded){ (snapshot: DataSnapshot) in
        
        //_refHandle = ref.child("Tasks").queryOrdered(byChild: "userId").queryStarting(atValue: userID).queryEnding(atValue: userID).observe(.childAdded){ (snapshot: DataSnapshot) in
            self.taskList.append(snapshot)
            self.taskTableView.insertRows(at: [IndexPath(row: self.taskList.count - 1, section: 0)], with: .automatic)
        }
       
    }
    
    deinit {
        self.ref.child("Tasks").removeObserver(withHandle: _refHandle)
        
    }
    

    // MARK: - Add Task
    
    func addTask(data: [String:String]){
        
        var mdata = data
        mdata[Tasks.status] = "0"
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        mdata[Tasks.taskCreated] = dateFormatter.string(from: date)
        mdata[Tasks.taskCompleted] = ""
        mdata[Tasks.userId] = Auth.auth().currentUser?.uid
        
        self.ref.child("Tasks").childByAutoId().setValue(mdata)
        
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
    
        self.ref.child("Tasks").child(key).updateChildValues(task)
    }
    
    // MARK:- Delete Task
    func deleteTask(at indexPath: IndexPath){
        
        let taskSnapshot: DataSnapshot! = taskList[indexPath.row]
        let key = taskSnapshot.key
        
        self.ref.child("Tasks").child(key).removeValue() { error, arr  in
            if error != nil {
                print("error \(error?.localizedDescription ?? "")")
            }
        }
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
            let data = ["task": textField.text! as String]
            addTask(data: data)
            textField.resignFirstResponder()
            textField.text = ""
        }
        return true
    }
}
