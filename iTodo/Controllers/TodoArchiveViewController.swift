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
    var taskList: [Task] = []
    var sections = [GroupedSection<Date, Task>]()
    
    // MARK: - Grouped Section
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
       
        getProfilePic()
        getArchiveTaskList()
        
    }
    
    // MARK: - Get Grouped Task List
    fileprivate func getGroupedTaskList(_ taskSnapshot: DataSnapshot){
        
        let taskFire = taskSnapshot.value as! [String: String]
        
        let taskTitle = taskFire[TodoList.taskTitle] ?? ""
        let status = taskFire[TodoList.status] ?? ""
        let taskCreated = taskFire[TodoList.taskCreated] ?? ""
        let taskCompleted = taskFire[TodoList.taskCompleted] ?? ""
        let userId = taskFire[TodoList.userId] ?? ""
        
        self.taskList.append(Task(taskTitle: taskTitle, status: status, taskCreated: taskCreated, taskCompleted: taskCompleted, userId: userId))
           
        
        self.sections = GroupedSection.group(rows: self.taskList, by: {getTaskSectionName($0.taskCreated)})
        self.sections.sort { (lhs, rhs) in lhs.sectionItem > rhs.sectionItem}
        
        self.taskArchiveTableView.reloadData()
        
    }
    
    // MARK: - Get Archive Task List
    func getArchiveTaskList() {
        
        TodoListUser.getTaskList(completion: handleArchiveTaskList(taskSnapshot:))
    }
    
    // MARK: -  Handle Task List
    func handleArchiveTaskList(taskSnapshot: DataSnapshot){
       
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let endDate = getFormattedDate(date: yesterday, format: "yyyy-MM-dd HH:mm:ss")
        
        let task = taskSnapshot.value as! [String: String]
        
        if let taskCreated = task[TodoList.taskCreated], taskCreated < endDate {
    
            self.getGroupedTaskList(taskSnapshot)
        }
    }
    
    // MARK: - Get Task Section Name
    func getTaskSectionName(_ date: String)  ->  Date  {
       
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateformat.date(from: date)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date!)
        return calendar.date(from: components)!
        
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
        
        cell.textLabel?.text = task.taskTitle
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
