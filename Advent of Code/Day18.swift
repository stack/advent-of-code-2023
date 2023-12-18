//
//  Day18.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-18.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day18: AdventDay {
    
    struct Instruction {
        var direction: Direction
        var steps: Int
        var color: String
        
        var offset: Point {
            switch direction {
            case .north:
                Point(x: 0, y: -1)
            case .south:
                Point(x: 0, y: 1)
            case .east:
                Point(x: 1, y: 0)
            case .west:
                Point(x: -1, y: 0)
            }
        }
        
        var fullOffset: Point {
            var offsetPoint = offset
            offsetPoint.x *= steps
            offsetPoint.y *= steps
            
            return offsetPoint
        }
    }
    
    var data: String
    
    var fixedInstructions: [Instruction] {
        data.split(separator: "\n").map {
            let match = $0.firstMatch(of: /^([RDLU]) (\d+) \(#([0-9a-f]{6})\)$/)!
            
            let color = match.output.3
            let stepsString = color.prefix(5)
            let steps = Int(stepsString, radix: 16)!
            
            let direction: Direction = switch color.suffix(1) {
            case "0": .east
            case "1": .south
            case "2": .west
            case "3": .north
            default:
                fatalError("Unknown direction: \(color.suffix(1))")
            }
            
            return Instruction(direction: direction, steps: steps, color: "")
        }
    }
    
    var instructions: [Instruction] {
        data.split(separator: "\n").map {
            let match = $0.firstMatch(of: /^([RDLU]) (\d+) \(#([0-9a-f]{6})\)$/)!
            
            let direction: Direction = switch match.output.1 {
            case "U": .north
            case "D": .south
            case "R": .east
            case "L": .west
            default:
                fatalError("Unknown direction: \(match.output.1)")
            }
            
            return Instruction(direction: direction, steps: Int(match.output.2)!, color: String(match.output.3))
        }
    }
    
    func part1() async throws -> Any {
        shoelace(instructions: instructions)
    }
    
    func part2() async throws -> Any {
        shoelace(instructions: fixedInstructions)
    }
    
    private func shoelace(instructions: [Instruction]) -> Int {
        var position = Point.zero
        var points = [position]
        
        for instruction in instructions {
            position = position + instruction.fullOffset
            points.append(position)
        }
        
        let innerArea = points.adjacentPairs().reduce(0) { $0 + ($1.0.x * $1.1.y - $1.0.y * $1.1.x) } / 2
        let outside = points.adjacentPairs().reduce(0) { $0 + ($1.0.manhattenDistance(to: $1.1)) } / 2
        return innerArea + outside + 1
    }
}
