//
//  ResponseModels.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 28.11.2021.
//

import Foundation

enum TodoItemPriorityModel: String, Decodable {
    case low
    case basic
    case important
}

struct TodoItemModel: Decodable {
    let id: UUID
    let text: String
    let importance: TodoItemPriorityModel
    let deadline: Int64?
    let done: Bool
    let color: String?
    let createdAt: Int64
    let changedAt: Int64
    let lastUpdatedBy: Int
}

struct ListModel: Decodable {
    let status: String
    let list: [TodoItemModel]
    let revision: Int32
}

