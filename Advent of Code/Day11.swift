//
//  Day11.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-11.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day11: AdventDay {
    
    struct PointSet: Hashable {
        var lhs: Point
        var rhs: Point
        
        var distance: Int {
            lhs.manhattenDistance(to: rhs)
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            if lhs.lhs == rhs.lhs && lhs.rhs == rhs.rhs {
                return true
            } else if lhs.lhs == rhs.rhs && lhs.rhs == rhs.lhs {
                return true
            } else {
                return false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            if lhs < rhs {
                hasher.combine(lhs)
                hasher.combine(rhs)
            } else {
                hasher.combine(rhs)
                hasher.combine(lhs)
            }
        }
    }
    
    var data: String
    
    var galaxies: [Point] {
        data.split(separator: "\n").enumerated().flatMap { line in
            line.element.enumerated().compactMap {
                $0.element == "#" ? Point(x: $0.offset, y: line.offset) : nil
            }
        }
    }
    
    func part1() async throws -> Any {
        let galaxies = galaxies(expandedBy: 1)
        var visited: Set<PointSet> = []
        var total: Int = 0
        
        for lhs in galaxies {
            for rhs in galaxies {
                guard lhs != rhs else { continue }
                
                let pointSet = PointSet(lhs: lhs, rhs: rhs)
                guard !visited.contains(pointSet) else { continue }
                
                total += pointSet.distance
                visited.insert(pointSet)
            }
        }
        
        return total
    }
    
    func part2() async throws -> Any {
        let galaxies = galaxies(expandedBy: 1000000 - 1)
        var visited: Set<PointSet> = []
        var total: Int = 0
        
        for lhs in galaxies {
            for rhs in galaxies {
                guard lhs != rhs else { continue }
                
                let pointSet = PointSet(lhs: lhs, rhs: rhs)
                guard !visited.contains(pointSet) else { continue }
                
                total += pointSet.distance
                visited.insert(pointSet)
            }
        }
        
        return total
    }
    
    private func galaxies(expandedBy factor: Int) -> [Point] {
        var galaxies = self.galaxies
        
        let xPoints = Set(galaxies.map { $0.x })
        let yPoints = Set(galaxies.map { $0.y })
        
        let maxX = xPoints.max() ?? .zero
        let maxY = yPoints.max() ?? .zero
        
        let missingXs = Set(0 ..< maxX).subtracting(xPoints)
        let missingYs = Set(0 ..< maxY).subtracting(yPoints)
        
        for missingX in missingXs.sorted().reversed() {
            galaxies = galaxies.map {
                if $0.x > missingX {
                    Point(x: $0.x + factor, y: $0.y)
                } else {
                    $0
                }
            }
        }
        
        for missingY in missingYs.sorted().reversed() {
            galaxies = galaxies.map {
                if $0.y > missingY {
                    Point(x: $0.x, y: $0.y + factor)
                } else {
                    $0
                }
            }
        }
        
        return galaxies
    }
}
