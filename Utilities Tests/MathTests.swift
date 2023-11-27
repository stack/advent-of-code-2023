//
//  MathTests.swift
//  Advent of Code 2023 Utilities Tests
//
//  Created by Stephen H. Gerstacker on 2023-11-26.
//  SPDX-License-Identifier: MIT
//

import XCTest
@testable import Utilities

final class MathTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testGCD() throws {
        XCTAssertEqual(gcd(52, 39), 13)
        XCTAssertEqual(gcd(228, 36), 12)
        XCTAssertEqual(gcd(51357, 3819), 57)
        XCTAssertEqual(gcd(16, 12), 4)
        XCTAssertEqual(gcd(150, 200), 50)
    }
}
