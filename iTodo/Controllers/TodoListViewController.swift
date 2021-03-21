//
//  TodoListViewController.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 3/10/21.
//

import UIKit
import CoreData


class TodoListViewController: UIViewController, UITextFieldDelegate {

    // MARK:- IBOutlets
    @IBOutlet weak var taskTitle: UITextField!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
   
    var taskList : [String] = []
    
    // MARK:-  View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //disableAddTaskButton(true)
        
        self.tableView.delegate = self
        self.taskTitle.delegate = self
        self.taskTitle.text = ""
    }
    
    // MARK:-  Add Task Tapped
    @IBAction func addTaskTapped(_ sender: Any) {
        addTask()
    }
    
    // MARK:-  Add Task
    func addTask() {
        if self.taskTitle.text == "" {
            print("Please enter a task")
        }
        
        self.taskList.append(self.taskTitle.text!)
        self.tableView.reloadData()
        self.taskTitle.text = ""
    }
    
    // MARK:- Disable Add Task Button
    func disableAddTaskButton(_ isEnable : Bool) {
        self.addTaskButton.isEnabled = !isEnable
    }
    
    
    // MARK: - Text Field Should Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    // MARK: - Text Field Did End Editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        addTask()
        
        self.taskTitle.becomeFirstResponder()
    }
    
    
}

// MARK: -  Extension TodoListViewController
extension TodoListViewController : UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return taskList.count
    }
    
    // MARK: - Cell For Row At
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskListViewCell")!
       
        let task = taskList[(indexPath as NSIndexPath).row]
        
        cell.textLabel?.text = task
        
        return cell
    }
    
}
