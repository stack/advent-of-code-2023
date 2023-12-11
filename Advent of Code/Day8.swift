//
//  Day8.swift
//  Advent of Code 2023
//
//  Created by Stephen H. Gerstacker on 2023-12-08.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day8: AdventDay {
    
    struct Map {
        var directions: String
        var nodes: [String:(String,String)]
        
        func run() -> Int {
            guard nodes.keys.contains("AAA") else { return -1 }
            
            var times = 0
            var current = "AAA"
            
            while current != "ZZZ" {
                current = runOnce(start: current)
                times += 1
            }
            
            return times * directions.count
        }
        
        func runOnce(start: String) -> String {
            var current = start
            
            for direction in directions {
                current = direction == "L" ? nodes[current]!.0 : nodes[current]!.1
            }
            
            return current
        }
    }
    
    var data: String
    
    var maps: [Map] {
        var map: Map? = nil
        var maps: [Map] = []
        
        for line in data.split(separator: "\n") {
            if let match = line.firstMatch(of: /(.{3}) = \((.{3}), (.{3})\)/) {
                map!.nodes[String(match.output.1)] = (String(match.output.2), String(match.output.3))
            } else {
                if let existingMap = map {
                    maps.append(existingMap)
                }
                
                map = Map(directions: String(line), nodes: [:])
            }
        }
        
        if let map {
            maps.append(map)
        }
        
        return maps
    }
    
    func part1() async throws -> Any {
        maps.map { $0.run() }
    }
    
    func part2() async throws -> Any {
        var totals: [Int] = []
        
        for map in maps {
            let jumps = map.nodes.keys.reduce([String:String]()) { dict, node in
                var dict = dict
                dict[node] = map.runOnce(start: node)
                return dict
            }
            
            let startKeys = map.nodes.keys.filter { $0.hasSuffix("A") }
            let endKeys = Set(map.nodes.keys.filter { $0.hasSuffix("Z") })
            
            let cycles = startKeys.map {
                var current = $0
                var times = 0
                
                while !endKeys.contains(current) {
                    current = jumps[current]!
                    times += 1
                }
                
                return times * map.directions.count
            }
            
            let reducedCycles = cycles.reduce(cycles[0], lcm)
            totals.append(reducedCycles)
        }
        
        return totals
    }
}
