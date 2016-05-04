//
//  RunningHistoryTableViewController.swift
//  RunTracker
//
//  Created by Di on 2/5/16.
//  Copyright © 2016 Di. All rights reserved.
//

import UIKit

import CoreData

class RunningHistoryTableViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext?
    var fetchedResultsController: NSFetchedResultsController!
    var runs = [NSManagedObject]()
    var achieveController = AchieveController()
    var tmpArray: [Achievement]!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRuns()
        tmpArray = achieveController.achieveArray.reverse()
    }
    
    func fetchRuns(){
        
        let request = NSFetchRequest(entityName: "Run")
        let runSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        request.sortDescriptors = [runSort]
        
        //let moc = self.managedObjectContext
        //self.fetchedResultsController.delegate = self
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        managedObjectContext = appDelegate.managedObjectContext
        do{
            let result = try managedObjectContext!.executeFetchRequest(request)
            runs = result as! [NSManagedObject]
        }catch let error as NSError{
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func configureCell(cell: RunningHistoryTableViewCell, indexPath: NSIndexPath) {
        
        let run = runs[indexPath.row] as! Run
        
        //cell.achieveImage = UIImage(named: run.))
        cell.distanceLabel.text = "Distance: " + run.distance.description
        cell.durationLabel.text = "Time: " + run.duration.description
        
        for achieve in tmpArray {
            if run.distance.doubleValue >= achieve.distance {
                //print("image here")
                cell.achieveImage.image = UIImage(named: achieve.image)
                break
            }
            
        }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "historyToDetail" {
            let nav = segue.destinationViewController as! UINavigationController
            if let drVC = nav.topViewController as? DetailRunViewController {
                //print("destination is drVC")
                if let selectRunCell = sender as? RunningHistoryTableViewCell{
                    //print("cell selected")
                    let indexPath = tableView.indexPathForCell(selectRunCell)
                    //print("indexPath find \(indexPath)")
                    drVC.run = runs[indexPath!.row] as! Run
                }
            }
            
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runs.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("runHistoryCell", forIndexPath: indexPath) as! RunningHistoryTableViewCell
        
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    @IBAction func backToHome(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
