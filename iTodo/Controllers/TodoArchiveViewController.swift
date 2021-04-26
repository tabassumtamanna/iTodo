//
//  TodoArchiveViewController.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 4/18/21.
//

import UIKit
import Firebase

// MARK: - TodoArchiveViewController
class TodoArchiveViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var taskArchiveTableView: UITableView!
    
    // MARK: - Properties
    var ref: DatabaseReference!
    //var taskList: [DataSnapshot] = []
   
    var displayName = ""
    fileprivate var _refHandle: DatabaseHandle!
    
    
    var taskListGroup: [FireTask] = []
    var sections = [GroupedSection<Date, FireTask>]()
    
    // MARK: - GroupedS ection
    struct GroupedSection<SectionItem : Hashable, RowItem>{
        
        var sectionItem : SectionItem
        var rowItem : [RowItem]
        
        static func group(rows : [RowItem], by criteria : (RowItem) -> SectionItem) -> [GroupedSection<SectionItem, RowItem>] {
            let groups = Dictionary(grouping: rows, by: criteria)
            
            return groups.map(GroupedSection.init(sectionItem: rowItem:))
        }
    }
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        self.taskArchiveTableView.delegate = self
        self.taskArchiveTableView.dataSource = self
       
        configureDatabase()
        
        self.displayName = String(Auth.auth().currentUser?.displayName ?? "")
        
        
    }
    
    func getDateFromString(_ date: String)  ->  Date  {
       
        
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateformat.date(from: date)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date!)
        return calendar.date(from: components)!
        
    }
    
    fileprivate func getTaskList(_ taskSnapshot: DataSnapshot){
        
        let taskFire = taskSnapshot.value as! [String: String]
        
        let taskTitle = taskFire[Tasks.taskTitle] ?? ""
        let status = taskFire[Tasks.status] ?? ""
        let taskCreated = taskFire[Tasks.taskCreated] ?? ""
        let taskCompleted = taskFire[Tasks.taskCompleted] ?? ""
        let userId = taskFire[Tasks.userId] ?? ""
        
        self.taskListGroup.append(FireTask(task: taskTitle, status: status, taskCreated: taskCreated, taskCompleted: taskCompleted, userId: userId))
           
        
        self.sections = GroupedSection.group(rows: self.taskListGroup, by: {getDateFromString($0.taskCreated)})
        self.sections.sort { (lhs, rhs) in lhs.sectionItem > rhs.sectionItem}
        
        self.taskArchiveTableView.reloadData()
        
    }
    
   
        
    // MARK: - configure Database
    
    func configureDatabase() {
        
        TodoListUser.getTaskList(completion: handleTaskList(taskSnapshot:))
    }
    
    func handleTaskList(taskSnapshot: DataSnapshot){
       
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let endDate = getFormattedDate(date: yesterday, format: "yyyy-MM-dd HH:mm:ss")
        
        let task = taskSnapshot.value as! [String: String]
        
        if let taskCreated = task[Tasks.taskCreated], taskCreated < endDate {
    
            self.getTaskList(taskSnapshot)
        }
    }
    
    
}

// MARK: - TodoArchiveViewController:  UITableViewDataSource, UITableViewDelegate
extension TodoArchiveViewController:  UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Number Of Sections
   func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count
    }
    
    //MARK: - Title For Header In Section
   func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       let section = self.sections[section]
       let date = section.sectionItem
       
       let formatingDate = getFormattedDate(date: date, format: "MMM dd, yyyy")
       
       return formatingDate
   }
    
    // MARK: - Number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections[section]
        
        return  section.rowItem.count
    }
   
   
    // MARK: - Cell For Row At
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskArchiveViewCell", for: indexPath)
       
        let section = self.sections[indexPath.section]
        let task = section.rowItem[indexPath.row]
        
        cell.textLabel?.text = task.task
        cell.textLabel?.textColor =  task.status == "1" ? .gray : .black
        
        if task.taskCompleted != "" {
            
            let dateformat = DateFormatter()
            dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let taskCompleted = dateformat.date(from:  task.taskCompleted)
            
            cell.detailTextLabel?.text = "Completion Date: " + getFormattedDate(date: taskCompleted!, format: "MMM dd, yyyy hh:mm:ss a")
            cell.detailTextLabel?.textColor = .gray
            
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
   
}
