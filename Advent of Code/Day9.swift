//
//  Day9.swift
//  Advent of Code 2023
//
//  Created by Stephen H. Gerstacker on 2023-12-09.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day9: AdventDay {
    
    var data: String
    
    var initialValues: [[Int]] {
        data.split(separator: "\n").map {
            $0.split(separator: " ").map { Int($0)! }
        }
    }
    
    func part1() async throws -> Any {
        var results: [Int] = []
        
        for values in initialValues {
            var tree = [values]
            
            var currentValues = values
            
            print("Expanding \(currentValues)")
            
            while !currentValues.allSatisfy({ $0 == 0 }) {
                let nextValues = currentValues.adjacentPairs().map { $0.1 - $0.0 }
                tree.append(nextValues)
                currentValues = nextValues
                
                print("- \(currentValues)")
            }
            
            tree[tree.count - 1].append(0)
            print("- Advanced \(tree.count - 1) to \(tree[tree.count - 1])")
            
            for index in (1 ..< tree.count).reversed() {
                let value = tree[index].last! + tree[index - 1].last!
                tree[index - 1].append(value)
                
                print("- Advanced \(index - 1) to \(tree[index - 1])")
            }
            
            results.append(tree.first!.last!)
        }
        
        return results.reduce(0, +)
    }
    
    func part2() async throws -> Any {
        var results: [Int] = []
        
        for values in initialValues {
            var tree = [values]
            
            var currentValues = values
            
            print("Expanding \(currentValues)")
            
            while !currentValues.allSatisfy({ $0 == 0 }) {
                let nextValues = currentValues.adjacentPairs().map { $0.1 - $0.0 }
                tree.append(nextValues)
                currentValues = nextValues
                
                print("- \(currentValues)")
            }
            
            tree[tree.count - 1].insert(0, at: 0)
            print("- Prepended \(tree.count - 1) to \(tree[tree.count - 1])")
            
            for index in (1 ..< tree.count).reversed() {
                let value = tree[index - 1].first! - tree[index].first! 
                tree[index - 1].insert(value, at: 0)
                
                print("- Prepended \(index - 1) to \(tree[index - 1])")
            }
            
            results.append(tree.first!.first!)
        }
        
        return results.reduce(0, +)
    }
}
