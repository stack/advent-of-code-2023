//
//  Day10.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-10.
//

import Foundation

struct Day10: AdventDay {
    
    enum Direction {
        case north
        case south
        case east
        case west
    }
    
    enum Pipe: String, CaseIterable {
        case vertical = "|"
        case horizontal = "-"
        case lBend = "L"
        case jBend = "J"
        case sevenBend = "7"
        case fBend = "F"
        case start = "S"
        case none = "."
        
        var directions: Set<Direction> {
            switch self {
            case .vertical:
                [.north, .south]
            case .horizontal:
                [.east, .west]
            case .lBend:
                [.north, .east]
            case .jBend:
                [.north, .west]
            case .sevenBend:
                [.south, .west]
            case .fBend:
                [.south, .east]
            case .start:
                []
            case .none:
                []
            }
        }
    }
    
    typealias Map = [[Pipe]]
    
    var data: String
    
    var maps: [Map] {
        data.split(separator: "\n\n").map {
            $0.split(separator: "\n").map {
                $0.map { Pipe(rawValue: String($0))! }
            }
        }
    }
    
    func part1() async throws -> Any {
        var distances: [Int] = []
        
        for map in maps {
            guard let start = findStart(in: map) else {
                fatalError("No start found")
            }
            
            var farthest: Int = 0
            var visited: Set<Point> = [start]
            var toVisit: [(Point, Int)] = findNext(from: start, map: map).map { ($0, 1) }
            
            while !toVisit.isEmpty {
                let (current, distance) = toVisit.removeFirst()
                
                guard !visited.contains(current) else { continue }
                visited.insert(current)
                
                farthest = max(farthest, distance)
                
                let currentPipe = map[current.y][current.x]
                
                if currentPipe.directions.contains(.north) {
                    toVisit.append((Point(x: current.x, y: current.y - 1), distance + 1))
                }
                
                if currentPipe.directions.contains(.south) {
                    toVisit.append((Point(x: current.x, y: current.y + 1), distance + 1))
                }
                
                if currentPipe.directions.contains(.east) {
                    toVisit.append((Point(x: current.x + 1, y: current.y), distance + 1))
                }
                
                if currentPipe.directions.contains(.west) {
                    toVisit.append((Point(x: current.x - 1, y: current.y), distance + 1))
                }
            }
            
            distances.append(farthest)
        }
        
        return distances
    }
    
    func part2() async throws -> Any {
        var insides: [Int] = []
        
        for var map in maps {
            guard let start = findStart(in: map) else {
                fatalError("No start found")
            }
            
            map[start.y][start.x] = determineType(from: start, in: map)
            
            var farthest: Int = 0
            var visited: Set<Point> = [start]
            var toVisit: [(Point, Int)] = findNext(from: start, map: map).map { ($0, 1) }
            
            while !toVisit.isEmpty {
                let (current, distance) = toVisit.removeFirst()
                
                guard !visited.contains(current) else { continue }
                visited.insert(current)
                
                farthest = max(farthest, distance)
                
                let currentPipe = map[current.y][current.x]
                
                if currentPipe.directions.contains(.north) {
                    toVisit.append((Point(x: current.x, y: current.y - 1), distance + 1))
                }
                
                if currentPipe.directions.contains(.south) {
                    toVisit.append((Point(x: current.x, y: current.y + 1), distance + 1))
                }
                
                if currentPipe.directions.contains(.east) {
                    toVisit.append((Point(x: current.x + 1, y: current.y), distance + 1))
                }
                
                if currentPipe.directions.contains(.west) {
                    toVisit.append((Point(x: current.x - 1, y: current.y), distance + 1))
                }
            }
            
            var insidePoints: Set<Point> = []
            var outsidePoints: Set<Point> = []
            
            for (y, line) in map.enumerated() {
                for (x, pipe) in line.enumerated() {
                    let point = Point(x: x, y: y)
                    
                    guard pipe == .none || !visited.contains(point) else { continue }
                    
                    var count = 0
                    
                    for x in 0 ..< point.x {
                        let testPoint = Point(x: x, y: point.y)
                        
                        guard visited.contains(testPoint) else { continue }
                        
                        let testPipe = map[point.y][x]
                        
                        if testPipe == .vertical || testPipe == .sevenBend || testPipe == .fBend {
                            count += 1
                        }
                    }
                    
                    if count % 2 == 0 {
                        outsidePoints.insert(point)
                    } else {
                        insidePoints.insert(point)
                    }
                }
            }
            
            insides.append(insidePoints.count)
            
            for y in 0 ..< map.count {
                for x in 0 ..< map[0].count {
                    let point = Point(x: x, y: y)
                    
                    if visited.contains(point) {
                        let pipe = map[point.y][point.x]
                        print(pipe.rawValue, terminator: "")
                    } else if outsidePoints.contains(point) {
                        print("O", terminator: "")
                    } else if insidePoints.contains(point) {
                        print("I", terminator: "")
                    } else {
                        print("ø", terminator: "")
                    }
                }
                
                print()
            }
            
            print()
        }
        
        return insides
    }
    
    private func findStart(in map: Map) -> Point? {
        for (y, line) in map.enumerated() {
            if let index = line.firstIndex(of: .start) {
                return Point(x: line.distance(from: line.startIndex, to: index), y: y)
            }
        }
        
        return nil
    }
    
    private func determineType(from point: Point, in map: Map) -> Pipe {
        var directions: Set<Direction> = []
        
        let north = Point(x: point.x, y: point.y - 1)
        
        if north.y >= 0 {
            let northPipe = map[north.y][north.x]
            
            if northPipe.directions.contains(.south) {
                directions.insert(.north)
            }
        }
        
        let south = Point(x: point.x, y: point.y + 1)
        
        if south.y < map.count {
            let southPipe = map[south.y][south.x]
            
            if southPipe.directions.contains(.north) {
                directions.insert(.south)
            }
        }
        
        let east = Point(x: point.x + 1, y: point.y)
        
        if east.x < map[0].count {
            let eastPipe = map[east.y][east.x]
            
            if eastPipe.directions.contains(.west) {
                directions.insert(.east)
            }
        }
        
        let west = Point(x: point.x - 1, y: point.y)
        
        if west.x >= 0 {
            let westPipe = map[west.y][west.x]
            
            if westPipe.directions.contains(.east) {
                directions.insert(.west)
            }
        }
        
        for pipe in Pipe.allCases {
            if !pipe.directions.isEmpty && pipe.directions == directions {
                return pipe
            }
        }
        
        fatalError("Failed to determine start pipe type")
    }
    
    private func findNext(from start: Point, map: Map) -> [Point] {
        var results: [Point] = []
        
        let north = Point(x: start.x, y: start.y - 1)
        
        if north.y >= 0 {
            let northPipe = map[north.y][north.x]
            
            if northPipe.directions.contains(.south) {
                results.append(north)
            }
        }
        
        let south = Point(x: start.x, y: start.y + 1)
        
        if south.y < map.count {
            let southPipe = map[south.y][south.x]
            
            if southPipe.directions.contains(.north) {
                results.append(south)
            }
        }
        
        let east = Point(x: start.x + 1, y: start.y)
        
        if east.x < map[0].count {
            let eastPipe = map[east.y][east.x]
            
            if eastPipe.directions.contains(.west) {
                results.append(east)
            }
        }
        
        let west = Point(x: start.x - 1, y: start.y)
        
        if west.x >= 0 {
            let westPipe = map[west.y][west.x]
            
            if westPipe.directions.contains(.east) {
                results.append(west)
            }
        }
        
        return results
    }
}
