//
//  ResponseModels.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 28.11.2021.
//

import Foundation
import UIKit
import CocoaLumberjack

enum TodoItemPriorityModel: String, Codable {
    case low
    case basic
    case important
}

extension TodoItemPriority {
    init(_ todoItemPriorityModel: TodoItemPriorityModel) {
        switch todoItemPriorityModel {
        case .low:
            self = .no
        case .basic:
            self = .normal
        case .important:
            self = .important
        }
    }
}
extension TodoItemPriorityModel {
    init(_ todoItemPriority: TodoItemPriority) {
        switch todoItemPriority {
        case .no:
            self = .low
        case .normal:
            self = .basic
        case .important:
            self = .important
        }
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}

struct TodoItemModel: Codable {
    let id: UUID
    let text: String
    let importance: TodoItemPriorityModel
    let deadline: Int64?
    let done: Bool
    let color: String?
    let createdAt: Int64
    let changedAt: Int64
    let lastUpdatedBy: UUID
}

extension TodoItemModel {
    init(from todoItem: TodoItem) {

        self.init(
            id: todoItem.id,
            text: todoItem.text,
            importance: TodoItemPriorityModel(todoItem.priority),
            deadline: todoItem.deadLine?.unixTimestamp,
            done: false,
            color: todoItem.color?.hexString,
            createdAt: Date().unixTimestamp,
            changedAt: Date().unixTimestamp,
            lastUpdatedBy: UUID.init()
        )
    }
}

struct ListModel: Codable {
    let status: String
    let list: [TodoItemModel]
    let revision: Int32
}

struct MergeModel: Codable {
    let list: [TodoItemModel]
}

struct NewItemModel: Codable {
    let element: TodoItemModel
}

struct NewItemResponse: Codable {
    let status: String
    let element: TodoItemModel
    let revision: Int32
}
