//
//  newRunViewController.swift
//  RunTracker
//
//  Created by Di on 2/5/16.
//  Copyright © 2016 Di. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation
import HealthKit
import AudioToolbox


class newRunViewController: UIViewController {
    
    var run: Run!
    var weight: Weight?
    var locations = [CLLocation]()
    var timer:NSTimer?
    var calTimer: NSTimer?
    var timerDiff = 2.0
    var calTimerDiff = 2.0
    //var weight = 150.0
    var seconds = 0.0
    var distance = 0.0
    var calories = 0.0
    var caloriesRatio = 0.63
    var alterController: UIAlertController!
    var managedObjectContext: NSManagedObjectContext?
    var segueIdn = "showDetail"
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .Fitness
        _locationManager.distanceFilter = 10.0
        
        return _locationManager
    }()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var startLabel: UIButton!
    @IBOutlet weak var resumeLabel: UIButton!
    
    override func viewDidLoad() {
        //managedObjectContext = NSManagedObjectContext()
        
        //print("weight: \(weight)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //print("new run here")
        resumeLabel.hidden = true
        locationManager.requestAlwaysAuthorization()
        locations.removeAll()
        //print("distance: \(distance)")
        distance = 0.0
        seconds = 0.0
        calories = 0.0
        startLabel.hidden = false
        //caloriesLabel.text = "Calories: 0.0Cal"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        calTimer?.invalidate()
        locationManager.stopUpdatingLocation()
        mapView.delegate = self
        //alterController?.removeFromParentViewController()
    }
    
    
    func startTrack(timer: NSTimer){
        seconds += 2
        
        let time = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
        timeLabel.text = "Time: " + time.description
        let dt = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: Double(round(distance*10)/10))
        distanceLabel.text = "Distance: " + dt.description
        
        let spUnit = HKUnit.meterUnit().unitDividedByUnit(HKUnit.secondUnit())
        let sp = HKQuantity(unit: spUnit, doubleValue: Double(round((distance/seconds)*10)/10))
        speedLabel.text = "Speed: " + sp.description
        
    }
    
    
    func caloriesBurnCalculator(timer: NSTimer){
        
        //let netCaloriesUnit = HKUnit.meterUnit().unitMultipliedByUnit(HKUnit.poundUnit())
        let distanceInMile = distance/(1000*1.6)
        print("inside newRun weight: \(weight)")
        let calValue = Double(round(distanceInMile*caloriesRatio*(weight?.weight)!*10)/10)
        let netCalories = HKQuantity(unit: HKUnit.calorieUnit(), doubleValue: calValue)
        calories = calValue
        caloriesLabel.text = "Calories: " + netCalories.description
        
    }
    
    
    func startUpdateLocation(){
        
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func stopTracking(sender: UIButton) {
        locationManager.stopUpdatingLocation()

        alterController = UIAlertController(title: nil, message: "Save This Running?", preferredStyle: .ActionSheet)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default){
            (action: UIAlertAction) in
            self.saveThisRunning()
        }
        
        let cancelAction = UIAlertAction(title: "Discard", style: .Default){
            (action) in self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alterController!.addAction(saveAction)
        alterController!.addAction(cancelAction)
        self.presentViewController(alterController, animated: true, completion: nil)
    }
    
    func saveThisRunning(){
        //print("save running")
        if managedObjectContext == nil{
            
            print("mbc is nil")
        }
        timer?.invalidate()
        if let thisRunning = NSEntityDescription.insertNewObjectForEntityForName("Run", inManagedObjectContext: self.managedObjectContext!) as? Run{
        //print("save distance: \(distance)")
        thisRunning.distance = distance
        thisRunning.duration = seconds
        thisRunning.timeStamp = NSDate()
        thisRunning.calories = calories
        
        var thisLocations = [Location]()
        for location in locations{
            
            let thisLocation = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: self.managedObjectContext!) as! Location
            thisLocation.latitude = location.coordinate.latitude
            thisLocation.longtitude = location.coordinate.longitude
            thisLocation.timeStamp = location.timestamp
            thisLocations.append(thisLocation)
        }
        
        thisRunning.locations = NSOrderedSet(array: thisLocations)
        run = thisRunning
        
        do{
            _ = try managedObjectContext!.save()
            print("save this run")
        }catch {
            print("Could not save the run!")
        }
        }
        performSegueWithIdentifier(self.segueIdn, sender: nil)
    }
    
   
    @IBAction func resumeRunning(sender: UIButton) {
        //print("resume btn")
        //timer?.fire()
        timer = NSTimer.scheduledTimerWithTimeInterval(timerDiff, target: self, selector: "startTrack:", userInfo: nil, repeats: true)
        timer = NSTimer.scheduledTimerWithTimeInterval(calTimerDiff, target: self, selector: "caloriesBurnCalculator:", userInfo: nil, repeats: true)
    }
    
    @IBAction func PauseRunning(sender: UIButton) {
        //print("pause btn")
        timer?.invalidate()
        calTimer?.invalidate()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueIdn{
            timer!.invalidate()
            let nav = segue.destinationViewController as! UINavigationController
            if let drVC = nav.topViewController as? DetailRunViewController {
                drVC.run = run
            }
        }
    }
    
    @IBAction func startRecording(sender: UIButton) {
        startLabel.hidden = true
        resumeLabel.hidden = false
        timer = NSTimer.scheduledTimerWithTimeInterval(timerDiff, target: self, selector: "startTrack:", userInfo: nil, repeats: true)
        calTimer = NSTimer.scheduledTimerWithTimeInterval(calTimerDiff, target: self, selector: "caloriesBurnCalculator:", userInfo: nil, repeats: true)
        startUpdateLocation()
        
    }
    
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// MARK: - MKMapViewDelegate
extension newRunViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
//        if !overlay.isKindOfClass(MKPolyline) {
//            return nil
//        }
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blueColor()
        //print("overlay: \(overlay)")
        renderer.lineWidth = 3
        return renderer
    }
}

// MARK: - CLLocationManagerDelegate
extension newRunViewController: CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
//        for location in locations{
//            if location.horizontalAccuracy < 20{
//                if self.locations.count > 0 {
//                    //print("location: \(location)")
//                    self.distance += location.distanceFromLocation(self.locations.last!)
//                }
//                self.locations.append(location)
//            }
//        }
        
        for location in locations {
            let howRecent = location.timestamp.timeIntervalSinceNow
            
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20{
                if self.locations.count > 0{
                    distance += location.distanceFromLocation(self.locations.last!)
                    
                    var coords = [CLLocationCoordinate2D]()
                    coords.append((self.locations.last?.coordinate)!)
                    coords.append(location.coordinate)
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
                    mapView.setRegion(region, animated: true)
                    mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
                }
                self.locations.append(location)
            }
            
        }
    }

    
}
