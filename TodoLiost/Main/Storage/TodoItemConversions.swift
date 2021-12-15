//
//  TodoItemConversions.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 05.12.2021.
//

import Foundation
import UIKit

extension TodoItem {
    init(_ todoItemModel: TodoItemModel) {

        self.id = todoItemModel.id
        self.text = todoItemModel.text

        self.priority = TodoItemPriority(todoItemModel.importance)

        if let deadline = todoItemModel.deadline {
            self.deadLine = Date(timeIntervalSince1970: TimeInterval(integerLiteral: deadline))
        } else {
            self.deadLine = nil
        }

        if let color = todoItemModel.color {
            self.color = UIColor(hex: color)
        } else {
            self.color = nil
        }
        self.createdAt = Date(timeIntervalSince1970: TimeInterval(integerLiteral: todoItemModel.createdAt))
        self.changedAt = Date(timeIntervalSince1970: TimeInterval(integerLiteral: todoItemModel.changedAt))
    }
}
