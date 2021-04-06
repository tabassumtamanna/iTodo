//
//  TodoListViewController.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 3/10/21.
//

import UIKit
import CoreData


class TodoListViewController: UIViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {

    // MARK:- IBOutlets
    @IBOutlet weak var taskTitle: UITextField!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
   
    // MARK: - Variables
    var dataController: DataController!
    var fetchResultsController: NSFetchedResultsController<Task>!
    
    
    // MARK:-  View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //disableAddTaskButton(true)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.taskTitle.delegate = self
        self.taskTitle.text = ""
        
        setupFetchResultsController()
    }
    
    // MARK:-  Add Task Tapped
    @IBAction func addTaskTapped(_ sender: Any) {
        addTask()
    }
    
    // MARK: - Setup Fetch Results Controller
    fileprivate func setupFetchResultsController(){
        
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let today = NSDate()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: NSDate() as Date)
        print("today: \(today)")
        print("yesterday: \(String(describing: yesterday))")
       
        let datePredicate = NSPredicate(format: "createdDate < %@ and createdDate > %@ ", today as NSDate, yesterday! as NSDate)
        fetchRequest.predicate = datePredicate
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
        
    }
    
    // MARK:-  Add Task
    func addTask() {
        if self.taskTitle.text == "" {
            print("Please enter a task")
            showFailureMessage(title: "Task Field Empty!", message: "Please enter a task.")

        } else {
            let taskTitle = self.taskTitle.text
            
            let task = Task(context: dataController.viewContext)
            task.taskTitle = taskTitle
            task.taskDescription = taskTitle
            task.status = false
            task.createdDate = Date()
            
            do {
                try dataController.viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
            setupFetchResultsController()
            self.tableView.reloadData()
            self.taskTitle.text = ""
        }
    }
    
    // MARK:- Delete Task
    func deleteTask(at indexPath: IndexPath){
        
        let taskToDelete = fetchResultsController.object(at: indexPath)
        
        dataController.viewContext.delete(taskToDelete)
        
        do {
            try dataController.viewContext.save()
        } catch {
            
            print(error.localizedDescription)
        }
        setupFetchResultsController()
        self.tableView.reloadData()
    }
    
    // MARK:- Update Task Status
    func updateTaskStatus(at indexPath: IndexPath, status: Bool){
        
        let taskToUpdate = fetchResultsController.object(at: indexPath)
        
        taskToUpdate.status = status
        
        taskToUpdate.completedDate = status ? Date() : nil
        
        do {
            try dataController.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
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
    
    // MARK: -  Show Failure Message
    func showFailureMessage(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
}

// MARK: -  Extension TodoListViewController
extension TodoListViewController : UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    // MARK: - Cell For Row At
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListViewCell", for: indexPath) as! TaskListViewCell
       
        let task = fetchResultsController.object(at: indexPath)
        
        cell.taskLabel.text = task.taskTitle
        
        if task.status {
            cell.checkboxImage.image = UIImage(named: "checked")
            cell.taskLabel.textColor = .gray
        } else {
            cell.checkboxImage.image = UIImage(named: "unchecked")
            cell.taskLabel.textColor = .black
        }
        
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
            tableView.reloadData()
            
        } 	
    }
    
}
