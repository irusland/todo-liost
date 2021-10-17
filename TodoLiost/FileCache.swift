//
//  FileCache.swift
//  TodoList
//
//  Created by Ruslan Sirazhetdinov on 10.10.2021.
//

import Foundation


// todo use as settings file content protocol
struct _DataFile : Equatable, Codable {
    let items: [TodoItemJson]
}
typealias DataFile = [String: Any]

class FileCache {
    private(set) var todoItems: [TodoItem]
    private let itemKey: String = "items"
    
    public init(todoItems: [TodoItem] = []) {
        self.todoItems = todoItems
    }
    
    public func add(_ todoItem: TodoItem) {
        self.todoItems.append(todoItem)
    }
    
    private func getIndex(by id: UUID) -> Int? {
        guard let itemIndex = self.todoItems.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        return itemIndex
    }
    
    public func remove(by id: UUID) -> Bool {
        guard let itemIndex = getIndex(by: id) else {
            return false
        }
        self.todoItems.remove(at: itemIndex)
        return true
    }
    
    public func get(by id: UUID) -> TodoItem? {
        guard let itemIndex = self.todoItems.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        return self.todoItems[itemIndex]
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
        return String(data: data, encoding: String.Encoding.utf8)! // вот тут как без ! по компактнее бросать эксепшон?
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
