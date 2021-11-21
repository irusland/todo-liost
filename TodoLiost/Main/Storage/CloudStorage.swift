//
//  CloudStorage.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 21.11.2021.
//

import Foundation

class CloudStorage {
    let item: TodoItem = TodoItem(text: "WEB")
    func fetch() -> [TodoItem] {
        sleep(1)
        return [item]
    }
}
