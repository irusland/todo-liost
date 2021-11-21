//
//  Storage.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 21.11.2021.
//

import Foundation
import CocoaLumberjack

protocol ItemStorage {
    var todoItems: [TodoItem] { get }
    func add(_ todoItem: TodoItem)
    func update(at id: UUID, todoItem: TodoItem) -> Bool
    func remove(by id: UUID) -> Bool
    func get(by id: UUID) -> TodoItem?
}

protocol ISyncStorage {
    func sync(notifierDelegate: NotifierDelegate)
}

class WebRequestOperation: AsyncOperation {
    var result: [TodoItem]?
    var cloudStorage: CloudStorage

    init(cloudStorage: CloudStorage) {
        self.cloudStorage = cloudStorage
    }

    override func main() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            self.result = self.cloudStorage.fetch()
            self.finish()
        }
    }
}

class UpdateCacheOperation: AsyncOperation {
    var newItems: [TodoItem]?
    var cache: FileCache

    init(cache: FileCache) {
        self.cache = cache
    }

    override func main() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            guard let items = self.newItems else { return }
            for item in items {
                if self.cache.update(at: item.id, todoItem: item) {
                    DDLogInfo("Item \(item.id) updated")
                } else {
                    self.cache.add(item)
                    DDLogInfo("Item \(item.id) added")
                }
            }
            self.finish()
        }
    }
}

class NotifyOperation: Operation {
    weak var notifierDelegate: NotifierDelegate
    init(notifierDelegate: NotifierDelegate) {
        self.notifierDelegate = notifierDelegate
    }
    override func main() {
        DDLogInfo("Items synced")
        notifierDelegate.operationFinished()
    }
}

@objc protocol NotifierDelegate {
    func operationFinished()
}

class PresistantStorage: FileCache, ISyncStorage {
    func sync(notifierDelegate: NotifierDelegate) {
        let webOp = WebRequestOperation(cloudStorage: cloudStorage)
        let updateOp = UpdateCacheOperation(cache: self)
        let transferOp = BlockOperation { [webOp, updateOp] in
            updateOp.newItems = webOp.result
        }
        let notifyOp = NotifyOperation(notifierDelegate: notifierDelegate)

        let opQueue = OperationQueue()
        opQueue.maxConcurrentOperationCount = 2

        transferOp.addDependency(webOp)
        updateOp.addDependency(transferOp)
        notifyOp.addDependency(updateOp)
        opQueue.addOperation(webOp)
        opQueue.addOperation(transferOp)
        opQueue.addOperation(updateOp)
        opQueue.addOperation(notifyOp)
        DDLogInfo("Syncing items started")
    }

    private var cloudStorage: CloudStorage

    init(cloudStorage: CloudStorage) {
        self.cloudStorage = cloudStorage
    }
}
