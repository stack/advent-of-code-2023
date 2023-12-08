//
//  Math.swift
//  Advent of Code 2023 Utilities
//
//  Created by Stephen H. Gerstacker on 2023-11-26.
//  SPDX-License-Identifier: MIT
//

import Foundation

public func lcm<T: SignedInteger>(_ a: T, _ b: T) -> T {
    abs(a) * (abs(b) / gcd(a, b))
}

public func gcd<T: SignedInteger>(_ a: T, _ b: T) -> T {
    let r = a % b
    
    if r != 0 {
        return gcd(b, r)
    } else {
        return b
    }
}
