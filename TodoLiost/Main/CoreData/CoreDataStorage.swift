//
//  CoreDataStorage.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 16.12.2021.
//

import Foundation
import CoreData
import CocoaLumberjack

class CoreDataStorage: AsyncItemStorage {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func flush() {
        coreDataStack.context.perform { [self] in
            let fetchRequest: NSFetchRequest<TodoItemDBModel> = TodoItemDBModel.fetchRequest()
            do {
                for object in try self.coreDataStack.context.fetch(fetchRequest) {
                    DDLogInfo("DELETING \(object)")
                    self.coreDataStack.context.delete(object)
                }
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func todoItems(returnItems: @escaping ([TodoItem]) -> Void) {
        coreDataStack.context.perform {
            let fetchRequest: NSFetchRequest<TodoItemDBModel> = TodoItemDBModel.fetchRequest()
            do {
                let objects = try self.coreDataStack.context.fetch(fetchRequest)
                DDLogInfo("Got objects from DB \(objects)")
                returnItems(objects.map({ modelDB in
                    guard let item = TodoItem.init(from: modelDB) else {
                        fatalError("Cannot map DB item \(modelDB) from \(objects)")
                    }
                    return item
                }))
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func add(_ todoItem: TodoItem, handler: @escaping () -> Void) {
        coreDataStack.context.perform {
            let person = TodoItemDBModel(context: self.coreDataStack.context)
            person.fill(with: todoItem)
            self.coreDataStack.commit()
            DDLogInfo("DB item added \(todoItem)")
            handler()
        }
    }
    
    func update(at id: UUID, todoItem: TodoItem, handler: @escaping (Bool) -> Void) {
        coreDataStack.context.perform {
            let fetchRequest: NSFetchRequest<TodoItemDBModel> = TodoItemDBModel.fetchRequest()
            fetchRequest.predicate = NSComparisonPredicate(
                format: "id == %@", id.uuidString
            )
            do {
                let objects = try self.coreDataStack.context.fetch(fetchRequest)
                guard objects.count == 1, let item = objects.first else {
                    DDLogInfo("By id \(id) expected one but found \(objects.count) objects\n\(objects.map({item in return TodoItem(from: item)}))")
                    handler(false)
                    return
                }
                DDLogInfo("Got object from DB \(item)")
                item.fill(with: todoItem)
                self.coreDataStack.commit()
                handler(true)
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func remove(by id: UUID, handler: @escaping (Bool) -> Void) {
        coreDataStack.context.perform {
            let fetchRequest: NSFetchRequest<TodoItemDBModel> = TodoItemDBModel.fetchRequest()
            fetchRequest.predicate = NSComparisonPredicate(
                format: "id == %@", id.uuidString
            )
            do {
                let objects = try self.coreDataStack.context.fetch(fetchRequest)
                guard objects.count == 1, let item = objects.first else {
                    DDLogInfo("By id \(id) expected one but found \(objects.count) objects\n\(objects.map({item in return TodoItem(from: item)}))")
                    handler(false)
                    return
                }
                DDLogInfo("Got object from DB \(item)")
                self.coreDataStack.context.delete(item)
                handler(true)
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func get(by id: UUID, handler: @escaping (TodoItem?) -> Void) {
        coreDataStack.context.perform {
            let fetchRequest: NSFetchRequest<TodoItemDBModel> = TodoItemDBModel.fetchRequest()
            fetchRequest.predicate = NSComparisonPredicate(
                format: "id == %@", id.uuidString
            )
            do {
                let objects = try self.coreDataStack.context.fetch(fetchRequest)
                guard objects.count == 1, let item = objects.first else {
                    DDLogInfo("By id \(id) expected one but found \(objects.count) objects\n\(objects.map({item in return TodoItem(from: item)}))")
                    handler(nil)
                    return
                }
                
                let todoItem = TodoItem(from: item)
                DDLogInfo("Got object from DB \(item) = \(String(describing: todoItem))")
                handler(todoItem)
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
