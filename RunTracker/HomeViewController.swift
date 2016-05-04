//
//  ViewController.swift
//  RunTracker
//
//  Created by Di on 2/5/16.
//  Copyright © 2016 Di. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UITextFieldDelegate {
    
    var managedObjectContext: NSManagedObjectContext!
    var weight: Weight!
    //var weight:Double?

    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var stepperBtn: UIStepper!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepperBtn.autorepeat = true
        //db query later on
        deleteAllWeight()
        getWeight()
        
        stepperBtn.value = weight.weight
        weightTextField.text = weight.weight.description
        weightTextField.delegate = self
        
//        weight.weight = 120
//        print("weight")
//        print("no weight")
    
//        if let thisWeight = NSEntityDescription.insertNewObjectForEntityForName("Weight", inManagedObjectContext: self.managedObjectContext!) as? Weight{
//            thisWeight.weight = Double(weightTextField.text!)!
//            weight = thisWeight
//        }

        
        //thisWeight = NSEntityDescription
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
//        view.addGestureRecognizer(tap)
    }
    
//    func dismissKeyboard() {
//        //Causes the view (or one of its embedded text fields) to resign the first responder status.
//        view.endEditing(true)
//    }
    
    func deleteAllWeight(){
        
        let fetchRequest = NSFetchRequest(entityName: "Weight")
        
        do{
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            
            for res in result{
                self.managedObjectContext.deleteObject(res as! NSManagedObject)
            }
            
        }catch {
            let fetchError = error as NSError
            print(fetchError)
        }

        print("delete")
    }

    
    func getWeight(){
        
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Weight", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entityDescription
        
        do{
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            if result.count > 0 {
                
                weight = result.first as! Weight
                if weight.weight == 0{
                    weight.weight = 120
                }
                
            }else{
                //weight = Weight()
                weight = NSEntityDescription.insertNewObjectForEntityForName("Weight",
                    inManagedObjectContext: managedObjectContext) as! Weight
                weight.weight = 120
                print("no weight")
            }
        }catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        //return result
    }
    
    
    @IBAction func clickStepper(sender: UIStepper) {
        
        weightTextField.text = Int(sender.value).description
        weight.weight = sender.value
        saveWeight()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        weightTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //weightTextField.resignFirstResponder()
        if let tmp = weightTextField.text{
            //print("weightTextField not nil")
            if tmp.characters.count == 0 {
                weightLabel.text = "100.0"
                //print("text: \(weightTextField.text)")
            }else{
                weightLabel.text = weightTextField.text
                weight.weight = Double(weightTextField.text!)!
                //print("text not nil: \(weightTextField.text)")
            }
        }else{
            ///print("no weightTextField.text")
            weightLabel.text = "120.0"
        }

        saveWeight()
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
    
    func saveWeight(){
        
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Weight", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entityDescription
        
        do {
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            print("weight count: \(result.count)")
            weight = result[0] as! Weight
            print("save weight: \(weight)")
            weight.setValue(weight.weight, forKey: "weight")
            try weight.managedObjectContext?.save()
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
//        if let thisWeight = NSEntityDescription.insertNewObjectForEntityForName("Weight", inManagedObjectContext: self.managedObjectContext!) as? Weight{
//            
//            thisWeight.weight = Double(weightLabel.text!)!
//            //print("this weight: \(thisWeight)")
//            weight = thisWeight
//        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //print("prepareForSegue")
        if segue.identifier == "showRunHistory"{
            let nav = segue.destinationViewController as! UINavigationController
            if let runHistoryTVC = nav.topViewController as? RunningHistoryTableViewController{
                runHistoryTVC.managedObjectContext = managedObjectContext
            }
        }else if segue.identifier == "showRun" {
            //print("show Run outside")
            let nav = segue.destinationViewController as! UINavigationController
                if let newRunVC:newRunViewController = nav.topViewController as? newRunViewController{
                    newRunVC.managedObjectContext = managedObjectContext
                    newRunVC.weight = weight
                    print("in segue: \(weight)")
                    print("show Run inside \(newRunVC.weight?.weight)")

                }
            
        }else if segue.identifier == "showAchievements"{
            print("show achievements")
            
        }else{
            
            print("no segue math")
        }
        //print("no idea")
    }
    
    

}

