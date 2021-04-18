//
//  TodoArchiveViewController.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 4/18/21.
//

import UIKit
import Firebase

class TodoArchiveViewController: UIViewController {

    
    @IBOutlet weak var taskArchiveTableView: UITableView!
    
    // MARK: - Properties
    var ref: DatabaseReference!
    var taskList: [DataSnapshot]! = []
   
    var displayName = ""
    fileprivate var _refHandle: DatabaseHandle!
    
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        self.taskArchiveTableView.delegate = self
        self.taskArchiveTableView.dataSource = self
       
        
        configureDatabase()
        
        self.displayName = String(Auth.auth().currentUser?.displayName ?? "")
       
    }
    
    // MARK: - View Did Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Actions signOutTapped
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
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let endDate = getFormattedDate(date: yesterday, format: "yyyy-MM-dd HH:mm:ss")
        
        _refHandle = ref.child("Tasks").queryOrdered(byChild: "taskCreated").queryEnding(atValue: endDate).observe(.childAdded){ (snapshot: DataSnapshot) in
            
            self.taskList.append(snapshot)
            self.taskArchiveTableView.insertRows(at: [IndexPath(row: self.taskList.count - 1, section: 0)], with: .automatic)
        }
    }
    
    deinit {
        self.ref.child("Tasks").removeObserver(withHandle: _refHandle)
        
    }
    
    
}


extension TodoArchiveViewController:  UITableViewDataSource, UITableViewDelegate {
    // MARK: - Number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return  taskList.count
    }
    
    // MARK: - Cell For Row At
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskArchiveViewCell", for: indexPath)
       
        let taskSnapshot: DataSnapshot! = taskList[indexPath.row]
        let task = taskSnapshot.value as! [String: String]
        let status = task[Tasks.status]
        
        cell.textLabel?.text = task[Tasks.taskTitle]
        cell.textLabel?.textColor =  status == "1" ? .gray : .black
        
        if let taskCompleted =  task[Tasks.taskCompleted] ,  taskCompleted != "" {
            //let formatingDate = getFormattedDate(date: task[Tasks.taskCompleted], format: "MMM dd, yyyy hh:mm:ss a")
            
            cell.detailTextLabel?.text = "Completion Date: " + taskCompleted
            cell.detailTextLabel?.textColor = .gray
            
        } else {
            cell.detailTextLabel?.text = "Created Date: " + String(task[Tasks.taskCreated] ?? "")
        }
        
        return cell
    }
    
   
}
