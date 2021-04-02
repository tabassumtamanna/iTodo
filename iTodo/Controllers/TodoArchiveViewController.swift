//
//  TodoArchiveViewController.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 3/25/21.
//

import UIKit
import CoreData

class TodoArchiveViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate{

    // MARK:- IBOutlets
    
    @IBOutlet weak var archiveTableView: UITableView!
    
    // MARK: - Variables
    var dataController: DataController!
    var fetchResultsController: NSFetchedResultsController<Task>!
    var sections = [MonthSection]()
    
    // MARK: - struct: Month Section
    struct MonthSection{
        var date: Date
        var taskList : [Task]
    }
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.archiveTableView.delegate = self
        self.archiveTableView.dataSource = self
        
        setupFetchResultsController()
        
        let groups = Dictionary(grouping: self.fetchResultsController.fetchedObjects!) { (fetchedObject) in
            return firstDay(date: fetchedObject.createdDate!)
        }
        
        self.sections = groups.map(MonthSection.init(date:taskList:))
        self.sections.sort { (lhs, rhs) in lhs.date > rhs.date}
        print(self.sections)
    }
    
    // MARK: - First Day
    fileprivate func firstDay(date: Date) ->  Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components)!
    }
    
    // MARK: - Setup Fetch Results Controller
    fileprivate func setupFetchResultsController(){
        
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let sortDescriptorDate = NSSortDescriptor(key: "createdDate", ascending: false)
        let sortDescriptorStatus = NSSortDescriptor(key: "status", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptorDate, sortDescriptorStatus]
        
        
        let today = NSDate()
       
        let datePredicate = NSPredicate(format: "createdDate < %@  ", today as NSDate)
        fetchRequest.predicate = datePredicate
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: "createdDate", cacheName: nil)
        
        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }

    // MARK: - Table view data source

    // MARK: - Number Of Sections
   func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count
    }
    
    // MARK: - Title For Header In Section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.sections[section]
        let date = section.date
        
        let formatingDate = getFormattedDate(date: date, format: "MMM dd, yyyy")
        
        return formatingDate
    }
    
    // MARK: - Number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections[section]
        
        return  section.taskList.count
    }

    // MARK: - Cell For Row At
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskArchiveViewCell", for: indexPath)
       
        
        //let task = fetchResultsController.object(at: indexPath)
        let section = self.sections[indexPath.section]
        let task = section.taskList[indexPath.row]
        
        cell.textLabel?.text = task.taskTitle
        cell.textLabel?.textColor =  task.status ? .gray : .black
        
        if task.completedDate != nil {
            let formatingDate = getFormattedDate(date: task.completedDate!, format: "MMM dd, yyyy hh:mm:ss a")
            
            cell.detailTextLabel?.text = "Completion Date: " + formatingDate
            cell.detailTextLabel?.textColor = .gray
            
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    // MARK: - Get Formatted Date
    func getFormattedDate(date: Date, format: String) -> String {
            let dateformat = DateFormatter()
            dateformat.dateFormat = format
            return dateformat.string(from: date)
    }


}

