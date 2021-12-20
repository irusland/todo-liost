//
//  FileCache.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 17.10.2021.
//

import Foundation
import CocoaLumberjack

typealias DataFile = [String: Any]

private enum FileCacheErrors: Error {
    case dumpError(String)
}

class FileCache: ItemStorage {
    private let itemKey: String = "items"
    private let coreDataStorage: CoreDataStorage

    init(coreDataStorage: CoreDataStorage) {
        self.coreDataStorage = coreDataStorage
        self._todoItems = []
        coreDataStorage.todoItems { DBItems in
            DDLogInfo("Current items in DB:\n\(DBItems)\nIn mem:\n\(self._todoItems)")
            self._todoItems = DBItems
        }
    }
    private var _todoItems: [TodoItem]
    public var todoItems: [TodoItem] {
        get {
            return _todoItems
        }
    }

    func flush() {
        coreDataStorage.flush()
        _todoItems = []
    }

    public func add(_ todoItem: TodoItem) {
        coreDataStorage.get(by: todoItem.id) { item in
            if item != nil {
                return
            } else {
                self.coreDataStorage.add(todoItem) {
                    DDLogInfo("Item Added to DB")
                }
            }
        }

        if self._todoItems.contains(where: { item in
            item.id == todoItem.id
        }) {
            return
        }
        self._todoItems.append(todoItem)
    }

    public func update(at id: UUID, todoItem: TodoItem) -> Bool {
        coreDataStorage.update(at: id, todoItem: todoItem) { wasSuccessful in
            DDLogInfo("Update in DB finished with \(wasSuccessful ? "success" : "fail")")
        }
        guard let itemIndex = getIndex(by: id) else {
            return false
        }
        self._todoItems.remove(at: itemIndex)
        self._todoItems.insert(todoItem, at: itemIndex)
        return true
    }

    private func getIndex(by id: UUID) -> Int? {
        return self.todoItems.firstIndex(where: { $0.id == id })
    }

    public func remove(by id: UUID) -> Bool {
        coreDataStorage.remove(by: id) { wasSuccessful in
            DDLogInfo("Delete in DB finished with \(wasSuccessful ? "success" : "fail")")
        }
        guard let itemIndex = getIndex(by: id) else {
            return false
        }
        self._todoItems.remove(at: itemIndex)
        return true
    }

    public func get(by id: UUID) -> TodoItem? {
        coreDataStorage.get(by: id) { todoItem in
            DDLogInfo("Item from DB: \(todoItem)")
        }
        return self.todoItems.first(where: { $0.id == id })
    }

    public func save(to file: String) -> Bool {
        guard let dir = FileManager.default.urls(for: .documentDirectory /* maybe cachesDirectory */, in: .userDomainMask).first else {
            return false
        }
        let fileURL = dir.appendingPathComponent(file)
        do {
            let data = try dumps()
            try data.write(to: fileURL)
        } catch let error as NSError {
            print("Failed: \(error.localizedDescription)")
            return false
        }
        return true
    }

    public func dump() -> DataFile {
        let jsonItems = self.todoItems.map {$0.json}
        let jsonData: DataFile = [
            self.itemKey: jsonItems
        ]
        return jsonData
    }

    public func dumps() throws -> Data {
        let jsonObject = dump()
        let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        return data
    }

    public func load(from file: String) -> Bool {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        let fileURL = dir.appendingPathComponent(file)

        do {
            let str = try String(contentsOf: fileURL, encoding: .utf8)
            let data = Data(str.utf8)

            guard let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return false
            }
            guard let rawTodoItems = jsonDict[self.itemKey] as? [[String: Any]] else {
                return false
            }
            for rawTodoItem in rawTodoItems {
                if let todoItem = TodoItem.parse(json: rawTodoItem) {
                    self._todoItems.append(todoItem)
                }
            }

        } catch let error as NSError {
            print("Failed: \(error.localizedDescription)")
            return false
        }
        return true
    }
}
