//
//  FileCache.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 17.10.2021.
//

import Foundation


typealias DataFile = [String: Any]


private enum FileCacheErrors: Error {
    case dumpError(String)
}


class FileCache {
    private(set) var todoItems: [TodoItem]
    private let itemKey: String = "items"
    
    public init(todoItems: [TodoItem] = []) {
        self.todoItems = todoItems
    }
    
    public func add(_ todoItem: TodoItem) {
        if self.todoItems.contains(where: { item in
            item.id == todoItem.id
        }) {
            return
        }
        self.todoItems.append(todoItem)
    }
    
    private func getIndex(by id: UUID) -> Int? {
        return self.todoItems.firstIndex(where: { $0.id == id })
    }
    
    public func remove(by id: UUID) -> Bool {
        guard let itemIndex = getIndex(by: id) else {
            return false
        }
        self.todoItems.remove(at: itemIndex)
        return true
    }
    
    public func get(by id: UUID) -> TodoItem? {
        return self.todoItems.first(where: { $0.id == id })
    }
    
    public func save(to file: String) -> Bool {
        guard let dir = FileManager.default.urls(for: .documentDirectory /* maybe cachesDirectory */, in: .userDomainMask).first else {
            return false
        }
        let fileURL = dir.appendingPathComponent(file)
        do {
            let jsonString = try dumps()
            try jsonString.write(to: fileURL, atomically: false, encoding: .utf8)
        } catch let error as NSError {
            print("Failed: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    public func dump() -> DataFile {
        let jsonItems = self.todoItems.map{$0.json}
        let jsonData: DataFile = [
            self.itemKey: jsonItems
        ]
        return jsonData
    }
    
    public func dumps() throws -> String {
        let jsonObject = dump()
        let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        guard let string = String(data: data, encoding: String.Encoding.utf8) else {
            throw FileCacheErrors.dumpError("Dumped data is nil")
        }
        return string
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
                    self.todoItems.append(todoItem)
                }
            }
            
        } catch let error as NSError {
            print("Failed: \(error.localizedDescription)")
            return false
        }
        return true
    }
}
