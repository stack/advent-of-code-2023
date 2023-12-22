//
//  Day22.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-22.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day22: AdventDay {
    
    struct Brick: Hashable, CustomDebugStringConvertible {
        var id: UUID = UUID()
        var points: Set<Point3D>
        
        var minZ: Int {
            points.map { $0.z }.min()!
        }
        
        var movedDown: Brick {
            let nextPoints = Set(points.map { Point3D(x: $0.x, y: $0.y, z: $0.z - 1) })
            return Brick(id: id, points: nextPoints)
        }
        
        var debugDescription: String {
            let pointsString = points.sorted().map { $0.debugDescription }.joined(separator: ", ")
            return "\(id) -> \(pointsString)"
        }
    }
    
    var data: String
    
    var bricks: [Brick] {
        data.split(separator: "\n").map {
            let parts = $0.split(separator: "~")
                .map {
                    $0.split(separator: ",").map { Int($0)! }
                }
                .map {
                    Point3D(x: $0[0], y: $0[1], z: $0[2])
                }
            
            let lhsCoords = parts[0]
            let rhsCoords = parts[1]
            
            if lhsCoords.x != rhsCoords.x {
                return Brick(points: Set((lhsCoords.x ... rhsCoords.x).map { Point3D(x: $0, y: lhsCoords.y, z: lhsCoords.z) }))
            } else if lhsCoords.y != rhsCoords.y {
                return Brick(points: Set((lhsCoords.y ... rhsCoords.y).map { Point3D(x: lhsCoords.x, y: $0, z: lhsCoords.z) }))
            } else if lhsCoords.z != rhsCoords.z {
                return Brick(points: Set((lhsCoords.z ... rhsCoords.z).map { Point3D(x: lhsCoords.x, y: lhsCoords.y, z: $0) }))
            } else {
                return Brick(points: Set([lhsCoords]))
            }
        }
    }
    
    func part1() async throws -> Any {
        var bricks = self.bricks
        
        print("Start bricks:")
        print(bricks)
        
        while true {
            let map = supportedByMap(bricks: bricks)
            
            let unsupported = map.filter { (brick: Brick, supportedBy: [Brick]) in
                brick.minZ > 1 && supportedBy.isEmpty
            }
            
            guard !unsupported.isEmpty else { break }
            
            for index in 0 ..< bricks.count {
                let brick = bricks[index]
                
                if let _ = unsupported[brick] {
                    bricks[index] = brick.movedDown
                }
            }
        }
        
        print()
        print("Shifted bricks:")
        print(bricks)
        
        let graph = buildGraph(bricks: bricks)
        
        print()
        print("Graph:")
        
        for brick in bricks {
            print(graph[brick.id]!)
        }
        
        var canDisintegrate: [Brick] = []
        
        for brick in bricks {
            let brickNode = graph[brick.id]!
            let supportedBricks = brickNode.supports
            let supportedByCounts = supportedBricks.map { $0.supportedBy.count }
            
            if supportedByCounts.allSatisfy({ $0 > 1 }) {
                canDisintegrate.append(brick)
            }
        }
        
        return canDisintegrate.count
    }
    
    func part2() async throws -> Any {
        var bricks = self.bricks
        
        print("Start bricks:")
        print(bricks)
        
        while true {
            let map = supportedByMap(bricks: bricks)
            
            let unsupported = map.filter { (brick: Brick, supportedBy: [Brick]) in
                brick.minZ > 1 && supportedBy.isEmpty
            }
            
            guard !unsupported.isEmpty else { break }
            
            for index in 0 ..< bricks.count {
                let brick = bricks[index]
                
                if let _ = unsupported[brick] {
                    bricks[index] = brick.movedDown
                }
            }
        }
        
        print()
        print("Shifted bricks:")
        print(bricks)
        
        let graph = buildGraph(bricks: bricks)
        
        print()
        print("Graph:")
        
        for brick in bricks {
            print(graph[brick.id]!)
        }
        
        var canDisintegrate: [Brick] = []
        
        for brick in bricks {
            let brickNode = graph[brick.id]!
            let supportedBricks = brickNode.supports
            let supportedByCounts = supportedBricks.map { $0.supportedBy.count }
            
            if supportedByCounts.allSatisfy({ $0 > 1 }) {
                canDisintegrate.append(brick)
            }
        }
        
        let toDisintegrate = bricks.filter { !canDisintegrate.contains($0) }
        
        return toDisintegrate.map { willDrop(brick: $0, graph: graph).count }.reduce(0, +)
    }
    
    private func willDrop(brick: Brick, graph: [UUID:BrickNode]) -> Set<Brick> {
        willDrop(falling: Set(graph[brick.id]!.supports.map { $0.brick }), graph: graph)
    }
    
    private func willDrop(falling: Set<Brick>, graph: [UUID:BrickNode]) -> Set<Brick> {
        var supportedBricks = falling
        
        for (_, node) in graph {
            let supportedBy = Set(node.supportedBy.map { $0.brick })
            
            if !supportedBy.isEmpty && supportedBy.isSubset(of: falling) {
                supportedBricks.insert(node.brick)
            }
        }
        
        if supportedBricks == falling {
            return supportedBricks
        } else {
            return willDrop(falling: supportedBricks, graph: graph)
        }
    }
    
    class BrickNode: CustomDebugStringConvertible {
        let brick: Brick
        var supports: [BrickNode] = []
        var supportedBy: [BrickNode] = []
        
        init(brick: Brick) {
            self.brick = brick
        }
        
        var debugDescription: String {
            "\(brick)\n|-\(supports.map { $0.brick.id })\n`-\(supportedBy.map { $0.brick.id})"
        }
    }
    
    private func buildGraph(bricks: [Brick]) -> [UUID:BrickNode] {
        var nodes: [UUID:BrickNode] = [:]
        
        for brick in bricks {
            nodes[brick.id] = BrickNode(brick: brick)
        }
        
        for brick in bricks {
            for otherBrick in bricks {
                guard brick.id != otherBrick.id else { continue }
                
                let brickNode = nodes[brick.id]!
                let otherBrickNode = nodes[otherBrick.id]!
                
                let movedBrick = brick.movedDown
                
                if !movedBrick.points.intersection(otherBrick.points).isEmpty {
                    otherBrickNode.supports.append(brickNode)
                    brickNode.supportedBy.append(otherBrickNode)
                }
            }
        }
        
        return nodes
    }
    
    private func supportedByMap(bricks: [Brick]) -> [Brick:[Brick]] {
        var results: [Brick:[Brick]] = [:]
        
        for brick in bricks {
            var supportedBy: [Brick] = []
            let movedBrick = brick.movedDown
            
            for otherBrick in bricks {
                guard brick.id != otherBrick.id else { continue }
                
                if !otherBrick.points.intersection(movedBrick.points).isEmpty {
                    supportedBy.append(otherBrick)
                }
            }
            
            results[brick] = supportedBy
        }
        
        return results
    }
}
