//
//  Day14.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-14.
//

import Foundation

struct Day14: AdventDay {
    
    enum Square: CustomDebugStringConvertible, Hashable {
        case round
        case square
        case empty
        
        var debugDescription: String {
            switch self {
            case .round: "O"
            case .square: "#"
            case .empty: "."
            }
        }
    }
    
    struct Dish: CustomDebugStringConvertible, Hashable {
        var field: [[Square]]
        
        static func parse(data: any StringProtocol) -> Dish {
            let field = data.split(separator: "\n").map {
                $0.map {
                    switch $0 {
                    case "O":
                        return Square.round
                    case "#":
                        return Square.square
                    case ".":
                        return Square.empty
                    default:
                        fatalError("Unhandled square: \($0)")
                    }
                }
            }
            
            return Dish(field: field)
        }
        
        var debugDescription: String {
            field.map { $0.map { $0.debugDescription }.joined() }.joined(separator: "\n")
        }
        
        var load: Int {
            let distance = field.count
            
            var total = 0
            
            for (yIndex, line) in field.enumerated() {
                for square in line {
                    guard square == .round else { continue }
                    
                    total += distance - yIndex
                }
            }

            return total
        }
        
        func rolledEast() -> Dish {
            var nextField = field
            
            for yIndex in 0 ..< nextField.count {
                for xIndex in (0 ..< nextField[0].count - 1).reversed() {
                    guard nextField[yIndex][xIndex] == .round else { continue }
                    
                    var nextX: Int? = nil
                    
                    for testX in (xIndex + 1 ..< nextField[0].count) {
                        guard nextField[yIndex][testX] == .empty else { break }
                        
                        nextX = testX
                    }
                    
                    if let nextX {
                        nextField[yIndex][nextX] = nextField[yIndex][xIndex]
                        nextField[yIndex][xIndex] = .empty
                    }
                }
            }
            
            return Dish(field: nextField)
        }
        
        func rolledWest() -> Dish {
            var nextField = field
            
            for yIndex in 0 ..< nextField.count {
                for xIndex in 1 ..< nextField[0].count {
                    guard nextField[yIndex][xIndex] == .round else { continue }
                    
                    var nextX: Int? = nil
                    
                    for testX in (0 ..< xIndex).reversed() {
                        guard nextField[yIndex][testX] == .empty else { break }
                        
                        nextX = testX
                    }
                    
                    if let nextX {
                        nextField[yIndex][nextX] = nextField[yIndex][xIndex]
                        nextField[yIndex][xIndex] = .empty
                    }
                }
            }
            
            return Dish(field: nextField)
        }
        
        func rolledNorth() -> Dish {
            var nextField = field
            
            for yIndex in 1 ..< nextField.count {
                for xIndex in 0 ..< nextField[0].count {
                    guard nextField[yIndex][xIndex] == .round else { continue }
                    
                    var nextY: Int? = nil
                    
                    for testY in (0 ..< yIndex).reversed() {
                        guard nextField[testY][xIndex] == .empty else { break }

                        nextY = testY
                    }
                    
                    if let nextY {
                        nextField[nextY][xIndex] = nextField[yIndex][xIndex]
                        nextField[yIndex][xIndex] = .empty
                    }
                }
            }
            
            return Dish(field: nextField)
        }
        
        func rolledSouth() -> Dish {
            var nextField = field
            
            for yIndex in (0 ..< nextField.count - 1).reversed() {
                for xIndex in 0 ..< nextField[0].count {
                    guard nextField[yIndex][xIndex] == .round else { continue }
                    
                    var nextY: Int? = nil
                    
                    for testY in (yIndex + 1 ..< nextField.count) {
                        guard nextField[testY][xIndex] == .empty else { break }

                        nextY = testY
                    }
                    
                    if let nextY {
                        nextField[nextY][xIndex] = nextField[yIndex][xIndex]
                        nextField[yIndex][xIndex] = .empty
                    }
                }
            }
            
            return Dish(field: nextField)
        }
        
        func spin() -> Dish {
            var nextDish = self
            nextDish = nextDish.rolledNorth()
            nextDish = nextDish.rolledWest()
            nextDish = nextDish.rolledSouth()
            nextDish = nextDish.rolledEast()
            
            return nextDish
        }
    }
    
    var data: String
    var dish: Dish {
        Dish.parse(data: data)
    }
    
    func part1() async throws -> Any {
        let dish = self.dish
        print(dish)
        
        let nextDish = dish.rolledNorth()
        print()
        print(nextDish)
        
        let load = nextDish.load
        
        return load
    }
    
    func part2() async throws -> Any {
        var nextDish = dish
        var visited: Set<Dish> = []
        var path: [Dish] = []
        
        for cycle in 0 ..< 1000000000 {
            if visited.contains(nextDish) {
                let index = path.firstIndex(of: nextDish)!
                
                print("Found cycle after \(cycle) cycles starting at \(index)")
                
                let cycle = Array(path[index ..< cycle])
                
                let modulus = (1000000000 - index) % cycle.count
                let final = cycle[modulus]
                let load = final.load
                
                return load
            }
            
            visited.insert(nextDish)
            path.append(nextDish)
            nextDish = nextDish.spin()
        }
        
        return -1
    }
}
