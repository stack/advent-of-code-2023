//
//  Day7.swift
//  Advent of Code 2023
//
//  Created by Stephen H. Gerstacker on 2023-12-07.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day7: AdventDay {
    
    enum HandType {
        case fiveOfAKind
        case fourOfAKind
        case fullHouse
        case threeOfAKind
        case twoPair
        case onePair
        case highCard
        
        var rank: Int {
            switch self {
            case .fiveOfAKind:
                6
            case .fourOfAKind:
                5
            case .fullHouse:
                4
            case .threeOfAKind:
                3
            case .twoPair:
                2
            case .onePair:
                1
            case .highCard:
                0
            }
        }
    }
    
    enum Card: CustomDebugStringConvertible, Equatable {
        case ace
        case king
        case queen
        case jack
        case number(Int)
        
        var altValue: Int {
            guard self != .jack else { return 1 }
            
            return value
        }
        
        var value: Int {
            switch self {
            case .ace:
                14
            case .king:
                13
            case .queen:
                12
            case .jack:
                11
            case .number(let int):
                int
            }
        }
        
        var debugDescription: String {
            switch self {
            case .ace:
                "A"
            case .king:
                "K"
            case .queen:
                "Q"
            case .jack:
                "J"
            case .number(let value):
                value == 10 ? "T" : "\(value)"
            }
        }
    }
    
    struct Hand: Comparable, CustomDebugStringConvertible {
        var type: HandType
        var cards: [Card]
        var bid: Int
        
        var debugDescription: String {
            return "\(cards): \(type) -> \(bid)"
        }
    
        static func <(lhs: Hand, rhs: Hand) -> Bool {
            if lhs.type.rank != rhs.type.rank {
                return lhs.type.rank < rhs.type.rank
            } else {
                for (l, r) in zip(lhs.cards, rhs.cards) {
                    if l != r {
                        return l.value < r.value
                    }
                }
            }
            
            return false
        }
        
        static func altCompare(lhs: Hand, rhs: Hand) -> Bool {
            if lhs.type.rank != rhs.type.rank {
                return lhs.type.rank < rhs.type.rank
            } else {
                for (l, r) in zip(lhs.cards, rhs.cards) {
                    if l != r {
                        return l.altValue < r.altValue
                    }
                }
            }
            
            return false
        }
        
        static func altParse(cards: Substring, bid: Substring) -> Hand {
            let cardList = makeList(cards: cards)
            let type = cardList.contains(.jack) ? determineAltType(cards: cardList) : determineType(cards: cardList)
            
            return Hand(type: type, cards: cardList, bid: Int(String(bid))!)
        }
        
        static func parse(cards: Substring, bid: Substring) -> Hand {
            let cardList = makeList(cards: cards)
            let type = determineType(cards: cardList)
            
            return Hand(type: type, cards: cardList, bid: Int(String(bid))!)
        }
        
        private static func determineAltType(cards: [Card]) -> HandType {
            precondition(cards.count == 5)
            
            let jokerCards = cards.filter { $0 == .jack }
            let otherCards = cards.filter { $0 != .jack }
            
            var counts = [Int](repeating: 0, count: 15)
            
            for card in otherCards {
                counts[card.value] += 1
            }
            
            let altCounts = counts.map { $0 + jokerCards.count }
            
            if altCounts.contains(5) {
                return .fiveOfAKind
            } else if altCounts.contains(4) {
                return .fourOfAKind
            }
            
            let threes = counts.filter { $0 == 3 }
            let twos = counts.filter { $0 == 2 }
            let ones = counts.filter { $0 == 1 }
            
            if jokerCards.count == 3 && twos.count > 0 {
                return .fullHouse
            } else if jokerCards.count == 2 && threes.count > 0 {
                return .fullHouse
            } else if jokerCards.count == 2 && twos.count > 0 && ones.count > 0 {
                return .fullHouse
            } else if jokerCards.count == 1 && twos.count > 1 {
                return .fullHouse
            }
            
            if altCounts.contains(3) {
                return .threeOfAKind
            }
            
            if jokerCards.count == 2 && counts.contains(2) {
                return .twoPair
            } else if jokerCards.count == 1 && counts.contains(2) && counts.contains(1) {
                return .twoPair
            }
            
            if jokerCards.count == 1 {
                return .onePair
            }
            
            return .highCard
        }
        
        private static func determineType(cards: [Card]) -> HandType {
            precondition(cards.count == 5)
            
            var counts = [Int](repeating: 0, count: 15)
            
            for card in cards {
                counts[card.value] += 1
            }
            
            if counts.contains(5) {
                return .fiveOfAKind
            } else if counts.contains(4) {
                return .fourOfAKind
            } else if counts.contains(3) {
                if counts.contains(2) {
                    return .fullHouse
                } else {
                    return .threeOfAKind
                }
            } else {
                let twos = counts.filter { $0 == 2 }
                
                if twos.count == 2 {
                    return .twoPair
                } else if twos.count == 1 {
                    return .onePair
                }
            }
            
            return .highCard
        }
        
        private static func makeList(cards: Substring) -> [Card] {
            cards.map {
                switch $0 {
                case "A":
                    return .ace
                case "K":
                    return .king
                case "Q":
                    return .queen
                case "J":
                    return .jack
                case "T":
                    return .number(10)
                default:
                    return .number(Int(String($0))!)
                }
            }
        }
    }
    
    var data: String
    
    var altHands: [Hand] {
        data.split(separator: "\n").map { line in
            let parts = line.split(separator: " ")
            return Hand.altParse(cards: parts[0], bid: parts[1])
        }
    }
    
    var hands: [Hand] {
        data.split(separator: "\n").map { line in
            let parts = line.split(separator: " ")
            return Hand.parse(cards: parts[0], bid: parts[1])
        }
    }
    
    func part1() async throws -> Any {
        hands
            .sorted()
            .enumerated()
            .map { idx, hand in hand.bid * (idx + 1) }
            .reduce(0, +)
    }
    
    func part2() async throws -> Any {
        altHands
            .sorted(by: Hand.altCompare)
            .enumerated()
            .map { idx, hand in hand.bid * (idx + 1) }
            .reduce(0, +)
    }
}
