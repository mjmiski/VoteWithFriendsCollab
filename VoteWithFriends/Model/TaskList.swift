//
//  TaskList.swift
//  RealmTasks
//
//  Created by Hossam Ghareeb on 10/13/15.
//  Copyright © 2015 Hossam Ghareeb. All rights reserved.
//

import RealmSwift


class TaskList: Object {
    
    dynamic var name = ""
    dynamic var fname = ""
    dynamic var lname = ""
    dynamic var phone = ""
   // dynamic var email = ""
    dynamic var fid = ""
    dynamic var voted = "x"
    dynamic var createdAt = NSDate()
    let tasks = List<Task>()
    
    func primaryKey() -> String {
        return fid
    }
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
