//
//  Day23.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-23.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day23: AdventDay {
    
    enum Space {
        case empty
        case slideRight
        case slideDown
    }
    
    var data: String
    
    var spaces: [Point:Space] {
        var result: [Point:Space] = [:]
        
        for (y, line) in data.split(separator: "\n").enumerated() {
            for (x, value) in line.enumerated() {
                let point = Point(x: x, y: y)
                
                switch value {
                case ".": result[point] = .empty
                case ">": result[point] = .slideRight
                case "v": result[point] = .slideDown
                case "#": break
                default: fatalError("Unhandled value: \(value)")
                }
            }
        }
        
        return result
    }
    
    var start: Point {
        let line = data.split(separator: "\n").first!
        let index = line.firstIndex(of: ".")!
        
        return Point(x: line.distance(from: line.startIndex, to: index), y: 0)
    }
    
    var end: Point {
        let lines = data.split(separator: "\n")
        let line = lines.last!
        let index = line.firstIndex(of: ".")!
        
        return Point(x: line.distance(from: line.startIndex, to: index), y: lines.count - 1)
    }
    
    func part1() async throws -> Any {
        let spaces = self.spaces
        let start = self.start
        let end = self.end
        
        return search(spaces: spaces, start: start, end: end) { currentPoint, spaces in
            switch spaces[currentPoint]! {
            case .empty: currentPoint.cardinalNeighbors
            case .slideDown: [currentPoint + Point(x: 0, y: 1)]
            case .slideRight: [currentPoint + Point(x: 1, y: 0)]
            }
        }
    }
    
    func part2() async throws -> Any {
        let spaces = self.spaces
        let start = self.start
        let end = self.end
        
        return search(spaces: spaces, start: start, end: end) { currentPoint, spaces in
            currentPoint.cardinalNeighbors
        }
    }
    
    private func findPath(point: Point, end: Point, graph: [Point:[Point:Int]], visited: inout Set<Point>) -> Int {
        guard point != end else { return 0 }
        
        var maxLength = Int.min
        
        visited.insert(point)
        
        for (nextPoint, nextDistance) in graph[point]! where !visited.contains(nextPoint) {
            let result = findPath(point: nextPoint, end: end, graph: graph, visited: &visited) + nextDistance
            maxLength = max(maxLength, result)
        }
        
        visited.remove(point)
        
        return maxLength
    }
    
    private func search(spaces: [Point:Space], start: Point, end: Point, nextPoints: (Point,[Point:Space]) -> [Point]) -> Int {
        let intersections = spaces.compactMap { (point, space) -> Point? in
            guard space == .empty else { return nil }
            
            let neighbors = point.cardinalNeighbors
                .filter { spaces[$0] != nil }
                
            return neighbors.count > 2 ? point : nil
        }
        
        let points = [start] + intersections + [end]
        var graph: [Point:[Point:Int]] = [:]
        
        for point in points {
            var toVisit = [(0, point)]
            var visited: Set<Point> = [point]
            
            while !toVisit.isEmpty {
                let (distance, currentPoint) = toVisit.removeLast()
                
                if distance != 0 && points.contains(currentPoint) {
                    graph[point, default: [:]][currentPoint] = distance
                    continue
                }
                
                let neighbors = nextPoints(currentPoint, spaces)
                
                for neighbor in neighbors where spaces[neighbor] != nil && !visited.contains(neighbor) {
                    toVisit.append((distance + 1, neighbor))
                    visited.insert(neighbor)
                }
            }
        }
    
        print(graph)
        
        var cache: Set<Point> = []
        
        return findPath(point: start, end: end, graph: graph, visited: &cache)
    }
}
