//
//  TodoListTests.swift
//  TodoLiostTests
//
//  Created by Ruslan Sirazhetdinov on 17.10.2021.
//

import XCTest
@testable import TodoLiost

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
            XCTAssertEqual(actual[k] as? String, v as? String)
        }

        XCTAssertEqual(expected as? [String: String], actual as? [String: String], "expected \(expected) but was \(String(describing: actual))")
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

    func testCacheAddWithSameId() throws {
        let sut = FileCache()
        let item1 = TodoItem(text: "sample1")
        let item2 = TodoItem(id: item1.id, text: "sample2")

        sut.add(item1)
        sut.add(item2)

        XCTAssertTrue(sut.todoItems.count == 1)
        XCTAssertEqual(sut.todoItems, [item1])
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
                    "text": todoItem.text
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

        _ = sut.save(to: file)
        let actual = sut.load(from: file)

        XCTAssertTrue(actual)
    }

    func testCacheSavesAndLoadsData() throws {
        let fileCache = FileCache()
        let expectedtodoItem = TodoItem(text: "sample")
        fileCache.add(expectedtodoItem)
        let file = "file.json"
        _ = fileCache.save(to: file)

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
                    "deadLine": jsonDate
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
                    "priority": todoItem1.priority.rawValue
                ],
                [
                    "id": todoItem2.id.uuidString,
                    "text": todoItem2.text
                ],
                [
                    "id": todoItem3.id.uuidString,
                    "text": todoItem3.text,
                    "priority": todoItem3.priority.rawValue
                ]
            ]
        ]
        for item in [todoItem1, todoItem2, todoItem3] {
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
                    "color": "0.6 0.4 0.2 1"
                ]
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let todoItem1 = TodoItem(text: "sample", priority: .important, deadLine: formatter.date(from: "2021/10/22 20:00"))
        let todoItem2 = TodoItem(text: "sample", priority: .normal, deadLine: formatter.date(from: "2021/10/22 21:30"), color: .black)
        let todoItem3 = TodoItem(text: "sample", priority: .no)
        let expected = [
            "items": [
                [
                    "id": todoItem1.id.uuidString,
                    "text": todoItem1.text,
                    "priority": todoItem1.priority.rawValue,
                    "deadLine": "656607600"
                ],
                [
                    "id": todoItem2.id.uuidString,
                    "text": todoItem2.text,
                    "color": "0 0 0 1",
                    "deadLine": "656613000"
                ],
                [
                    "id": todoItem3.id.uuidString,
                    "text": todoItem3.text,
                    "priority": todoItem3.priority.rawValue
                ]
            ]
        ]
        for item in [todoItem1, todoItem2, todoItem3] {
            fileCache.add(item)
        }
        _ = fileCache.save(to: file)

        let sut = FileCache()
        let isLoaded = sut.load(from: file)
        let actual = sut.dump()

        XCTAssertTrue(isLoaded)
        XCTAssertNotNil(actual)
        XCTAssertTrue(NSDictionary(dictionary: expected).isEqual(to: actual), "expected \(expected) but was \(String(describing: actual))")
    }

}
