//
//  DataController.swift
//  Swfitnotes
//
//  Created by John Lago on 1/18/17.
//  Copyright © 2017 John Lago. All rights reserved.
//


import UIKit
import CoreData

class DataController: NSObject {
    static let sharedInstance = DataController()
    var managedObjectContext: NSManagedObjectContext
    
    private override init() {
        guard let modelURL = Bundle.main.url(forResource: "Swiftnotes", withExtension: "momd") else {
            fatalError("Could not load model")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error inititalizing object model")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        let myQueue = DispatchQueue(label: "com.NoteQueue.john", qos: .background)
        myQueue.async {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL: URL = urls[urls.endIndex-1]
            let storeURL = docURL.appendingPathComponent("Swiftnotes.sqlite")
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil) }
            catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
}
