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

    func merge(with items: [TodoItem], handler: @escaping ([TodoItem]) -> Void) {
        let itemModels = items.map { item in
            TodoItemModel(from: item, by: deviceId)
        }
        let model = MergeModel(list: itemModels)
        connector.merge(with: model, handler: { result in
            switch result {
            case .failure(let error):
                DDLogError("Cloud storage got an error \(error)")
                handler([])
                return
            case .success(let model):
                self.lastKnownRevision = model.revision
                handler(self.convert(listModel: model))
            }
        })
    }

    func todoItems(returnItems: @escaping ([TodoItem]) -> Void) {
        connector.getList(handler: { result in
            switch result {
            case .failure(let error):
                DDLogError("Cloud storage got an error \(error)")
                returnItems([])
                return
            case .success(let model):
                self.lastKnownRevision = model.revision
                returnItems(self.convert(listModel: model))
            }
        })
    }

    func add(_ todoItem: TodoItem, handler: @escaping () -> Void) {
        let model = NewItemModel(element: TodoItemModel(from: todoItem, by: deviceId))

        connector.add(todoItem: model, lastKnownRevision: lastKnownRevision, handler: { result in
            switch result {
            case .failure(let error):
                DDLogError("Cloud storage got an error \(error)")
                handler()
                return
            case .success(let model):
                self.lastKnownRevision = model.revision
                handler()
            }
        })
    }

    func update(at id: UUID, todoItem: TodoItem, handler: @escaping (Bool) -> Void) {
        let model = NewItemModel(element: TodoItemModel(from: todoItem, by: deviceId))

        connector.update(at: id, todoItem: model, lastKnownRevision: lastKnownRevision, handler: { result in
            switch result {
            case .failure(let error):
                DDLogError("Cloud storage got an error \(error)")
                handler(false)
                return
            case .success(let model):
                self.lastKnownRevision = model.revision
                handler(true)
            }
        })
    }

    func remove(by id: UUID, handler: @escaping (Bool) -> Void) {
        connector.remove(by: id, lastKnownRevision: lastKnownRevision, handler: { result in
            switch result {
            case .failure(let error):
                DDLogError("Cloud storage got an error \(error)")
                handler(false)
                return
            case .success(let model):
                self.lastKnownRevision = model.revision
                handler(true)
            }
        })
    }

    func get(by id: UUID, handler: @escaping (TodoItem?) -> Void) {
        connector.get(by: id, lastKnownRevision: lastKnownRevision, handler: { result in
            switch result {
            case .failure(let error):
                DDLogError("Cloud storage got an error \(error)")
                handler(nil)
                return
            case .success(let model):
                self.lastKnownRevision = model.revision
                handler(TodoItem(model.element))
            }
        })
    }
}
