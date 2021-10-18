//
//  TodoItem.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 17.10.2021.
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

public typealias TodoItemJson = [String: Any]

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
            throw TodoItemParsingErrors.requiredFieldIsNotDefined("key: text")
        }
        self.text = text

        if let jsonPriority = json["priority"] as? String, let priority = TodoItemPriority(rawValue: jsonPriority) {
            self.priority = priority
        } else {
            self.priority = .normal
        }

        self.deadLine = nil

        if let color = json["color"] as? String {
            self.color = UIColor(ciColor: CIColor(string: color))
        } else {
            self.color = nil
        }
    }
    
    static func parse(json: [String: Any]) -> TodoItem? {
        do {
            return try TodoItem(json)
        } catch {
            return nil
        }
    }
    
    var json: TodoItemJson {
        var json: TodoItemJson = TodoItemJson()
        // todo json[\TodoItem.id]=...  (use keyPath https://stackoverflow.com/questions/26005654/get-a-swift-variables-actual-name-as-string)
        json["id"] = id.uuidString
        json["text"] = text
        if priority != .normal {
            json["priority"] = priority.rawValue
        }
        
        let encoder = JSONEncoder()
        if deadLine != nil {
            do {
                let jsonDeadLine = try encoder.encode(self.deadLine)
                if let deadLine = String(data: jsonDeadLine, encoding: .utf8) {
                    json["deadLine"] = deadLine
                }
            } catch {}
        }
        if color != nil {
            json["color"] = CIColor(color: color!).stringRepresentation
        }
        return json
    }
}
