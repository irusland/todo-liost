//
//  TodoLiostUITests.swift
//  TodoLiostUITests
//
//  Created by Ruslan Sirazhetdinov on 17.10.2021.
//

import XCTest

class TodoLiostUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()

        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDetailsOpens() throws {
        app.buttons["+"].tap()
        XCTAssertTrue(app.isDisplayingDetailsView)
        app/*@START_MENU_TOKEN@*/.staticTexts["Save"]/*[[".buttons[\"Save\"].staticTexts[\"Save\"]",".staticTexts[\"Save\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssertFalse(app.isDisplayingDetailsView)
    }
    
    func testDelete() throws {
        let collectionViewsQuery = app.collectionViews
        let initialCount = collectionViewsQuery.cells.count
        app.buttons["+"].tap()
        XCTAssertTrue(app.isDisplayingDetailsView)
        app/*@START_MENU_TOKEN@*/.staticTexts["Save"]/*[[".buttons[\"Save\"].staticTexts[\"Save\"]",".staticTexts[\"Save\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssertFalse(app.isDisplayingDetailsView)
        
        XCTAssertEqual(collectionViewsQuery.cells.count, initialCount + 1)
    
        app.collectionViews.children(matching: .cell).element(boundBy: 3).children(matching: .other).element/*@START_MENU_TOKEN@*/.press(forDuration: 1.3);/*[[".tap()",".press(forDuration: 1.3);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Delete"]/*[[".cells.buttons[\"Delete\"]",".buttons[\"Delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssertEqual(collectionViewsQuery.cells.count, initialCount)
    }
    
    
    func testText() throws {
        app.buttons["+"].tap()
        
        let tododetailsviewElement = app.otherElements["todoDetailsView"]
        let textView = tododetailsviewElement.children(matching: .textView).element
        let text = "Some written text"
        XCTAssertTrue(textView.exists)
        XCTAssertTrue(app.isDisplayingDetailsView)
        
        textView.tap()
        textView.typeText(text)
                
        app/*@START_MENU_TOKEN@*/.staticTexts["Save"]/*[[".otherElements[\"todoDetailsView\"]",".buttons[\"Save\"].staticTexts[\"Save\"]",".staticTexts[\"Save\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        app.collectionViews.children(matching: .cell).otherElements.containing(.staticText, identifier:text).element/*@START_MENU_TOKEN@*/.press(forDuration: 1.3);/*[[".tap()",".press(forDuration: 1.3);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        app.collectionViews.buttons["Edit"].tap()
        XCTAssertTrue(app.isDisplayingDetailsView)
        
        XCTAssertEqual(textView.value as! String, text)
        app/*@START_MENU_TOKEN@*/.staticTexts["Delete"]/*[[".otherElements[\"todoDetailsView\"]",".buttons[\"Delete\"].staticTexts[\"Delete\"]",".staticTexts[\"Delete\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
    
    
    func testLaunchPerformance() throws {
        if #available(iOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

extension XCUIApplication {
    var isDisplayingDetailsView: Bool {
        return otherElements["todoDetailsView"].exists
    }
}
