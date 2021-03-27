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
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let today = NSDate()
       
        let datePredicate = NSPredicate(format: "createdDate < %@  ", today as NSDate)
        fetchRequest.predicate = datePredicate
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
        
    }

    // MARK: - Table view data source

   func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchResultsController.sections?[0].numberOfObjects ?? 0
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
    
    func getFormattedDate(date: Date, format: String) -> String {
            let dateformat = DateFormatter()
            dateformat.dateFormat = format
            return dateformat.string(from: date)
    }

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

