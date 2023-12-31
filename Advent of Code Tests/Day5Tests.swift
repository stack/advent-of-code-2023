//
//  Day5Tests.swift
//  Advent of Code 2023 Tests
//
//  Created by Stephen H. Gerstacker on 2023-12-05.
//  SPDX-License-Identifier: MIT
//

import XCTest

final class Day5Tests: XCTestCase {

    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }

    func testIntersection() throws {
        let map = Day5.Map(source: "x", destination: "y", sourceRange: 5 ..< 10, destinationRange: 15 ..< 20)
        
        XCTAssertFalse(map.intersects(source: 0 ..< 5))
        XCTAssertFalse(map.intersects(source: 11 ..< 20))
        
        XCTAssertTrue(map.intersects(source: 5 ..< 10))
        XCTAssertTrue(map.intersects(source: 0 ..< 6))
        XCTAssertTrue(map.intersects(source: 9 ..< 10))
    }
    
    func testSplit() throws {
        let map = Day5.Map(source: "x", destination: "y", sourceRange: 5 ..< 10, destinationRange: 15 ..< 20)
        
        // Left overhang
        var result = map.split(source: 0 ..< 10)
        XCTAssertEqual(result.0, (15 ..< 20))
        XCTAssertEqual(result.1, [(0 ..< 5)])
        
        // Right overhang
        result = map.split(source: 5 ..< 20)
        XCTAssertEqual(result.0, (15 ..< 20))
        XCTAssertEqual(result.1, [(10 ..< 20)])
        
        // Both overhang
        result = map.split(source: 0 ..< 20)
        XCTAssertEqual(result.0, (15 ..< 20))
        XCTAssertEqual(result.1, [(0 ..< 5), (10 ..< 20)])
        
        // Partial left overhang
        result = map.split(source: 0 ..< 7)
        XCTAssertEqual(result.0, (15 ..< 17))
        XCTAssertEqual(result.1, [(0 ..< 5)])
        
        // Partial right overhang
        result = map.split(source: 7 ..< 15)
        XCTAssertEqual(result.0, (17 ..< 20))
        XCTAssertEqual(result.1, [(10 ..< 15)])
    }
    
    func testReal() throws {
        let maps = [
            Day5.Map(source: "", destination: "", sourceRange: 53 ..< 61, destinationRange: 49 ..< 57),
            Day5.Map(source: "", destination: "", sourceRange: 11 ..< 53, destinationRange: 0 ..< 42),
            Day5.Map(source: "", destination: "", sourceRange: 0 ..< 7, destinationRange: 42 ..< 49),
            Day5.Map(source: "", destination: "", sourceRange: 7 ..< 11, destinationRange: 57 ..< 61)
        ]
        
        let inputRanges = [81 ..< 95, 57 ..< 70]
        
        var outputRanges: [Range<Int>] = []
        
        for inputRange in inputRanges {
            if let map = maps.first(where: { $0.intersects(source: inputRange) }) {
                let result = map.split(source: inputRange)
                outputRanges.append(result.0)
                outputRanges.append(contentsOf: result.1)
            } else {
                outputRanges.append(inputRange)
            }
        }
        
        XCTAssertEqual(outputRanges, [81 ..< 95, 53 ..< 57, 61 ..< 70])
    }
}
