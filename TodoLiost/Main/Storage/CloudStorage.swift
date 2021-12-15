//
//  CloudStorage.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 21.11.2021.
//

import Foundation
import CocoaLumberjack
class CloudStorage: AsyncItemStorage {
    private var connector: BackendConnector
    private var lastKnownRevision: Int32 = 0
    private var deviceId: UUID

    init(connector: BackendConnector) {
        if let vendor = UIDevice.current.identifierForVendor {
            deviceId = UUID(uuid: vendor.uuid)
        }
        deviceId = UUID()
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

    func merge(with items: [TodoItem], handler: @escaping ([TodoItem]) -> ()) {
        let itemModels = items.map { item in
            TodoItemModel(from: item, by: deviceId)
        }
        let model = MergeModel(list: itemModels)
        connector.merge(with: model, handler: { model, errors in
            if let errors = errors {
                DDLogError("Cloud storage got an error \(errors)")
                handler([])
            }
            guard let model = model else {
                handler([])
                return
            }
            self.lastKnownRevision = model.revision
            handler(self.convert(listModel: model))
        })
    }

    func todoItems(returnItems: @escaping ([TodoItem]) -> ()) {
        connector.getList(handler: { model, errors in
            if let errors = errors {
                DDLogError("Cloud storage got an error \(errors)")
                returnItems([])
            }
            guard let model = model else {
                returnItems([])
                return
            }
            self.lastKnownRevision = model.revision
            returnItems(self.convert(listModel: model))
        })
    }

    func add(_ todoItem: TodoItem) {
        let model = NewItemModel(element: TodoItemModel(from: todoItem, by: deviceId))
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
        let model = NewItemModel(element: TodoItemModel(from: todoItem, by: deviceId))
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
