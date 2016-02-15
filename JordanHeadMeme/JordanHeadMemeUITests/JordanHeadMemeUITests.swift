//
//  JordanHeadMemeUITests.swift
//  JordanHeadMemeUITests
//
//  Created by David Okun on 12/18/15.
//  Copyright © 2015 David Okun, LLC. All rights reserved.
//

import XCTest

class JordanHeadMemeUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testChoosingPhotoFromCameraRollWithOneFace() {
        let app = XCUIApplication()
        app.buttons["Choose Photo"].tap()
        app.tables.buttons["Camera Roll"].tap()
        app.collectionViews.childrenMatchingType(.Cell).matchingIdentifier("Photo, Portrait, January 19, 2015, 11:10 PM").elementBoundByIndex(0).tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        app.buttons["Done"].tap()
        
        XCTAssertTrue(app.buttons["Choose Photo"].exists, "Should be back on the home screen after tapping done")
        XCTAssertTrue(app.buttons["Take Photo"].exists, "Should be back on the home screen after tapping done")
    }
    
    func testSavingPhoto() {
        let app = XCUIApplication()
        app.buttons["Choose Photo"].tap()
        app.tables.buttons["Camera Roll"].tap()
        app.collectionViews.childrenMatchingType(.Cell).matchingIdentifier("Photo, Portrait, January 19, 2015, 11:10 PM").elementBoundByIndex(0).tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        app.buttons["Save"].tap()
        
        XCTAssertTrue(app.buttons["Choose Photo"].exists, "Should be back on the home screen after tapping done")
        XCTAssertTrue(app.buttons["Take Photo"].exists, "Should be back on the home screen after tapping done")
    }
}
