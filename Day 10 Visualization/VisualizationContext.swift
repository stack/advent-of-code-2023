//
//  VisualizationContext.swift
//  Advent of Code 2023 Day 10 Visualization
//
//  Created by Stephen H. Gerstacker on 2023-12-10.
//  SPDX-License-Identifier: MIT
//

import Foundation
import QuartzCore
import Utilities
import Visualization

class VisualizationContext: Solution2DContext {
    
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
    
    override var name: String {
        "Day 10"
    }
    
    override func run() async throws {
        let dataURL = Bundle.main.url(forResource: "Day10", withExtension: "txt")!
        let data = try String(contentsOf: dataURL)
        var map = data.split(separator: "\n").map {
            $0.map { Pipe(rawValue: String($0))! }
        }
        
        let start = findStart(in: map)!
        map[start.y][start.x] = determineType(from: start, in: map)
        
        var insidePoints: Set<Point> = []
        var outsidePoints: Set<Point> = []
        
        try draw(start: start, map: map)
        
        var visited: Set<Point> = [start]
        var toVisit: [(Point, Int)] = findNext(from: start, map: map).map { ($0, 1) }
        
        while !toVisit.isEmpty {
            let (current, distance) = toVisit.removeFirst()
            
            guard !visited.contains(current) else { continue }
            visited.insert(current)
            
            try draw(start: start, points: visited, insides: insidePoints, outsides: outsidePoints, map: map)
            
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
        
        for (y, line) in map.enumerated() {
            for (x, pipe) in line.enumerated() {
                let point = Point(x: x, y: y)
                
                guard pipe == .none || !visited.contains(point) else { continue }
                
                var count = 0
                var testPoints: Set<Point> = []
                var testHits: Set<Point> = []
                
                for x in 0 ..< point.x {
                    let testPoint = Point(x: x, y: point.y)
                    testPoints.insert(testPoint)
                    
                    guard visited.contains(testPoint) else { continue }
                    
                    let testPipe = map[point.y][x]
                    
                    if testPipe == .vertical || testPipe == .sevenBend || testPipe == .fBend {
                        testHits.insert(testPoint)
                        count += 1
                    }
                }
                
                if count % 2 == 0 {
                    outsidePoints.insert(point)
                } else {
                    insidePoints.insert(point)
                }
                
                try draw(start: start, points: visited, insides: insidePoints, outsides: outsidePoints, testPoints: testPoints, testHits: testHits, map: map)
            }
        }
    }
    
    private func draw(start: Point, points: Set<Point> = [], insides: Set<Point> = [], outsides: Set<Point> = [], testPoints: Set<Point> = [], testHits: Set<Point> = [], map: Map) throws {
        let cellWidth = floor(CGFloat(width) / CGFloat(map[0].count))
        let cellHeight = floor(CGFloat(height) / CGFloat(map.count))
        let lineWidth = min(cellWidth * 0.5, cellHeight * 0.5)
        
        let backgroundColor = CGColor(gray: 0.0, alpha: 1.0)
        let pipeBackgroundColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let outsideBackground = CGColor(gray: 0.2, alpha: 1.0)
        let insideBackground = CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        let startBackgroundColor = CGColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        let pipeColor = CGColor(gray: 1.0, alpha: 1.0)
        let testPointColor = CGColor(gray: 1.0, alpha: 0.25)
        let testHitColor = CGColor(gray: 1.0, alpha: 0.5)
        
        let (context, pixelBuffer) = try nextContext()
        
        let backgroundBox = CGRect(origin: .zero, size: CGSize(width: context.width, height: context.height))
        fill(rect: backgroundBox, color: backgroundColor, in: context)
        
        for point in points {
            let pipe = map[point.y][point.x]
            let cellBox = CGRect(x: CGFloat(point.x) * cellWidth, y: CGFloat(point.y) * cellHeight, width: cellWidth, height: cellHeight)
            
            if point == start {
                fill(rect: cellBox, color: startBackgroundColor, in: context)
            } else if pipe != .none || pipe != .start {
                fill(rect: cellBox, color: pipeBackgroundColor, in: context)
            }
            
            switch pipe {
            case .vertical:
                let lineBox = CGRect(x: cellBox.midX - (lineWidth / 2.0), y: cellBox.minY, width: lineWidth, height: cellBox.height)
                fill(rect: lineBox, color: pipeColor, in: context)
            case .lBend, .jBend:
                let lineBox = CGRect(x: cellBox.midX - (lineWidth / 2.0), y: cellBox.minY, width: lineWidth, height: (cellBox.height / 2.0) + (lineWidth / 2.0))
                fill(rect: lineBox, color: pipeColor, in: context)
            case .sevenBend, .fBend:
                let lineBox = CGRect(x: cellBox.midX - (lineWidth / 2.0), y: cellBox.midY - (lineWidth / 2.0), width: lineWidth, height: (cellBox.height / 2.0) + (lineWidth / 2.0))
                fill(rect: lineBox, color: pipeColor, in: context)
            default:
                break
            }
            

            switch pipe {
            case .horizontal:
                let lineBox = CGRect(x: cellBox.minX, y: cellBox.midY - (lineWidth / 2.0), width: cellBox.width, height: lineWidth)
                fill(rect: lineBox, color: pipeColor, in: context)
            case .lBend, .fBend:
                let lineBox = CGRect(x: cellBox.midX - (lineWidth / 2.0), y: cellBox.midY - (lineWidth / 2.0), width: (cellBox.width / 2.0) + (lineWidth / 2.0), height: lineWidth)
                fill(rect: lineBox, color: pipeColor, in: context)
            case .jBend, .sevenBend:
                let lineBox = CGRect(x: cellBox.minX, y: cellBox.midY - (lineWidth / 2.0), width: (cellBox.width / 2.0) + (lineWidth / 2.0), height: lineWidth)
                fill(rect: lineBox, color: pipeColor, in: context)
            default:
                break
            }
        }
        
        for point in insides {
            let cellBox = CGRect(x: CGFloat(point.x) * cellWidth, y: CGFloat(point.y) * cellHeight, width: cellWidth, height: cellHeight)
            fill(rect: cellBox, color: insideBackground, in: context)
        }
        
        for point in outsides {
            let cellBox = CGRect(x: CGFloat(point.x) * cellWidth, y: CGFloat(point.y) * cellHeight, width: cellWidth, height: cellHeight)
            fill(rect: cellBox, color: outsideBackground, in: context)
        }
        
        for point in testPoints {
            let cellBox = CGRect(x: CGFloat(point.x) * cellWidth, y: CGFloat(point.y) * cellHeight, width: cellWidth, height: cellHeight)
            let color = testHits.contains(point) ? testHitColor : testPointColor
            fill(rect: cellBox, color: color, in: context)
        }
        
        submit(context: context, pixelBuffer: pixelBuffer)
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
