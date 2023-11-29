//
//  main.swift
//  Day 01
//
//  Created by Stephen H. Gerstacker on 2023-11-29.
//

import Foundation

let data1 = InputData
let data2 = InputData
var total = 0

// MARK: - Part 1

print("Part 1:")

total = 0

for line in data1.split(separator: "\n") {
    let numbers = line.compactMap { Int(String($0)) }
    
    guard !numbers.isEmpty else { fatalError("No numbers found") }
    
    let amount = numbers.first! * 10 + numbers.last!
    print("-   Found \(numbers.first!) + \(numbers.last!) = \(amount)")
    
    total += amount
}

print("-   Total: \(total)")

// MARK: - Part 2

print("")
print("Part 2:")

total = 0

let values = Array(1...9)
let names = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

for line in data2.split(separator: "\n") {
    var remaining = String(line)
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
    
    total += amount
}

print("-   Total: \(total)")
