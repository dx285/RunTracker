//
//  DetailRunViewController.swift
//  RunTracker
//
//  Created by Di on 2/8/16.
//  Copyright © 2016 Di. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import HealthKit

class DetailRunViewController: UIViewController {

    var run: Run!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var achievementLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
    }
    
    
    func configView(){
        
        let distance = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: run.distance.doubleValue)
        distanceLabel.text = "Distance: " + distance.description
        
        let time = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: run.duration.doubleValue)
        timeLabel.text = "Time: " + time.description
        
        let speedUnit = HKUnit.meterUnit().unitDividedByUnit(HKUnit.secondUnit())
        let speed = HKQuantity(unit: speedUnit, doubleValue: (run.distance.doubleValue/run.duration.doubleValue))
        speedLabel.text = "Speed: " + speed.description
        
        let calories = HKQuantity(unit: HKUnit.calorieUnit(), doubleValue: run.calories.doubleValue)
        caloriesLabel.text = "Calories: " + calories.description
        loadMap()
    }
    
    func mapConfig() -> MKCoordinateRegion {
        
        var minLat = (run.locations.firstObject as! Location).latitude.doubleValue
        var minLng = (run.locations.firstObject as! Location).longtitude.doubleValue
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = run.locations.array as! [Location]
        
        for location in locations{
            
            minLat = min(minLat, location.latitude.doubleValue)
            minLng = min(minLng, location.longtitude.doubleValue)
            maxLat = max(minLat, location.latitude.doubleValue)
            maxLng = max(minLng, location.longtitude.doubleValue)
            
        }
        
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2, longitude: (minLng + maxLng)/2), span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1, longitudeDelta: (maxLng - minLng)*1.1))
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MKPolyline){
            return nil
        }
        
        let polyLine = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyLine)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3
        return renderer
    }
    
    
    func polyline() -> MKPolyline {
        
        var coords = [CLLocationCoordinate2D]()
        
        let locations = run.locations.array as! [Location]
        for location in locations{
            coords.append(CLLocationCoordinate2D(latitude: location.latitude.doubleValue , longitude: location.longtitude.doubleValue))
        }
        return MKPolyline(coordinates: &coords, count: run.locations.count)
    }
    
    func loadMap() {
        
        if run.locations.count > 0 {
            mapView.hidden = false
            
            mapView.region = mapConfig()
            
            mapView.addOverlay(polyline())
            
        }else{
            mapView.hidden = true
            UIAlertView(title: "no locations saved", message: " ", delegate: nil, cancelButtonTitle: "OK").show()
        }
        
    }
    
    
    @IBAction func backToRoot(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
        //self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    @IBAction func backToHistory(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
}
