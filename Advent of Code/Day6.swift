//
//  Day6.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-06.
//

import Foundation

struct Day6: AdventDay {
    
    var data: String
    
    var times: [Int] {
        data
            .split(separator: "\n")[0]
            .split(separator: " ")
            .dropFirst()
            .map { Int($0)! }
    }
    
    var allTimes: Int {
        let value = data
            .split(separator: "\n")[0]
            .split(separator: " ")
            .dropFirst()
            .joined()
        
        return Int(value)!
    }

    var distances: [Int] {
        data
            .split(separator: "\n")[1]
            .split(separator: " ")
            .dropFirst()
            .map { Int($0)! }
    }
    
    var allDistances: Int {
        let value = data
            .split(separator: "\n")[1]
            .split(separator: " ")
            .dropFirst()
            .joined()
        
        return Int(value)!
    }
    
    func part1() async throws -> Any {
        print("Times: \(times)")
        print("Distances: \(distances)")
        
        var wins: [Int] = []
        
        for (time, recordDistance) in zip(times, distances) {
            print("Max time: \(time), distance to beat: \(recordDistance)")
            
            var currentWins = 0
            
            for holdTime in 0 ... time {
                let runTime = time - holdTime
                let rate = holdTime
                let distance = rate * runTime
                
                print("- Hold for \(holdTime), rate \(rate), distance: \(distance)")
                
                if distance > recordDistance {
                    print(" - Winner")
                    currentWins += 1
                }
            }
            
            wins.append(currentWins)
        }
        
        return wins.reduce(1, *)
    }
    
    func part2() async throws -> Any {
        print("Time: \(allTimes)")
        print("Distance: \(allDistances)")
        
        var currentWins = 0
        let raceTime = allTimes
        let targetDistance = allDistances
        
        for holdTime in 0 ..< allTimes {
            let runTime = raceTime - holdTime
            let rate = holdTime
            let distance = rate * runTime
            
            // print("- Hold for \(holdTime), rate \(rate), distance: \(distance)")
            
            if distance > targetDistance {
                // print(" - Winner")
                currentWins += 1
            }
        }
        
        return currentWins
    }
}
