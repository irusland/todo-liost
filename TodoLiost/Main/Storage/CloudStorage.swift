//
//  CloudStorage.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 21.11.2021.
//

import Foundation
import CocoaLumberjack
class CloudStorage: ItemStorage {
    private var connector: BackendConnector
    private var lastKnownRevision: Int32 = 0
    
    init(connector: BackendConnector) {
        self.connector = connector
    }
    
    private func convert(listModel: ListModel) -> [TodoItem] {
        var items: [TodoItem] = []
        for itemModel in listModel.list {
            items.append(
                TodoItem(itemModel)
            )
        }
        return items
    }

    func merge(with items: [TodoItem]) -> [TodoItem] {
        let itemModels = todoItems.map { item in
            TodoItemModel(from: item)
        }
        let model = MergeModel(list: itemModels)
        do {
            let listModel = try connector.merge(with: model)
            guard let model = listModel else {
                throw BackendErrors.dataIsEmpty("")
            }
            lastKnownRevision = model.revision
            return convert(listModel: model)
        } catch let error {
            DDLogError("Cloud storage got an error \(error)")
            return []
        }
    }
    
    var todoItems: [TodoItem] {
        get {
            do {
                let listModel = try connector.getList()
                guard let model = listModel else {
                    throw BackendErrors.dataIsEmpty("")
                }
                lastKnownRevision = model.revision
                return convert(listModel: model)
            } catch let error {
                DDLogError("Cloud storage got an error \(error)")
                return []
            }
        }
    }
    
    func add(_ todoItem: TodoItem) {
        let model = NewItemModel(element: TodoItemModel(from: todoItem))
        do {
            guard let result = try connector.add(todoItem: model, lastKnownRevision: lastKnownRevision) else {
                DDLogInfo("Empty result")
                return
            }
            
            lastKnownRevision = result.revision
            
        } catch {
            DDLogError(error)
        }
    }
    
    func update(at id: UUID, todoItem: TodoItem) -> Bool {
        let model = NewItemModel(element: TodoItemModel(from: todoItem))
        do {
            guard let result = try connector.update(at: id, todoItem: model, lastKnownRevision: lastKnownRevision) else {
                DDLogInfo("Empty result")
                return false
            }
            
            lastKnownRevision = result.revision
            return true
        } catch {
            DDLogError("Cloud storage got an error \(error)")
        }
        return false
    }
    
    func remove(by id: UUID) -> Bool {
        do {
            guard let result = try connector.remove(by: id, lastKnownRevision: lastKnownRevision) else {
                DDLogInfo("Empty result")
                return false
            }
            
            lastKnownRevision = result.revision
            return true
        } catch {
            DDLogError("Cloud storage got an error \(error)")
        }
        return false
    }
    
    func get(by id: UUID) -> TodoItem? {
        do {
            guard let result = try connector.get(by: id, lastKnownRevision: lastKnownRevision) else {
                DDLogInfo("Empty result")
                return nil
            }
            
            lastKnownRevision = result.revision
            return TodoItem(result.element)
        } catch {
            DDLogError("Cloud storage got an error \(error)")
        }
        return nil
    }
}
