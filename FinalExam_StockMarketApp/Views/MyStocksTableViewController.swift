//
//  MyStocksTableViewController.swift
//  FinalExam_StockMarketApp
//
//  Created by user248634 on 10/16/23.
//

import UIKit
import CoreData

class MyStocksTableViewController: UITableViewController {
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    //lazy loading fecthresultcontroller object
    lazy var myFetchResultController : NSFetchedResultsController<Stocks> = {
        //creating a fetch request
        let fetch : NSFetchRequest<Stocks> = Stocks.fetchRequest()
        //giving sort descriptior with isActive key to srot Active & Watching stocks
        fetch.sortDescriptors = [NSSortDescriptor(key: "isActive", ascending: false)]
        //creating the fecthresultcontroller object and assigning it's delegate
        let ftc = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: CoreDataStack.shared.persistentContainer.viewContext, sectionNameKeyPath: "isActive", cacheName: nil)
         ftc.delegate = self
        return ftc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? myFetchResultController.performFetch()
    }
    
    
    @IBAction func editButtonPrssed(_ sender: UIBarButtonItem) {
        //enabling table's edit mode when edit button is pressed and disabling it when Done pressed
        if tableView.isEditing{
            tableView.isEditing = false
            editBarButton.title = "Edit"
        }else{
            tableView.isEditing = true
            editBarButton.title = "Done"
        }
    }
    
    func showTextViewAlert(selectedRowIndexPath:IndexPath) {
        // Create a UIAlertController
        let alertController = UIAlertController(title: "Comment", message: nil, preferredStyle: .alert)

        // Add a UITextView to the alert controller
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter text"
        }

        // Create a "Submit" button
        let submitAction = UIAlertAction(title: "Save", style: .default) { (action) in
            
            //saving the notes by creating notes object and adding it to notesLst for selected stock
            //updating the model entity as per the change on view - using MVC design pattern
            if let text = alertController.textFields?.first?.text {
                print("Entered text: \(text)")
                let objToAddNotes = self.myFetchResultController.object(at: selectedRowIndexPath)
                let note = Note(context: CoreDataStack.shared.persistentContainer.viewContext)
                note.noteDescription = text
                objToAddNotes.addToNotes(note)
                CoreDataStack.shared.saveContext()
            }
        }

        // Create a "Cancel" button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        // Add the actions to the alert controller
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //print("\(myFetchResultController.sections?.count)")
        return myFetchResultController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("\(myFetchResultController.sections?[section].numberOfObjects)")
//        guard let sections = self.myFetchResultController.sections else {
//                fatalError("No sections in fetchedResultsController")
//            }
//            let sectionInfo = sections[section]
//            return sectionInfo.numberOfObjects
        return myFetchResultController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyStockCell", for: indexPath) as! MyStockTableViewCell
        cell.configCell(stockObj: myFetchResultController.object(at: indexPath))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //giving titles for section headers
        if section==0 {
            return "ACTIVE"
        }else{
            return "WATCHING"
        }
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        //not lettign the user move a row within the same section
        if sourceIndexPath.section==proposedDestinationIndexPath.section{
            return sourceIndexPath
        }else{
            return proposedDestinationIndexPath
        }
    }
    
    //enabling the moveable functionality all rows
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let objectToMove = myFetchResultController.object(at: sourceIndexPath)
        //setting the isActive value depending on the destination section and saving the context
        //updating the model entity as per the change on view - using MVC design pattern
        if destinationIndexPath.section==1 {
            objectToMove.isActive=false
        }else {
            objectToMove.isActive=true
        }
        CoreDataStack.shared.saveContext()
    }
    
    //enabling an alert to add comments when a row is clicked
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTextViewAlert(selectedRowIndexPath:indexPath)
    }
   
//uncomment below function to delete any stock from CoreData
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            guard let fetchedObjects = myFetchResultController.fetchedObjects else{
//                return
//            }
//            let objToDel = fetchedObjects[indexPath.row]
//            CoreDataStack.shared.persistentContainer.viewContext.delete(objToDel)
//            CoreDataStack.shared.saveContext()
//        }
//    }

}

//conforming to fecthResultController's delegate - using delegate design pattern
extension MyStocksTableViewController:NSFetchedResultsControllerDelegate{
    
    //upating the view as per chnages in the model entity - using MVC design pattern
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert{
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }else if type == .delete{
            tableView.deleteRows(at: [indexPath!], with: .fade)
        }else if type == .update{
            tableView.reloadData()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
