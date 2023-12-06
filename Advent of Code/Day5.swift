//
//  Day5.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-05.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day5: AdventDay {
    
    struct Map {
        var source: String
        var destination: String
        var sourceRange: Range<Int>
        var destinationRange: Range<Int>
        
        var name: String {
            "\(source)-\(destination)"
        }
        
        var distance: Int {
            destinationRange.lowerBound - sourceRange.lowerBound
        }
        
        func contains(source: Int) -> Bool {
            sourceRange.contains(source)
        }
        
        func intersects(source: Range<Int>) -> Bool {
            if source.lowerBound > sourceRange.upperBound - 1 || sourceRange.lowerBound > source.upperBound - 1 {
                return false
            } else {
                return true
            }
        }
        
        func map(_ source: Int) -> Int {
            guard contains(source: source) else { return -1 }
            
            return source - sourceRange.lowerBound + destinationRange.lowerBound
        }
        
        func split(source: Range<Int>) -> (Range<Int>, [Range<Int>]) {
            var results: [Range<Int>] = []
            
            if source.lowerBound < sourceRange.lowerBound {
                results.append(source.lowerBound ..< sourceRange.lowerBound)
            }
            
            if source.upperBound > sourceRange.upperBound {
                results.append(sourceRange.upperBound ..< source.upperBound)
            }
            
            let lhs = max(sourceRange.lowerBound, source.lowerBound) + distance
            let rhs = min(sourceRange.upperBound, source.upperBound) + distance
            let converted = lhs ..< rhs
            
            return (converted, results)
        }
    }
    
    var data: String
    
    var maps: [Map] {
        var source: String = "ERROR"
        var destination: String = "ERROR"
        var maps: [Map] = []
        
        for line in data.split(separator: "\n").dropFirst() {
            if let match = line.firstMatch(of: /(\S+)-to-(\S+) map:/) {
                source = String(match.1)
                destination = String(match.2)
            } else {
                let parts = line.split(separator: " ").map { Int($0)! }
                let map = Map(source: source, destination: destination, sourceRange: parts[1] ..< parts[1] + parts[2], destinationRange: parts[0] ..< parts[0] + parts[2])
                maps.append(map)
            }
        }
        
        return maps
    }
    
    var organizedMaps: [String:[Map]] {
        var result: [String:[Map]] = [:]
        
        for map in maps {
            var current = result[map.name] ?? []
            current.append(map)
            result[map.name] = current
        }
        
        return result
    }
    
    var seeds: [Int] {
        let line = data.split(separator: "\n", maxSplits: 1).first!
        return line.split(separator: " ").compactMap { Int($0) }
    }
    
    func part1() async throws -> Any {
        let maps = organizedMaps
        var lowest: Int = .max
        
        let path = ["seed", "soil", "fertilizer", "water", "light", "temperature", "humidity", "location"]
        for seed in seeds {
            print("Seed \(seed)")
            var currentIndex = seed
            
            for pair in path.adjacentPairs() {
                let name = "\(pair.0)-\(pair.1)"
                print("- Checking \(name) for \(currentIndex)")
                
                if let map = maps[name]?.first(where: { $0.contains(source: currentIndex) }) {

                    let nextIndex = map.map(currentIndex)
                    print("- Mapped \(currentIndex) to \(nextIndex)")
                    currentIndex = nextIndex
                } else {
                    print("- Direct map to \(currentIndex)")
                }
            }
            
            lowest = min(currentIndex, lowest)
        }
        
        return lowest
    }
    
    func part2() async throws -> Any {
        var seedGroups = self.seeds.chunks(ofCount: 2).map {
            let start = $0[$0.startIndex]
            let count = $0[$0.index(after: $0.startIndex)]
            
            return (start ..< start + count)
        }
        
        let maps = organizedMaps
        let path = ["seed", "soil", "fertilizer", "water", "light", "temperature", "humidity", "location"]
        let names = path.adjacentPairs().map { "\($0.0)-\($0.1)" }
        
        var currentSeedGroups = seedGroups
        
        for name in names {
            // print("Working \(name)")
            
            var nextSeedGroups: [Range<Int>] = []
            let mapList = maps[name]!
            
            print("\(name):")
            print("Ranges In: \(currentSeedGroups)")
            
            while !currentSeedGroups.isEmpty {
                let currentSeedGroup = currentSeedGroups.removeFirst()
                
                if let map = mapList.first(where: { $0.intersects(source: currentSeedGroup) }) {
                    // print("Map \(map) intersects with \(seedGroup)")
                    let (modified, others) = map.split(source: currentSeedGroup)
                    // print("Results: \(results)")
                    nextSeedGroups.append(modified)
                    currentSeedGroups.append(contentsOf: others)
                } else {
                    // print("Direct transfer of \(seedGroup)")
                    nextSeedGroups.append(currentSeedGroup)
                }
            }
            
            currentSeedGroups = nextSeedGroups
            print("Ranges Out: \(currentSeedGroups)")
        }
        
        print("Final seed groups: \(currentSeedGroups)")
        
        return currentSeedGroups.min(by: { $0.lowerBound < $1.lowerBound })!.lowerBound
    }
}
