//
//  CoreDataMock.swift
//  HGCAppTests
//
//  Created by Surendra  on 20/05/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import Foundation
import CoreData
@testable import HGCApp

class MockCoreDataManager : CoreDataManagerProtocol {
    @available(iOS 10.0, *)
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "hgc")
        let desc = NSPersistentStoreDescription.init()
        desc.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [desc]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        var managedObjectContext = persistentContainer.viewContext
        return managedObjectContext
    }()
    
    func saveContext () {
        let context = mainContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createNewBackgroundContext() -> NSManagedObjectContext {
        let backgroundContext = persistentContainer.newBackgroundContext()
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidSave), name: NSNotification.Name.NSManagedObjectContextDidSave, object: backgroundContext)
        return backgroundContext
    }
    
    @objc func managedObjectContextObjectsDidSave(notification: Notification) {
        self.mainContext.perform {
            self.mainContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func saveBackgroundContext(_ bgContext:NSManagedObjectContext) {
        do {
            try bgContext.save()
        }
        catch {
            print("Error: \(error)\nCould not save background Core Data context.")
            return
        }
        bgContext.reset()
    }
}
