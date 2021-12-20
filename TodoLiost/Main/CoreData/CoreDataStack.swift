//
//  CoreDataStack.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 17.12.2021.
//

import Foundation
import CoreData
class CoreDataStack {
    private var modelName: String = "TodoItemDBModel"
    private var filename: String = "DataModel.sql"

    lazy var context: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(
            concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.automaticallyMergesChangesFromParent = true
        managedObjectContext.persistentStoreCoordinator = self.psc
        return managedObjectContext
    }()

    lazy var psc: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(
            managedObjectModel: self.managedObjectModel)

        let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let fileURL = URL(string: self.filename, relativeTo: dirURL)
        do {
            let options =
                [NSMigratePersistentStoresAutomaticallyOption: true]

            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                       configurationName: nil,
                                       at: fileURL, options: nil)
        } catch {
            fatalError("Error configuring persistent store: \(error)")
        }
        return coordinator
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName,
                                             withExtension: "momd") else {
            fatalError("Failed to find data model")
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }

        return mom
    }()

    func commit () {
        if context.hasChanges {
            context.performAndWait {
                do {
                    try self.context.save()
                } catch let error as NSError {
                    print("Error on commit: \(error.localizedDescription)")
                    abort()
                }
            }
        }
    }
}
