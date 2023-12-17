//
//  Day16.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-16.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day16: AdventDay {
    
    enum Direction: CustomDebugStringConvertible {
        case north
        case south
        case east
        case west
        
        var debugDescription: String {
            switch self {
            case .north: "^"
            case .south: "v"
            case .east: ">"
            case .west: "<"
            }
        }
    }
    
    enum Tile: String, CustomDebugStringConvertible {
        case backslash = "\\"
        case forwardslash = "/"
        case verticalPipe = "|"
        case horizontalPipe = "-"
        
        var debugDescription: String {
            rawValue
        }
        
        func modify(_ beam: Beam) -> [Beam] {
            switch self {
            case .backslash:
                [ modifyBackslash(beam) ]
            case .forwardslash:
                [ modifyForwardslash(beam) ]
            case .verticalPipe:
                modifyVerticalPipe(beam)
            case .horizontalPipe:
                modifyHorizontalPipe(beam)
            }
        }
        
        private func modifyBackslash(_ beam: Beam) -> Beam {
            switch beam.direction {
            case .north:
                Beam(direction: .west, position: beam.position)
            case .south:
                Beam(direction: .east, position: beam.position)
            case .east:
                Beam(direction: .south, position: beam.position)
            case .west:
                Beam(direction: .north, position: beam.position)
            }
        }
        
        private func modifyForwardslash(_ beam: Beam) -> Beam {
            switch beam.direction {
            case .north:
                Beam(direction: .east, position: beam.position)
            case .south:
                Beam(direction: .west, position: beam.position)
            case .east:
                Beam(direction: .north, position: beam.position)
            case .west:
                Beam(direction: .south, position: beam.position)
            }
        }
        
        private func modifyHorizontalPipe(_ beam: Beam) -> [Beam] {
            switch beam.direction {
            case .north, .south:
                [ Beam(direction: .east, position: beam.position), Beam(direction: .west, position: beam.position)]
            case .east, .west:
                [ beam ]
            }
        }
        
        private func modifyVerticalPipe(_ beam: Beam) -> [Beam] {
            switch beam.direction {
            case .north, .south:
                [ beam ]
            case .east, .west:
                [ Beam(direction: .north, position: beam.position), Beam(direction: .south, position: beam.position)]
            }
        }
    }
    
    struct Beam: CustomDebugStringConvertible, Hashable {
        var direction: Direction
        var position: Point
        
        func stepped() -> Beam {
            var next = self
            
            switch direction {
            case .north:
                next.position = Point(x: position.x, y: position.y - 1)
            case .south:
                next.position = Point(x: position.x, y: position.y + 1)
            case .east:
                next.position = Point(x: position.x + 1, y: position.y)
            case .west:
                next.position = Point(x: position.x - 1, y: position.y)
            }
            
            return next
        }
        
        var debugDescription: String {
            "\(position) \(direction)"
        }
    }
    
    var data: String
    var tiles: [Point:Tile] {
        var tiles: [Point:Tile] = [:]
        
        for (y, line) in data.split(separator: "\n").enumerated() {
            for (x, char) in line.enumerated() {
                guard char != "." else { continue }
                
                let point = Point(x: x, y: y)
                tiles[point] = Tile(rawValue: String(char))!
            }
        }
        
        return tiles
    }
    
    func part1() async throws -> Any {
        run(start: Beam(direction: .east, position: .zero))
    }
    
    func part2() async throws -> Any {
        let tiles = self.tiles
        let maxX = tiles.keys.map { $0.x }.max()!
        let maxY = tiles.keys.map { $0.y }.max()!
        
        var beams: [Beam] = []
        
        for x in 0 ... maxX {
            beams.append(Beam(direction: .south, position: Point(x: x, y: 0)))
            beams.append(Beam(direction: .north, position: Point(x: x, y: maxY)))
        }
        
        for y in 0 ... maxY {
            beams.append(Beam(direction: .east, position: Point(x: 0, y: y)))
            beams.append(Beam(direction: .west, position: Point(x: maxX, y: y)))
        }
        
        var maxValue = 0
        
        for beam in beams {
            maxValue = max(maxValue, run(start: beam))
        }
        
        return maxValue
    }
    
    private func run(start: Beam) -> Int {
        let tiles = self.tiles
        let maxX = tiles.keys.map { $0.x }.max()!
        let maxY = tiles.keys.map { $0.y }.max()!
        
        var beams = [start]
        var energized: Set<Beam> = []
        
        while !beams.isEmpty {
            let beam = beams.removeFirst()
            
            guard beam.position.x >= 0 && beam.position.x <= maxX else { continue }
            guard beam.position.y >= 0 && beam.position.y <= maxY else { continue }
            
            guard !energized.contains(beam) else { continue }
            energized.insert(beam)
            

            if let tile = tiles[beam.position] {
                beams.append(contentsOf: tile.modify(beam).map { $0.stepped() })
            } else {
                beams.append(beam.stepped())
            }
        }
        
        return Array(energized.map { $0.position }.uniqued()).count
    }
}
