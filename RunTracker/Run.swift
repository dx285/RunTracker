//
//  Run.swift
//  RunTracker
//
//  Created by Di on 2/5/16.
//  Copyright © 2016 Di. All rights reserved.
//

import Foundation
import CoreData

class Run: NSManagedObject{
    
    @NSManaged var timeStamp: NSDate
    @NSManaged var duration: NSNumber
    @NSManaged var distance: NSNumber
    @NSManaged var calories: NSNumber
    @NSManaged var locations: NSOrderedSet
    
}