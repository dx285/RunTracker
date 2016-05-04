//
//  Achievement.swift
//  RunTracker
//
//  Created by Di on 2/9/16.
//  Copyright © 2016 Di. All rights reserved.
//

import Foundation

class Achievement{
    
    let title: String!
    let distance: Double!
    let info: String!
    let image: String!
    
    init(json: [String: String]){
        
        title = json["title"]
        distance = (json["distance"]! as NSString).doubleValue
        info = json["info"]
        image = json["image"]
    }
}

class AchieveController{
    
    lazy var achieveArray : [Achievement] = {
    
        var _achieveArray = [Achievement]()
        
        let filePath = NSBundle.mainBundle().pathForResource("Achievements", ofType: "json")
        let data = NSData.dataWithContentsOfMappedFile(filePath!) as! NSData
        
        var error: NSError
        
        do{
        
            var achieves = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! [Dictionary<String, String>]
            
            for achieve in achieves{
                
                _achieveArray.append(Achievement(json: achieve))
            }
            
        }catch _{
            
        }
        return _achieveArray
    }()
}