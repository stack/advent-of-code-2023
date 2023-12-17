//
//  Day17.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-17.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Position: Hashable, CustomDebugStringConvertible {
    
    var point: Point
    var direction: Direction
    
    var debugDescription: String {
        "\(point) \(direction)"
    }
    
    var nextPositions: [Position] {
        switch direction {
        case .north:
            [
                Position(point: Point(x: point.x, y: point.y - 1), direction: .north),
                Position(point: Point(x: point.x - 1, y: point.y), direction: .west),
                Position(point: Point(x: point.x + 1, y: point.y), direction: .east)
            ]
        case .south:
            [
                Position(point: Point(x: point.x, y: point.y + 1), direction: .south),
                Position(point: Point(x: point.x - 1, y: point.y), direction: .west),
                Position(point: Point(x: point.x + 1, y: point.y), direction: .east)
            ]
        case .east:
            [
                Position(point: Point(x: point.x + 1, y: point.y), direction: .east),
                Position(point: Point(x: point.x, y: point.y - 1), direction: .north),
                Position(point: Point(x: point.x, y: point.y + 1), direction: .south)
            ]
        case .west:
            [
                Position(point: Point(x: point.x - 1, y: point.y), direction: .west),
                Position(point: Point(x: point.x, y: point.y - 1), direction: .north),
                Position(point: Point(x: point.x, y: point.y + 1), direction: .south)
            ]
        }
    }
}

extension Direction {
    
    var offset: Point {
        switch self {
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
    
    var turns: [Direction] {
        switch self {
        case .north, .south:
            [.east, .west]
        case .east, .west:
            [.north, .south]
        }
    }
}

struct Day17: AdventDay {
    
    var data: String
    
    var weights: [[Int]] {
        data.split(separator: "\n").map { $0.split(separator: "").map { Int($0)! } }
    }
    
    var weightTable: [Point:Int] {
        var table: [Point:Int] = [:]
        
        for (y, line) in weights.enumerated() {
            for (x, weight) in line.enumerated() {
                let point = Point(x: x, y: y)
                table[point] = weight
            }
        }
        
        return table
    }
    
    func part1() async throws -> Any {
        run(minBlocks: 0, maxBlocks: 3)
    }
    
    func part2() async throws -> Any {
        run(minBlocks: 3, maxBlocks: 10)
    }
    
    private func run(minBlocks: Int, maxBlocks: Int) -> Int {
        let heatTable = weightTable
        let maxX = heatTable.keys.map { $0.x }.max()!
        let maxY = heatTable.keys.map { $0.y }.max()!

        let startPoint = Point.zero
        let endPoint = Point(x: maxX, y: maxY)
        
        var toVisit = PriorityQueue<Position>()
        toVisit.push(Position(point: .zero, direction: .east), priority: 0)
        toVisit.push(Position(point: .zero, direction: .south), priority: 0)
        
        var costSoFar: [Position:Int] = [
            Position(point: startPoint, direction: .north): 0,
            Position(point: startPoint, direction: .south): 0,
            Position(point: startPoint, direction: .east): 0,
            Position(point: startPoint, direction: .west): 0,
        ]
        
        while !toVisit.isEmpty {
            let (currentPosition, currentCost) = toVisit.popWithCost()!
            
            let existingCost = costSoFar[currentPosition] ?? Int.max
            
            guard currentCost <= existingCost else { continue }
            
            var nextPoint = currentPosition.point
            var nextHeatLoss = currentCost
            
            for index in 0 ..< maxBlocks {
                nextPoint = nextPoint + currentPosition.direction.offset
                
                guard nextPoint.x >= 0 && nextPoint.x <= maxX && nextPoint.y >= 0 && nextPoint.y <= maxY else { continue }
                
                nextHeatLoss += heatTable[nextPoint]!
                
                guard index >= minBlocks else { continue }
                
                for turn in currentPosition.direction.turns {
                    let nextPosition = Position(point: nextPoint, direction: turn)
                    let existingCost = costSoFar[nextPosition] ?? Int.max
                    
                    if nextHeatLoss < existingCost {
                        costSoFar[nextPosition] = nextHeatLoss
                        toVisit.push(nextPosition, priority: nextHeatLoss)
                    }
                }
            }
        }
        
        let endPositions = costSoFar.keys.filter { $0.point == endPoint }
        let endCosts = endPositions.map { costSoFar[$0]! }
        
        return endCosts.min()!
    }
    
    private func dump(path: [Position], map: [Point:Int]) {
        let maxX = map.keys.map { $0.x }.max()!
        let maxY = map.keys.map { $0.y }.max()!
        
        for y in (0 ... maxY) {
            for x in (0 ... maxX) {
                let point = Point(x: x, y: y)
                
                if let position = path.first(where: { $0.point == point }) {
                    print(position.direction, terminator: "")
                } else {
                    print(map[point]!, terminator: "")
                }
            }
            
            print()
        }
    }
    private func path(to endPosition: Position, cameFrom: [Position:Position], limit: Int? = nil) -> [Position] {
        var current: Position? = endPosition
        var path: [Position] = [endPosition]
        
        while current != nil && path.count != limit {
            current = cameFrom[current!]
            
            if let current {
                path.append(current)
            }
        }
        
        return path.reversed()
    }
}
