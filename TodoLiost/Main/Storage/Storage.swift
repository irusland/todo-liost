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
    func flush()
}

protocol AsyncItemStorage {
    func todoItems(returnItems: @escaping ([TodoItem]) -> Void)
    func add(_ todoItem: TodoItem, handler: @escaping () -> Void)
    func update(at id: UUID, todoItem: TodoItem, handler: @escaping (Bool) -> Void)
    func remove(by id: UUID, handler: @escaping (Bool) -> Void)
    func get(by id: UUID, handler: @escaping (TodoItem?) -> Void)
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
        self.cloudStorage.todoItems { items in
            self.result = items
            self.finish()
        }
    }
}

class AwaitingOperation<T>: AsyncOperation {
    var result: T?
    var callable: (@escaping (T) -> Void) -> Void

    init(callable: @escaping (@escaping (T) -> Void) -> Void) {
        self.callable = callable
    }

    override func main() {
        callable({ items in
            self.result = items
            self.finish()
        })
    }
}

class UpdateCacheOperation: AsyncOperation {
    var newItems: [TodoItem]?
    var storage: ItemStorage

    init(storage: ItemStorage) {
        self.storage = storage
    }

    override func main() {
        guard let items = self.newItems else { return }
        self.storage.flush()
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

class AlertOperation: Operation {
    var alert: UIAlertController
    weak var notifierDelegate: NotifierDelegate?

    init(notifierDelegate: NotifierDelegate, message: String, actions: [(String, (UIAlertAction) -> Void)]) {
        self.notifierDelegate = notifierDelegate
        self.alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        for (title, action) in actions {
            alert.addAction(UIAlertAction(title: title, style: .default, handler: action))
        }
    }

    override func main() {
        DispatchQueue.main.async {
            DDLogInfo("Sending error to UI")
            self.notifierDelegate?.errorOcurred(alertController: self.alert)
        }
    }
}

@objc protocol NotifierDelegate {
    func operationFinished()
    func errorOcurred(alertController: UIAlertController)
    func sync()
}

class ExecutionOperation<T>: BlockOperation {
    var callable: () -> T
    var result: T?

    init(callable: @escaping () -> T) {
        self.callable = callable
    }

    override func main() {
        self.result = self.callable()
    }
}

class ComparisonOperation<T: Equatable>: Operation {
    var expected: T
    var actual: T?
    var isEqual: Bool?

    init(expected: T) {
        self.expected = expected
    }

    override func main() {
        guard let actual = self.actual else { return }
        self.isEqual = self.expected == actual
    }
}

class PersistentStorage: ItemStorage, ISyncStorage {
    func flush() {
        self.fileCache.flush()
    }

    var todoItems: [TodoItem] {
        get {
            withSyncronization(fromLocal: {
                return self.fileCache.todoItems
            }, fromNetwork: self.cloudStorage.todoItems)
        }
    }

    private func withConsistancy(fromLocal: () -> Void, fromNetwork: @escaping () -> Void) {
        withSyncronization { () -> Bool in
            fromLocal()
            return true
        } fromNetwork: {
            fromNetwork()
            return true
        }
    }

    private func inconsistantError() {
        let actions: [(String, (UIAlertAction) -> Void)] = [
            ("Cancel", { (_: UIAlertAction!) in
                DDLogWarn("User canceled sync")
            }),
            ("Sync", { (_: UIAlertAction!) in
                self.notifierDelegate?.sync()
            })
        ]
        displayError(message: "Server sync needed", actions: actions)
    }

    private func displayError(message: String, actions: [(String, (UIAlertAction) -> Void)] = []) {
        guard let notifier = notifierDelegate else {
            DDLogError("Notifier delegate was not set!")
            return
        }
        let alertOp = AlertOperation(notifierDelegate: notifier, message: message, actions: actions)

        opQueue.addOperation(alertOp)
    }

    private func logResults<T>(localResult: T, netResult: T?) {
        if let result = netResult {
            DDLogInfo("\nLocal expected:\n\(localResult)\nNet actual:\n\(result)")
        } else {
            DDLogInfo("\nLocal expected:\n\(localResult)\nNet actual:\nnil")
        }
    }

    private func withSyncronization<T: Equatable>(fromLocal: () -> T, fromNetwork: @escaping () -> T) -> T {
        let localResult = fromLocal()
        DDLogInfo("Consistant operation got from local")

        let asyncOp = ExecutionOperation(callable: fromNetwork)
        let validateOp = ComparisonOperation(expected: localResult)
        let transferOp = BlockOperation { [asyncOp, validateOp] in
            validateOp.actual = asyncOp.result
        }
        let needSyncOp = BlockOperation { [validateOp, asyncOp, weak self] in
            guard let self = self else { return }
            guard let isEqual = validateOp.isEqual else {
                DDLogError("Validation of consistency did not set isEquals")
                return
            }
            self.logResults(localResult: localResult, netResult: asyncOp.result)
            if isEqual {
                DDLogInfo("Validation of consistency succeded")
            } else {
                DDLogError("Validation of consistency failed, sync needed")
                self.inconsistantError()
            }
        }

        transferOp.addDependency(asyncOp)
        validateOp.addDependency(transferOp)
        needSyncOp.addDependency(validateOp)

        opQueue.addOperation(asyncOp)
        opQueue.addOperation(transferOp)
        opQueue.addOperation(validateOp)
        opQueue.addOperation(needSyncOp)

        DDLogInfo("Consistant operation started")
        return localResult
    }

    private func withSyncronization<T: Equatable>(fromLocal: () -> T, fromNetwork: @escaping (@escaping (T) -> Void) -> Void) -> T {
        let localResult = fromLocal()
        DDLogInfo("Consistant operation got from local")
        let asyncOp = AwaitingOperation(callable: fromNetwork)
        let validateOp = ComparisonOperation(expected: localResult)
        let transferOp = BlockOperation { [asyncOp, validateOp] in
            validateOp.actual = asyncOp.result
        }
        let needSyncOp = BlockOperation { [validateOp, asyncOp, weak self] in
            guard let self = self else { return }
            guard let isEqual = validateOp.isEqual else {
                DDLogError("Validation of consistency did not set isEquals")
                return
            }
            self.logResults(localResult: localResult, netResult: asyncOp.result)
            if isEqual {
                DDLogInfo("Validation of consistency succeded")
            } else {
                DDLogError("Validation of consistency failed, sync needed")
                self.inconsistantError()
            }
        }

        transferOp.addDependency(asyncOp)
        validateOp.addDependency(transferOp)
        needSyncOp.addDependency(validateOp)

        opQueue.addOperation(asyncOp)
        opQueue.addOperation(transferOp)
        opQueue.addOperation(validateOp)
        opQueue.addOperation(needSyncOp)

        DDLogInfo("Consistant operation started")
        return localResult
    }

    func add(_ todoItem: TodoItem) {
        fileCache.add(todoItem)
        self.cloudStorage.add(todoItem) {}
    }

    func update(at id: UUID, todoItem: TodoItem) -> Bool {
        return withSyncronization {
            return fileCache.update(at: id, todoItem: todoItem)
        } fromNetwork: { handler in
            return self.cloudStorage.update(at: id, todoItem: todoItem, handler: handler)
        }
    }

    func remove(by id: UUID) -> Bool {
        return withSyncronization {
            return fileCache.remove(by: id)
        } fromNetwork: { handler in
            return self.cloudStorage.remove(by: id, handler: handler)
        }

    }

    func get(by id: UUID) -> TodoItem? {
        return withSyncronization {
            return fileCache.get(by: id)
        } fromNetwork: { handler in
            return self.cloudStorage.get(by: id, handler: handler)
        }
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
    public weak var notifierDelegate: NotifierDelegate?
    private var opQueue: OperationQueue

    init(fileCache: FileCache, cloudStorage: CloudStorage) {
        self.fileCache = fileCache
        self.cloudStorage = cloudStorage

        self.opQueue = OperationQueue()
        opQueue.maxConcurrentOperationCount = 2
    }
}
