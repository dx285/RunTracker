//
//  MedalTableViewController.swift
//  RunTracker
//
//  Created by Di on 2/5/16.
//  Copyright © 2016 Di. All rights reserved.
//

import UIKit

class AchievementsTableViewController: UITableViewController {
    
    var achieveController = AchieveController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return achieveController.achieveArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("achieveCell") as! AchievementsCell
        
        let achievementCell = achieveController.achieveArray[indexPath.row]
        
        cell.titleLabel.text = achievementCell.title
        cell.imageView?.image = UIImage(named: achievementCell.image)
        cell.distanceLabel.text = "Distance: " + achievementCell.distance.description
        //cell.infoLabel.text = achievementCell.info
        
        return cell
    }
    
    @IBAction func backToHome(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
