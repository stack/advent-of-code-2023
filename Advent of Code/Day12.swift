//
//  Day12.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-12.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day12: AdventDay {
    
    struct State: Hashable {
        var row: [String]
        var patter: [Int]
    }
    
    var data: String
    
    func part1() async throws -> Any {
        var counts: [Int] = []
        
        for line in data.split(separator: "\n") {
            let parts = line.split(separator: " ")
            let row = parts[0].map { String($0) }
            let pattern = parts[1].split(separator: ",").map { Int($0)! }
            
            var cache: [State:Int] = [:]
            counts.append(visit(row: row, pattern: pattern, cache: &cache))
        }
        
        return counts.reduce(0, +)
    }
    
    func part2() async throws -> Any {
        var counts: [Int] = []
        
        for line in data.split(separator: "\n") {
            let parts = line.split(separator: " ")
            let row = String(parts[0])
            let expandedRow = Array([String](repeating: row, count: 5).joined(separator: "?")).map { String($0) }
            let pattern = parts[1].split(separator: ",").map { Int($0)! }
            let expandedPattern = [[Int]](repeating: pattern, count: 5).flatMap { $0 }
            
            var cache: [State:Int] = [:]
            counts.append(visit(row: expandedRow, pattern: expandedPattern, cache: &cache))
        }
        
        return counts.reduce(0, +)
    }
    
    private func visit(row: [String], pattern: [Int], cache: inout [State:Int]) -> Int {
        let state = State(row: row, patter: pattern)
        
        if let count = cache[state] {
            return count
        }
        
        if row.isEmpty {
            return pattern.isEmpty ? 1 : 0
        }
        
        if pattern.isEmpty {
            return row.contains("#") ? 0 : 1
        }
        
        var count = 0
        
        if row[0] == "." || row[0] == "?" {
            count += visit(row: Array(row.dropFirst()), pattern: pattern, cache: &cache)
        }
        
        if row[0] == "#" || row[0] == "?" {
            if pattern[0] <= row.count && 
                !row[..<pattern[0]].contains(".") &&
                (pattern[0] == row.count || row[pattern[0]] != "#") {
                count += visit(row: Array(row.dropFirst(pattern[0] + 1)), pattern: Array(pattern.dropFirst()), cache: &cache)
            }
        }
        
        cache[state] = count
        
        return count
    }
}
