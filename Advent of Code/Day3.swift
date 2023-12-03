//
//  Day3.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-03.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day3: AdventDay {
    var data: String
    
    struct NumberRange {
        var value: Int
        var x: ClosedRange<Int>
        var y: ClosedRange<Int>
        
        func contains(_ symbolRange: SymbolRange) -> Bool {
            x.contains(symbolRange.x) && y.contains(symbolRange.y)
        }
    }
    
    struct SymbolRange {
        var value: String
        var x: Int
        var y: Int
    }
    
    var lines: [String] {
        data.split(separator: "\n").map { String($0) }
    }
    
    var numberRanges: [NumberRange] {
        var ranges: [NumberRange] = []
        
        for (y, line) in lines.enumerated() {
            for match in line.ranges(of: /\d+/) {
                let number = Int(line[match])!
                
                let lhsDistance = line.distance(from: line.startIndex, to: match.lowerBound)
                let rhsDistance = line.distance(from: line.startIndex, to: match.upperBound) - 1
                
                let left = lhsDistance == 0 ? 0 : lhsDistance - 1
                let right = rhsDistance == line.count - 1 ? line.count - 1 : rhsDistance + 1
                
                let top = y == 0 ? 0 : y - 1
                let bottom = y == lines.count - 1 ? y : y + 1
                
                ranges.append(NumberRange(value: number, x: left...right, y: top...bottom))
            }
        }
        
        return ranges
    }
    
    var symbolRanges: [SymbolRange] {
        var ranges: [SymbolRange] = []
        
        for (y, line) in lines.enumerated() {
            for match in line.ranges(of: /[^\d\.]/) {
                let value = String(line[match])
                let distance = line.distance(from: line.startIndex, to: match.lowerBound)
                
                ranges.append(SymbolRange(value: value, x: distance, y: y))
            }
        }
        
        return ranges
    }
    
    func part1() async throws -> Any {
        var sum = 0
        let symbolRanges = self.symbolRanges
        
        for numberRange in numberRanges {
            if let symbolRange = symbolRanges.first(where: { numberRange.contains($0) }) {
                print("\(numberRange) near \(symbolRange)")
                sum += numberRange.value
            }
        }
        
        return sum
    }
    
    func part2() async throws -> Any {
        var sum = 0
        let numberRanges = self.numberRanges
        let gearSymbols = symbolRanges.filter { $0.value == "*" }
        
        for gearSymbol in gearSymbols {
            let matchingNumbers = numberRanges.filter { $0.contains(gearSymbol) }
            
            if matchingNumbers.count == 2 {
                sum += matchingNumbers[0].value * matchingNumbers[1].value
            }
        }
        
        return sum
    }
}
