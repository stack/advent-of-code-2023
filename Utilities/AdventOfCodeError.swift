//
//  AdventOfCodeError.swift
//  Advent of Code 2023 Utilities
//
//  Created by Stephen H. Gerstacker on 2023-11-26.
//  SPDX-License-Identifier: MIT
//

import Foundation

public enum AdventOfCodeError: LocalizedError {
    
    case apiError(String)
    case wrapped(String,Error)
    
    public var errorDescription: String? {
        return localizedDescription
    }
    
    public var localizedDescription: String {
        switch self {
        case .apiError(let message): return message
        case .wrapped(let message, let error): return "\(message): \(error.localizedDescription)"
        }
    }
}
