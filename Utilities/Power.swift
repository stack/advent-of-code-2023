//
//  Power.swift
//  Advent of Code 2023 Utilities
//
//  Created by Stephen H. Gerstacker on 2023-11-26.
//  SPDX-License-Identifier: MIT
//

import Foundation

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence

public func ^^(radis: Int, power: Int) -> Int {
    return Int(pow(Double(radis), Double(power)))
}
