//
//  TodoItem.swift
//  TodoList
//
//  Created by Ruslan Sirazhetdinov on 10.10.2021.
//

import Foundation
import UIKit

public enum TodoItemPriority: String {
    case no = "неважная"
    case normal = "обычная"
    case important = "важная"
}

public struct TodoItem : Equatable {
    let id: UUID
    let text: String
    let priority: TodoItemPriority
    let deadLine: Date?
    let color: UIColor?
    public init(id: UUID = UUID(), text: String, priority: TodoItemPriority = .normal, deadLine: Date? = nil, color: UIColor? = nil) {
        self.id = id
        self.text = text
        self.priority = priority
        self.deadLine = deadLine
        self.color = color
    }
}

public typealias TodoItemJson = [String: String]

private enum TodoItemParsingErrors: Error {
    case requiredFieldIsNotDefined(String)
}

public extension TodoItem{
    init(_ json: [String: Any]) throws {
        if let id = json["id"] as? String, let uid = UUID(uuidString: id) {
            self.id = uid
        } else {
            self.id = UUID()
        }
        guard let text = json["text"] as? String else {
            throw TodoItemParsingErrors.requiredFieldIsNotDefined("")
        }
        self.text = text

        if let jsonPriority = json["priority"] as? String, let priority = TodoItemPriority(rawValue: jsonPriority) {
            self.priority = priority
        } else {
            self.priority = .normal
        }

        self.deadLine = json["deadLine"] as? Date
        self.color = json["deadLine"] as? UIColor
        
        // почему тут не xcode ничего не говорит если не все поля заполнены? А в init структуры говорит
    }
    
    static func parse(json: [String: Any]) -> TodoItem? {
        do {
            return try TodoItem.init(json)
        } catch {
            return nil
        }
    }
    
    var json: TodoItemJson {
        var json: TodoItemJson = TodoItemJson()
        // todo json[\TodoItem.id]=...  (use keyPath https://stackoverflow.com/questions/26005654/get-a-swift-variables-actual-name-as-string)
        json["id"] = self.id.uuidString
        json["text"] = self.text
        if self.priority != .normal {
            json["priority"] = self.priority.rawValue
        }
        
        let encoder = JSONEncoder()
        if self.deadLine != nil {
            do {
                let jsonDeadLine = try encoder.encode(self.deadLine)
                if let deadLine = String(data: jsonDeadLine, encoding: .utf8) {
                    json["deadLine"] = deadLine
                }
            } catch {}
        }
        // json["color"] = self.color
        
        return json
    }
}
