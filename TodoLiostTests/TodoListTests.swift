//
//  TodoListTests.swift
//  TodoListTests
//
//  Created by Ruslan Sirazhetdinov on 10.10.2021.
//

import XCTest
@testable import TodoList


// todo написать UI тест https://swiftbook.ru/post/koposhilka/test-making-via-xctest/
class TodoListTests: XCTestCase {
    func testJsonParse() throws {
        let id = "5D6C2F5C-5EDA-4350-9E49-AFB0F6D34D5B"
        let uuid = UUID(uuidString: id)!
        let text = "irusland"
        let expected = TodoItem(id: uuid, text: text)
        let json: TodoItemJson = [
            "id": id,
            "text": text
        ]
        assert(JSONSerialization.isValidJSONObject(json))
        
        let actual = TodoItem.parse(json: json)
        
        assert(expected == actual, "expected \(expected) but was \(String(describing: actual))")
    }
    
    func testJsonDump() throws {
        let id = "5D6C2F5C-5EDA-4350-9E49-AFB0F6D34D5B"
        let uuid = UUID(uuidString: id)!
        let text = "irusland"
        let sut = TodoItem(id: uuid, text: text)
        let expected: TodoItemJson = [
            "id": id,
            "text": text
        ]
        
        let actual = sut.json
        XCTAssertTrue(JSONSerialization.isValidJSONObject(actual))
        
        for (k, v) in expected {
            XCTAssertNotNil(actual[k])
            XCTAssertEqual(actual[k], v)
        }
        
        XCTAssertEqual(expected, actual, "expected \(expected) but was \(String(describing: actual))")
    }
    
    func testCacheInit() throws {
        let sut = FileCache()
        
        XCTAssertTrue(sut.todoItems.count == 0)
    }
    
    // Todo how to DRY?
    func testCacheAdd() throws {
        let sut = FileCache()
        let expected = TodoItem(text: "sample")
        
        sut.add(expected)
        
        XCTAssertTrue(sut.todoItems.count == 1)
        XCTAssertEqual(sut.todoItems[0], expected)
    }
    
    func testCacheAddGet() throws {
        let sut = FileCache()
        let expected = TodoItem(text: "sample")
        
        sut.add(expected)
        let actual = sut.get(by: expected.id)
        
        XCTAssertEqual(actual, expected)
    }
    
    
    func testCacheRemove() throws {
        let sut = FileCache()
        let todoItem = TodoItem(text: "sample")
        sut.add(todoItem)
        
        let actual = sut.remove(by: todoItem.id)
        
        XCTAssertTrue(actual)
        XCTAssertTrue(sut.todoItems.count == 0)
    }
    
    func testCacheRemoveNonExisting() throws {
        let sut = FileCache()
        let todoItem = TodoItem(text: "sample")
        
        sut.add(todoItem)
        let actual = sut.remove(by: UUID())
        
        XCTAssertFalse(actual)
        let storedItem = sut.get(by: todoItem.id)
        XCTAssertEqual(storedItem, storedItem)
    }
    
    func testCacheDumps() throws {
        let sut = FileCache()
        let todoItem = TodoItem(text: "sample")
        let expected = [
            "items": [
                [
                    "id": todoItem.id.uuidString,
                    "text": todoItem.text,
                ]
            ]
        ]
        sut.add(todoItem)
        
        let actual = sut.dump()
        
        XCTAssertNotNil(actual)
        XCTAssertTrue(NSDictionary(dictionary: expected).isEqual(to: actual))
    }
    
    func testCacheSaves() throws {
        let sut = FileCache()
        let todoItem = TodoItem(text: "sample")
        sut.add(todoItem)
        let file = "file.json"
        
        let actual = sut.save(to: file)
        
        XCTAssertTrue(actual)
    }
    
    func testCacheSavesAndLoads() throws {
        let sut = FileCache()
        let todoItem = TodoItem(text: "sample")
        sut.add(todoItem)
        let file = "file.json"
        
        let _ = sut.save(to: file)
        let actual = sut.load(from: file)
        
        XCTAssertTrue(actual)
    }
    
    func testCacheSavesAndLoadsData() throws {
        let fileCache = FileCache()
        let expectedtodoItem = TodoItem(text: "sample")
        fileCache.add(expectedtodoItem)
        let file = "file.json"
        let _ = fileCache.save(to: file)
        
        let sut = FileCache()
        let actual = sut.load(from: file)
        let loadedItem = sut.get(by: expectedtodoItem.id)
        
        XCTAssertTrue(actual)
        XCTAssertEqual(loadedItem, expectedtodoItem)
    }
    
    func testCacheDumpsDeadlineIfSet() throws {
        let sut = FileCache()
        let todoItem = TodoItem(text: "sample", deadLine: Date())
        let encoder = JSONEncoder()
        let jsonDate = String(data: try encoder.encode(todoItem.deadLine!), encoding: .utf8)
        let expected = [
            "items": [
                [
                    "id": todoItem.id.uuidString,
                    "text": todoItem.text,
                    "deadLine": jsonDate,
                ]
            ]
        ]
        sut.add(todoItem)
        
        let actual = sut.dump()
        
        XCTAssertNotNil(actual)
        XCTAssertTrue(NSDictionary(dictionary: expected).isEqual(to: actual))
    }
    
    func testCacheDumpsPriorityIfNotNormal() throws {
        let sut = FileCache()
        let todoItem1 = TodoItem(text: "sample", priority: .important)
        let todoItem2 = TodoItem(text: "sample", priority: .normal)
        let todoItem3 = TodoItem(text: "sample", priority: .no)
        let expected = [
            "items": [
                [
                    "id": todoItem1.id.uuidString,
                    "text": todoItem1.text,
                    "priority": todoItem1.priority.rawValue,
                ],
                [
                    "id": todoItem2.id.uuidString,
                    "text": todoItem2.text,
                ],
                [
                    "id": todoItem3.id.uuidString,
                    "text": todoItem3.text,
                    "priority": todoItem3.priority.rawValue,
                ],
            ]
        ]
        for item in [todoItem1, todoItem2, todoItem3]{
            sut.add(item)
        }
        
        let actual = sut.dump()
        
        XCTAssertNotNil(actual)
        XCTAssertTrue(NSDictionary(dictionary: expected).isEqual(to: actual), "expected \(expected) but was \(String(describing: actual))")
    }
    
    func testCacheDoesNotDumpsColor() throws {
        let sut = FileCache()
        let todoItem = TodoItem(text: "sample", color: .brown)
        let expected = [
            "items": [
                [
                    "id": todoItem.id.uuidString,
                    "text": todoItem.text,
                ],
            ]
        ]
        
        sut.add(todoItem)
        
        
        let actual = sut.dump()
        
        XCTAssertNotNil(actual)
        XCTAssertTrue(NSDictionary(dictionary: expected).isEqual(to: actual), "expected \(expected) but was \(String(describing: actual))")
    }
    
    
    
    func testCacheSavesAndLoadsDatePriority() throws {
        let fileCache = FileCache()
        let file = "file.json"
        let todoItem1 = TodoItem(text: "sample", priority: .important, deadLine: Date())
        let todoItem2 = TodoItem(text: "sample", priority: .normal, deadLine: Date(), color: .black)
        let todoItem3 = TodoItem(text: "sample", priority: .no)
        let encoder = JSONEncoder()
        let expected = [
            "items": [
                [
                    "id": todoItem1.id.uuidString,
                    "text": todoItem1.text,
                    "priority": todoItem1.priority.rawValue,
                ],
                [
                    "id": todoItem2.id.uuidString,
                    "text": todoItem2.text,
                ],
                [
                    "id": todoItem3.id.uuidString,
                    "text": todoItem3.text,
                    "priority": todoItem3.priority.rawValue,
                ],
            ]
        ]
        for item in [todoItem1, todoItem2, todoItem3]{
            fileCache.add(item)
        }
        let _ = fileCache.save(to: file)
        
        let sut = FileCache()
        let isLoaded = sut.load(from: file)
        let actual = sut.dump()
        
        XCTAssertTrue(isLoaded)
        XCTAssertNotNil(actual)
//        for item in [todoItem1, todoItem2, todoItem3]{
//            let loadedItem = sut.get(by: item.id)
//            XCTAssertEqual(loadedItem, item)
//        }
        XCTAssertTrue(NSDictionary(dictionary: expected).isEqual(to: actual), "expected \(expected) but was \(String(describing: actual))")
    }
    
    
}