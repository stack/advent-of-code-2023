//
//  Day20.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-20.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Pulse {
    var value: Bool
    var from: String
    var to: String
}

protocol Module {
    var name: String { get }
    var next: [String] { get }
    
    func receive(_ pulse: Bool, from: String) -> [Pulse]
}

struct Day20: AdventDay {
    
    class Button: Module, CustomDebugStringConvertible {
        let name: String = "button"
        let next: [String] = ["broadcaster"]
        
        func receive(_ pulse: Bool, from: String) -> [Pulse] {
            return next.map { Pulse(value: false, from: name, to: $0) }
        }
        
        var debugDescription: String {
            "\(name) -> \(next.joined(separator: ", "))"
        }
    }
    
    class Output: Module, CustomDebugStringConvertible {
        let name: String = "output"
        let next: [String] = []
        
        func receive(_ pulse: Bool, from: String) -> [Pulse] {
            return []
        }
        
        var debugDescription: String {
            "\(name)"
        }
    }
    
    class FlipFlop: Module, CustomDebugStringConvertible {
        let name: String
        let next: [String]
        
        private var state: Bool = false
        
        init(name: String, next: [String]) {
            self.name = name
            self.next = next
        }
        
        func receive(_ pulse: Bool, from: String) -> [Pulse] {
            guard !pulse else {
                return []
            }
            
            state.toggle()
            
            return next.map { Pulse(value: state, from: name, to: $0) }
        }
        
        var debugDescription: String {
            "%\(name) -> \(next.joined(separator: ", "))"
        }
    }
    
    class Conjunction: Module, CustomDebugStringConvertible {
        let name: String
        let next: [String]
        
        var state: [String:Bool] = [:]
        
        init(name: String, next: [String]) {
            self.name = name
            self.next = next
        }
        
        func receive(_ pulse: Bool, from: String) -> [Pulse] {
            state[from] = pulse
            
            if state.values.allSatisfy({ $0 }) {
                return next.map { Pulse(value: false, from: name, to: $0) }
            } else {
                return next.map { Pulse(value: true, from: name, to: $0) }
            }
        }
        
        var debugDescription: String {
            "&\(name) -> \(next.joined(separator: ", "))"
        }
    }
    
    class Broadcast: Module, CustomDebugStringConvertible {
        let name: String
        let next: [String]
        
        init(name: String, next: [String]) {
            self.name = name
            self.next = next
        }
        
        func receive(_ pulse: Bool, from: String) -> [Pulse] {
            return next.map { Pulse(value: pulse, from: name, to: $0) }
        }
        
        var debugDescription: String {
            "\(name) -> \(next.joined(separator: ", "))"
        }
    }
    
    var data: String
    
    var modules: [[Module]] {
        data.split(separator: "\n\n").map { group -> [Module] in
            group.split(separator: "\n").map { line -> Module in
                let parts = line.split(separator: " -> ")
                let name = String(parts[0])
                let targets = parts[1].split(separator: ", ").map { String($0) }
                
                let nextIndex = name.index(after: name.startIndex)
                
                if name == "broadcaster" {
                    return Broadcast(name: name, next: targets)
                } else if name.hasPrefix("%") {
                    return FlipFlop(name: String(name[nextIndex...]), next: targets)
                } else if name.hasPrefix("&") {
                    return Conjunction(name: String(name[nextIndex...]), next: targets)
                } else {
                    fatalError("Invalid module name: \(name)")
                }
            }
        }
    }
    
    var moduleMaps: [[String:Module]] {
        var maps: [[String:Module]] = []
        
        for group in modules {
            var map: [String:Module] = [:]
            
            for module in group {
                map[module.name] = module
            }
            
            maps.append(map)
        }
        
        return maps
    }
    
    func part1() async throws -> Any {
        let moduleMaps = self.moduleMaps
        
        var totals: [Int] = []
        
        for var map in moduleMaps {
            let button = Button()
            map["button"] = button
            
            let output = Output()
            map["output"] = output
            
            let conjunctionModules = map.values.compactMap { $0 as? Conjunction }
            
            for conjunctionModule in conjunctionModules {
                for outputModule in map.values {
                    if outputModule.next.contains(where: { $0 == conjunctionModule.name }) {
                        conjunctionModule.state[outputModule.name] = false
                        // print("\(outputModule.name) -> \(conjunctionModule.name)")
                    }
                }
            }
            
            var pressed = 0
            var lows: Int = 0
            var highs: Int = 0
            
            while pressed < 1000 {
                var queue: [Pulse] = button.receive(false, from: "")
                
                while !queue.isEmpty {
                    let currentPulse = queue.removeFirst()
                    
                    if currentPulse.value == false {
                        lows += 1
                    } else {
                        highs += 1
                    }
                    
                    
                    guard let module = map[currentPulse.to] else {
                        continue
                    }
                    
                    let nextPulses = module.receive(currentPulse.value, from: currentPulse.from)
                    queue.append(contentsOf: nextPulses)
                }
                
                pressed += 1
            }
            
            totals.append(highs * lows)
        }
        
        return totals
    }
    
    func part2() async throws -> Any {
        let moduleMaps = self.moduleMaps
        
        var totals: [Int] = []
        
        for var map in moduleMaps {
            let finals = map.values.filter({ $0.next.contains("rx") })
            
            guard finals.count == 1 else { continue }
            
            let final = finals.first!
            let finalFlipFlops = map.values.filter { $0.next.contains(final.name) }
            
            var finalFlipFlopCycles: [String:Int] = [:]
            var visited: [String:Int] = [:]
            
            for module in finalFlipFlops {
                visited[module.name] = 0
            }
            
            let button = Button()
            map["button"] = button
            
            let output = Output()
            map["output"] = output
            
            let conjunctionModules = map.values.compactMap { $0 as? Conjunction }
            
            for conjunctionModule in conjunctionModules {
                for outputModule in map.values {
                    if outputModule.next.contains(where: { $0 == conjunctionModule.name }) {
                        conjunctionModule.state[outputModule.name] = false
                        // print("\(outputModule.name) -> \(conjunctionModule.name)")
                    }
                }
            }
            
            var pressed = 0
            
        outer: while true {
                var queue: [Pulse] = button.receive(false, from: "")
                pressed += 1
                
                while !queue.isEmpty {
                    let currentPulse = queue.removeFirst()
                    
                    if currentPulse.to == "rx" {
                        if !currentPulse.value {
                            totals.append(pressed + 1)
                            break outer
                        } else {
                            continue
                        }
                    }
                    
                    guard let module = map[currentPulse.to] else {
                        fatalError("No target module \(currentPulse.to)")
                    }
                    
                    if currentPulse.to == final.name && currentPulse.value {
                        visited[currentPulse.from]! += 1
                        
                        if finalFlipFlopCycles[currentPulse.from] == nil {
                            finalFlipFlopCycles[currentPulse.from] = pressed
                        } else if pressed != visited[currentPulse.from]! * finalFlipFlopCycles[currentPulse.from]! {
                            fatalError("Cycle failure")
                        }
                        
                        if visited.values.allSatisfy({ $0 != 0 }) {
                            print(finalFlipFlopCycles)
                            
                            let cycles = finalFlipFlopCycles.values
                            let cycle = cycles.reduce(1, lcm)
                            
                            totals.append(cycle)
                            break outer
                        }
                    }
                    
                    let nextPulses = module.receive(currentPulse.value, from: currentPulse.from)
                    queue.append(contentsOf: nextPulses)
                }
            }
        }
        
        return totals
    }
}
