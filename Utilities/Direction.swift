//
//  Direction.swift
//  Advent of Code 2023 Utilities
//
//  Created by Stephen H. Gerstacker on 2023-12-17.
//  SPDX-License-Identifier: MIT
//

import Foundation

public enum Direction: Hashable, CustomDebugStringConvertible {
    case north
    case south
    case east
    case west
    
    public var debugDescription: String {
        switch self {
        case .north: "^"
        case .south: "v"
        case .east: ">"
        case .west: "<"
        }
    }
}
