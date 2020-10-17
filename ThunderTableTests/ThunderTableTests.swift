//
//  ThunderTableTests.swift
//  ThunderTableTests
//
//  Created by Simon Mitchell on 14/09/2016.
//  Copyright © 2016 3SidedCube. All rights reserved.
//

import XCTest
@testable import ThunderTable

class ThunderTableTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSectionIndexPathsCalculation() {
        
        let data = [
            [TableRow(title: ""), TableRow(title: "")],
            [],
            [TableRow(title: ""), TableRow(title: ""), TableRow(title: ""), TableRow(title: "")],
            [TableRow(title: "")]
        ] as [Section]
        
        let indexPaths = data.indexPaths
        
        XCTAssertEqual(
            indexPaths,
            [
                IndexPath(row: 0, section: 0),
                IndexPath(row: 1, section: 0),
                IndexPath(row: 0, section: 2),
                IndexPath(row: 1, section: 2),
                IndexPath(row: 2, section: 2),
                IndexPath(row: 3, section: 2),
                IndexPath(row: 0, section: 3)
            ]
        )
    }
}
