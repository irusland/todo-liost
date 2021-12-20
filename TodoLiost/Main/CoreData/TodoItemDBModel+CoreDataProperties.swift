//
//  TodoItemDBModel+CoreDataProperties.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 18.12.2021.
//
//

import Foundation
import CoreData

extension TodoItemDBModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItemDBModel> {
        return NSFetchRequest<TodoItemDBModel>(entityName: "TodoItemDBModel")
    }

    @NSManaged public var changedAt: Date
    @NSManaged public var color: NSObject?
    @NSManaged public var createdAt: Date
    @NSManaged public var deadLine: Date?
    @NSManaged public var id: UUID
    @NSManaged public var priority: Int32
    @NSManaged public var text: String

}

extension TodoItemDBModel: Identifiable {

}
