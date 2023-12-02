//
//  Day2.swift
//  Advent of Code 2023
//
//  Created by Stephen H. Gerstacker on 2023-12-02.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day2: AdventDay {
    
    struct Game {
        var id: Int
        var reds: [Int]
        var greens: [Int]
        var blues: [Int]
        
        var maxReds: Int {
            reds.max() ?? 0
        }
        
        var maxGreens: Int {
            greens.max() ?? 0
        }
        
        var maxBlues: Int {
            blues.max() ?? 0
        }
        
        init(rawData: Substring) {
            let parts = rawData.split(separator: ": ", maxSplits: 2)
            
            let id = parts[0].firstMatch(of: /(\d+)/)?.1
            self.id = Int(id!)!
            
            let combinations = parts[1].split(separator: "; ").map {
                let reds = $0.firstMatch(of: /(\d+) red/)?.1
                let greens = $0.firstMatch(of: /(\d+) green/)?.1
                let blues = $0.firstMatch(of: /(\d+) blue/)?.1
                
                return (
                    Int(reds ?? "0")!,
                    Int(greens ?? "0")!,
                    Int(blues ?? "0")!
                )
            }
            
            reds = combinations.map { $0.0 }
            greens = combinations.map { $0.1 }
            blues = combinations.map { $0.2 }
        }
        
        func isPossible(reds: Int, greens: Int, blues: Int) -> Bool {
            reds >= maxReds && greens >= maxGreens && blues >= maxBlues
        }
        
        var power: Int {
            maxReds * maxGreens * maxBlues
        }
    }
    
    var data: String
    var games: [Game] {
        data.split(separator: "\n").map { Game(rawData: $0) }
    }
    
    let targetReds = 12
    let targetGreens = 13
    let targetBlues = 14
    
    func part1() async throws -> Any {
        games
            .filter { $0.isPossible(reds: targetReds, greens: targetGreens, blues: targetBlues) }
            .reduce(0) { $0 + $1.id }
    }
    
    func part2() async throws -> Any {
        games.reduce(0) { $0 + $1.power }
    }
}
