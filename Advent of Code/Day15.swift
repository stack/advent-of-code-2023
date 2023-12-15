//
//  Day15.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-15.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day15: AdventDay {
    
    struct Lens: CustomDebugStringConvertible {
        var label: String
        var focalLength: Int
        
        var debugDescription: String { "\(label) \(focalLength)" }
    }
    
    struct Box {
        var index: Int
        var lenses: [Lens] = []
        
        var focusingPower: Int {
            let boxPower = index + 1
            
            return lenses
                .enumerated()
                .map { boxPower * ($0.offset + 1) * $0.element.focalLength }
                .reduce(0, +)
        }
    }
    
    var data: String
    var lines: [Substring] { data.split(separator: "\n") }
    
    func part1() async throws -> Any {
        data
            .trimmingCharacters(in: .newlines)
            .split(separator: ",")
            .map { hash($0) }
            .reduce(0, +)
    }
    
    func part2() async throws -> Any {
        var boxes = (0...256).map { Box(index: $0) }
        let instructions = data.trimmingCharacters(in: .newlines).split(separator: ",")
        
        for instruction in instructions {
            guard let match = instruction.firstMatch(of: /^(.+)([-=])(\d)?$/) else {
                fatalError("Unmatched instruction: \(instruction)")
            }
            
            let label = String(match.output.1)
            let boxIndex = hash(label)
            
            if match.output.2 == "-" {
                boxes[boxIndex].lenses.removeAll { $0.label == label }
            } else {
                let focalLength = Int(match.output.3!)!
                let lens = Lens(label: label, focalLength: focalLength)
                
                if let existingIndex = boxes[boxIndex].lenses.firstIndex(where: { $0.label == label }) {
                    boxes[boxIndex].lenses[existingIndex] = lens
                } else {
                    boxes[boxIndex].lenses.append(lens)
                }
            }
        }
        
        return boxes.reduce(0) { $0 + $1.focusingPower }
    }
    
    private func hash(_ value: any StringProtocol) -> Int {
        var current = 0
        
        for character in value.map({ Int($0.asciiValue!) }) {
            current += character
            current *= 17
            current = current % 256
        }
        
        return current
    }
}
