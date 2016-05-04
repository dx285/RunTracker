//
//  Location.swift
//  RunTracker
//
//  Created by Di on 2/5/16.
//  Copyright © 2016 Di. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject{
    
    @NSManaged var longtitude: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var timeStamp: NSDate
    
}