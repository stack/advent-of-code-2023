//
//  Day21.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-22.
//

import Foundation

struct Day21: AdventDay {
    
    var data: String
    
    var plots: Set<Point> {
        var result = Set<Point>()
        
        for (y, line) in data.split(separator: "\n").enumerated() {
            for (x, spot) in line.enumerated() {
                if spot != "#" {
                    result.insert(Point(x: x, y: y))
                }
            }
        }
        
        return result
    }
    
    var start: Point {
        for (y, line) in data.split(separator: "\n").enumerated() {
            for (x, spot) in line.enumerated() {
                if spot == "S" {
                    return Point(x: x, y: y)
                }
            }
        }
        
        fatalError("Did not find the starting spot")
    }
    
    func part1() async throws -> Any {
        let plots = self.plots
        var positions: Set<Point> = [start]
        
        let (minX, maxX) = plots.map { $0.x }.minAndMax()!
        let (minY, maxY) = plots.map { $0.y }.minAndMax()!
        
        let maxSteps = maxX == 10 ? 6 : 64
        
        for _ in 0 ..< maxSteps {
            var nextPositions: Set<Point> = []
            
            for position in positions {
                let neighborPoints = position.cardinalNeighbors
                    .filter { $0.x >= minX && $0.x <= maxX && $0.y >= minY && $0.y <= maxY }
                    .filter { plots.contains($0) }
                
                for point in neighborPoints {
                    nextPositions.insert(point)
                }
            }
            
            positions = nextPositions
            
            printMap(positions: positions, plots: plots, width: maxX + 1, height: maxY + 1)
            
            print()
        }
        
        return positions.count
    }
    
    func part2() async throws -> Any {
        let plots = self.plots
        var positions: Set<Point> = [start]
        
        let width = plots.map { $0.x }.max()! + 1
        let height = plots.map { $0.y }.max()! + 1
        
        var cache: [Point:[Point]] = [:]
        var answers: [Int] = []
        
        let pointA = width / 2
        let pointB = pointA + width
        let pointC = pointB + width
        
        for step in 0 ..< 26501365 {
            var nextPositions: Set<Point> = []
            
            for position in positions {
                if let neighorPoints = cache[position] {
                    nextPositions.formUnion(neighorPoints)
                } else {
                    let neighborPoints = position.cardinalNeighbors
                        .filter {
                            let x = $0.x % width
                            let y = $0.y % height
                            
                            let innerPoint = Point(
                                x: x >= 0 ? x : x + width,
                                y: y >= 0 ? y : y + height
                            )
                            
                            return plots.contains(innerPoint)
                        }
                    
                    cache[position] = neighborPoints
                    
                    nextPositions.formUnion(neighborPoints)
                }
            }
            
            positions = nextPositions
            
            if step + 1 == pointA {
                print("Answer A at \(step + 1)")
                answers.append(positions.count)
            } else if step + 1 == pointB {
                print("Answer B at \(step + 1)")
                answers.append(positions.count)
            } else if step + 1 == pointC {
                print("Answer C at \(step + 1)")
                answers.append(positions.count)
                break
            }
            
            print("\(step): \(positions.count)")
        }
        
        let a = (answers[2] - (2 * answers[1]) + answers[0]) / 2
        let b = answers[1] - answers[0] - a
        let c = answers[0]
        let n = (26501365 - (width / 2)) / width
        
        let answer = (a * (n * n)) + (b * n) + c
        
        return answer
    }
    
    private func printMap(positions: Set<Point>, plots: Set<Point>, width: Int, height: Int) {
        for y in 0 ..< height {
            for x in 0 ..< width {
                let point = Point(x: x, y: y)
                if positions.contains(point) {
                    print("O", terminator: "")
                } else if plots.contains(point) {
                    print(".", terminator: "")
                } else {
                    print("#", terminator: "")
                }
            }
            
            print()
        }
    }
}
