//
//  CoreDataContext.swift
//  StarEvents
//
//  Created by Liam Butler-Lawrence on 11/15/16.
//  Copyright © 2016 Liam Butler-Lawrence. All rights reserved.
//

import CoreData

struct CoreDataContext {

    static let shared: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        
        return context
    }()
    
    private static let persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            let documentsDirectoryURL = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            
            let persistentStoreFileName = "CoreDataStore.sqlite"
            let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(persistentStoreFileName)
            
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: persistentStoreURL
            )
            
            return coordinator
        } catch {
            fatalError("Could not initialize persistent store coordinator for Core Data")
        }
    }()
    
    private static let managedObjectModel: NSManagedObjectModel = {
        let modelFileName = "Model"
        let modelFileExtension = "momd"
        
        guard
            let modelURL = Bundle.main.url(forResource: modelFileName, withExtension: modelFileExtension),
            let model = NSManagedObjectModel(contentsOf: modelURL)
            else { fatalError("Could not retrieve Core Data model named \(modelFileName).\(modelFileExtension)") }
        
        return model
    }()
}

extension NSEntityDescription {
    
    static func insertNewTypedObject<T: NSManagedObject>(into context: NSManagedObjectContext) -> T {
        guard let newObject = insertNewObject(forEntityName: String(describing: T.self), into: context) as? T
            else { fatalError("Could not add Core Data object of type \(String(describing: T.self))") }
        
        return newObject
    }
}
