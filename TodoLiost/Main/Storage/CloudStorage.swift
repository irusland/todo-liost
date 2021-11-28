//
//  CloudStorage.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 21.11.2021.
//

import Foundation

class CloudStorage {
    private var connector: BackendConnector
    
    init(connector: BackendConnector) {
        self.connector = connector
    }
    
    let item: TodoItem = TodoItem(text: "WEB")
    
    func fetch() -> [TodoItem] {
        connector.getList()
        return [item]
    }
}
