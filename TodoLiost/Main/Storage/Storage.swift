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
    func sync()
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
            self.result = self.cloudStorage.todoItems
            self.finish()
        }
    }
}

class UpdateCacheOperation: AsyncOperation {
    var newItems: [TodoItem]?
    var storage: ItemStorage

    init(storage: ItemStorage) {
        self.storage = storage
    }

    override func main() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let items = self.newItems else { return }
            for item in items {
                if self.storage.update(at: item.id, todoItem: item) {
                    DDLogInfo("Item \(item.id) updated")
                } else {
                    self.storage.add(item)
                    DDLogInfo("Item \(item.id) added")
                }
            }
            self.finish()
        }
    }
}

class NotifyOperation: Operation {
    weak var notifierDelegate: NotifierDelegate?
    init(notifierDelegate: NotifierDelegate) {
        self.notifierDelegate = notifierDelegate
    }
    override func main() {
        DDLogInfo("Items synced")
        notifierDelegate?.operationFinished()
    }
}

@objc protocol NotifierDelegate {
    func operationFinished()
}

class PresistantStorage: ItemStorage, ISyncStorage {
    var todoItems: [TodoItem] {
        get {
//            sync()
            return self.fileCache.todoItems
        }
    }
    
    func add(_ todoItem: TodoItem) {
        cloudStorage.add(todoItem)
        fileCache.add(todoItem)
    }
    
    func update(at id: UUID, todoItem: TodoItem) -> Bool {
        _ = cloudStorage.update(at: id, todoItem: todoItem)
        return fileCache.update(at: id, todoItem: todoItem)
    }
    
    func remove(by id: UUID) -> Bool {
        _ = cloudStorage.remove(by: id)
        return fileCache.remove(by: id)
    }
    
    func get(by id: UUID) -> TodoItem? {
        _ = cloudStorage.get(by: id)
        return fileCache.get(by: id)
    }
    
    func sync() {
        let webOp = WebRequestOperation(cloudStorage: cloudStorage)
        let updateOp = UpdateCacheOperation(storage: self.fileCache)
        let transferOp = BlockOperation { [webOp, updateOp] in
            updateOp.newItems = webOp.result
        }
        guard let notifier = notifierDelegate else {
            DDLogError("Notifier delegate was not set!")
            return
        }
        let notifyOp = NotifyOperation(notifierDelegate: notifier)

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
    private var fileCache: FileCache
    public var notifierDelegate: NotifierDelegate?

    init(fileCache: FileCache, cloudStorage: CloudStorage) {
        self.fileCache = fileCache
        self.cloudStorage = cloudStorage
    }
}
