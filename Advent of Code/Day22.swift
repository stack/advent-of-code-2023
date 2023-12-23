//
//  Day22.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-22.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day22: AdventDay {
    
    struct Brick: CustomDebugStringConvertible {
        var id: UUID = UUID()
        var point1: Point3D
        var point2: Point3D
        
        func overlaps(_ other: Brick) -> Bool {
            max(point1.x, other.point1.x) <= min(point2.x, other.point2.x) &&
            max(point1.y, other.point1.y) <= min(point2.y, other.point2.y)
        }
        
        var debugDescription: String {
            "\(id): \(point1) -> \(point2)"
        }
    }
    
    var data: String
    
    var bricks: [Brick] {
        data.split(separator: "\n").map { line in
            let parts = line.split(separator: "~").map {
                let coords = $0.split(separator: ",").map { Int($0)! }
                return Point3D(x: coords[0], y: coords[1], z: coords[2])
            }
            
            return Brick(point1: parts[0], point2: parts[1])
        }
    }

    func part1() async throws -> Any {
        let bricks = collapse(bricks: bricks)
        
        print(bricks)
        
        let (supports, supportedBy) = supportMaps(bricks: bricks)
        
        var total = 0
        
        for brickIndex in 0 ..< bricks.count {
            if supports[brickIndex]!.allSatisfy({ supportedBy[$0]!.count > 1 }) {
                total += 1
            }
        }
        
        return total
    }
    
    func part2() async throws -> Any {
        let bricks = collapse(bricks: bricks)
        let (supports, supportedBy) = supportMaps(bricks: bricks)
        
        var total = 0
        
        for brickIndex in 0 ..< bricks.count {
            var queue: [Int] = supports[brickIndex]!.filter { supportedBy[$0]!.count == 1 }
            
            var falling = Set(queue)
            falling.insert(brickIndex)
            
            while !queue.isEmpty {
                let nextIndex = queue.removeFirst()
                
                for supportedIndex in supports[nextIndex]!.subtracting(falling) {
                    if supportedBy[supportedIndex]!.isSubset(of: falling) {
                        queue.append(supportedIndex)
                        falling.insert(supportedIndex)
                    }
                }
            }
            
            total += falling.count - 1
        }
        
        return total
    }
    
    private func collapse(bricks: [Brick]) -> [Brick] {
        var bricks = self.bricks.sorted(by: { $0.point1.z < $1.point1.z })
        
        for (index, brick) in bricks.enumerated() {
            var targetZ = 1
            
            for otherBrick in bricks[..<index] {
                if brick.overlaps(otherBrick) {
                    targetZ = max(targetZ, otherBrick.point2.z + 1)
                }
            }
            
            bricks[index].point2.z -= brick.point1.z - targetZ
            bricks[index].point1.z = targetZ
        }
        
        return bricks.sorted(by: { $0.point1.z < $1.point1.z })
    }
    
    private func supportMaps(bricks: [Brick]) -> ([Int:Set<Int>], [Int:Set<Int>]) {
        var supports: [Int:Set<Int>] = [:]
        var supportedBy: [Int:Set<Int>] = [:]
        
        for index in 0 ..< bricks.count {
            supports[index] = []
            supportedBy[index] = []
        }
        
        for (upperIndex, upperBrick) in bricks.enumerated() {
            for (lowerIndex, lowerBrick) in bricks[..<upperIndex].enumerated() {
                if upperBrick.overlaps(lowerBrick) && upperBrick.point1.z == lowerBrick.point2.z + 1 {
                    supports[lowerIndex]!.insert(upperIndex)
                    supportedBy[upperIndex]!.insert(lowerIndex)
                }
            }
        }
        
        return (supports, supportedBy)
    }
}
