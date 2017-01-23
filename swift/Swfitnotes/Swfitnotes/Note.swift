//
//  Note.swift
//  Swfitnotes
//
//  Created by John Lago on 1/18/17.
//  Copyright © 2017 John Lago. All rights reserved.
//

import CoreData
import UIKit

class Note: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var body: String
    @NSManaged var date: Date
    @NSManaged var starred: Bool
    @NSManaged var id: String
    @NSManaged var color: UIColor
    
     static func fetchRequest<Note>() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }
}
