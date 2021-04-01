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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.archiveTableView.delegate = self
        self.archiveTableView.dataSource = self
        
        setupFetchResultsController()
    }
    
    
    // MARK: - Setup Fetch Results Controller
    fileprivate func setupFetchResultsController(){
        
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let sortDescriptorDate = NSSortDescriptor(key: "createdDate", ascending: false)
        let sortDescriptorStatus = NSSortDescriptor(key: "status", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptorDate, sortDescriptorStatus]
        
        //fetchRequest.propertiesToGroupBy = ["createdDate", "status"]
        //fetchRequest.propertiesToFetch = ["createdDate", "status"]
    
        
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
        
        print(fetchResultsController.fetchedObjects)
        
    }

    // MARK: - Table view data source

   func numberOfSections(in tableView: UITableView) -> Int {
        
        if let sections = fetchResultsController.sections{
            print("section count: \(sections.count)")
            return sections.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sections = fetchResultsController.sections {
            let currentSection = sections[section]
            
            return currentSection.numberOfObjects
        }
        
        return  0
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskArchiveViewCell", for: indexPath)
       
        
        let task = fetchResultsController.object(at: indexPath)
        
        
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
    
    /*
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchResultsController.sections {
            let currentSection = sections[section]
            
            return currentSection.name
        }
        return nil
    }
    */
    func getFormattedDate(date: Date, format: String) -> String {
            let dateformat = DateFormatter()
            dateformat.dateFormat = format
            return dateformat.string(from: date)
    }


}

