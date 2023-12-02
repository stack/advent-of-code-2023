//
//  Day1.swift
//  Advent of Code 2023
//
//  Created by Stephen H. Gerstacker on 2023-12-01.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day1: AdventDay {
    var data: String
    
    let values = Array(1...9)
    let names = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    
    var testGroups: [[String]] {
        data.split(separator: "\n\n").map {
            $0.split(separator: "\n").map { String($0) }
        }
    }
    
    func part1() async throws -> Any {
        testGroups.enumerated().map {
            part1(group: $0.element, index: $0.offset)
        }
    }
    
    private func part1(group: [String], index: Int) -> Int {
        print("Running group \(index) part 1:")
        
        let total = group.reduce(0) { sum, value in
            let numbers = value.compactMap { Int(String($0)) }
            
            guard !numbers.isEmpty else { return sum + 0 }
            
            let amount = numbers.first! * 10 + numbers.last!
            print("-   Found \(numbers.first!) + \(numbers.last!) = \(amount)")
            
            return sum + amount
        }
        
        print("Total: \(total)")
        
        return total
    }
    
    func part2() async throws -> Any {
        testGroups.enumerated().map {
            part2(group: $0.element, index: $0.offset)
        }
    }
    
    private func part2(group: [String], index: Int) -> Int {
        print("Running group \(index) part 2:")
        
        let total = group.reduce(0) { sum, value in
            var remaining = String(value)
            var numbers: [Int] = []
            
            outer: while !remaining.isEmpty {
                
                if let first = remaining.first, let number = Int(String(first)) {
                    numbers.append(number)
                    remaining.removeFirst()
                    
                    continue
                }
                
                for (index, name) in names.enumerated() {
                    if remaining.hasPrefix(name) {
                        numbers.append(values[index])
                        remaining.removeFirst()
                        
                        continue outer
                    }
                }
                
                remaining.removeFirst()
            }
            
            guard !numbers.isEmpty else { fatalError("No numbers found") }
            
            let amount = numbers.first! * 10 + numbers.last!
            print("-   Found \(numbers.first!) + \(numbers.last!) = \(amount)")
            
            return sum + amount
        }
        
        print("Total: \(total)")
        
        return total
    }
}
