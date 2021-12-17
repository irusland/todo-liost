//
//  TodoItemDBModelExtensions.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 16.12.2021.
//

import Foundation
import UIKit

extension TodoItemDBModel {
    func fill(with todoItem: TodoItem) {
        self.id = todoItem.id
        self.changedAt = todoItem.changedAt
        self.color = todoItem.color
        self.createdAt = todoItem.createdAt
        self.deadLine = todoItem.deadLine
        self.priority = Int32(todoItem.priority.number)
        self.text = todoItem.text
    }
}


extension TodoItem {
    init?(from todoItem: TodoItemDBModel) {
        self.id = todoItem.id
        self.changedAt = todoItem.changedAt
        self.color = todoItem.color as? UIColor
        self.createdAt = todoItem.createdAt
        self.deadLine = todoItem.deadLine
        self.priority = TodoItemPriority.fromInt(Int(todoItem.priority))
        self.text = todoItem.text
    }
}
