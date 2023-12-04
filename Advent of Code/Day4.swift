//
//  Day4.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-04.
//

import Foundation

struct Day4: AdventDay {
    
    struct Card {
        var id: Int
        var winningNumbers: Set<Int>
        var yourNumbers: Set<Int>
        
        let points: Int
        let wins: Int
        
        init(id: Int, winningNumbers: Set<Int>, yourNumbers: Set<Int>) {
            self.id = id
            self.winningNumbers = winningNumbers
            self.yourNumbers = yourNumbers
            
            let intersection = winningNumbers.intersection(yourNumbers)
            
            if intersection.isEmpty {
                points = 0
            } else {
                points =  2 ^^ (intersection.count - 1)
            }
            
            wins = intersection.count
        }
    }
    
    var data: String
    
    var cards: [Card] {
        data.split(separator: "\n").map {
            let firstParts = $0.split(separator: ": ")
            let cardParts = firstParts[0].split(separator: " ")
            let secondParts = firstParts[1].split(separator: " | ")
            let winningParts = secondParts[0].split(separator: " ")
            let yourParts = secondParts[1].split(separator: " ")
            
            return Card(
                id: Int(cardParts[1])!,
                winningNumbers: Set(winningParts.map { Int($0)! }),
                yourNumbers: Set(yourParts.map { Int($0)! })
            )
        }
    }
    
    func part1() async throws -> Any {
        cards.reduce(0) { $0 + $1.points }
    }
    
    func part2() async throws -> Any {
        let cards = self.cards
        let wins = cards.map {
            Array($0.id ..< $0.id + $0.wins)
        }
        
        var totals = [Int](repeating: 1, count: wins.count)
        
        for currentIdx in 0 ..< totals.count {
            let winIndexes = wins[currentIdx]
            
            for winIndex in winIndexes {
                totals[winIndex] += totals[currentIdx]
            }
        }
        
        return totals.reduce(0, +)
    }
}
