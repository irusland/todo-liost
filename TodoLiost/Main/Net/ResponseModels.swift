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
            createdAt: todoItem.createdAt.unixTimestamp,
            changedAt: todoItem.changedAt.unixTimestamp,
            lastUpdatedBy: UUID.init() // todo UUID(uuid: UIDevice.current.identifierForVendor!.uuid)
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
