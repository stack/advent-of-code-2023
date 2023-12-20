//
//  Day19.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-19.
//  SPDX-License-Identifier: MIT
//

import Foundation

extension ClosedRange<Int> {
    
    func intersection(_ other: ClosedRange<Int>) -> ClosedRange<Int> {
        if other.lowerBound > upperBound || lowerBound > other.upperBound {
            return 0 ... 0
        } else {
            let lhs = Swift.max(lowerBound, other.lowerBound)
            let rhs = Swift.min(upperBound, other.upperBound)
            
            return lhs ... rhs
        }
    }
}

struct Day19: AdventDay {
    
    enum Condition {
        case lessThan(String,Int,String)
        case greaterThan(String,Int,String)
        case goto(String)
    }
    
    struct Workflow {
        var name: String
        var conditions: [Condition]
        
        func process(part: [String:Int]) -> String {
            for condition in conditions {
                switch condition {
                case .lessThan(let variable, let value, let target):
                    if part[variable]! < value {
                        return target
                    }
                case .greaterThan(let variable, let value, let target):
                    if part[variable]! > value {
                        return target
                    }
                case .goto(let target):
                    return target
                }
            }
            
            fatalError("Workflow ended without a result")
        }
    }
    
    enum NodeOperator {
        case lessThan(Int)
        case greaterThan(Int)
    }
    
    struct NodeCondition {
        var op: NodeOperator
        var index: Int
    }
    
    class Node {
        let name: String
        var children: [(NodeCondition?, Node)]
        
        init(name: String) {
            self.name = name
            self.children = []
        }
        
        func examine(_ ranges: [ClosedRange<Int>]) -> Int {
            guard name != "R" else { return 0 }
            guard name != "A" else {
                return ranges.reduce(1) { $0 * ($1.upperBound - $1.lowerBound + 1) }
            }
            
            var currentRanges = ranges
            var total = 0
            
            for child in children {
                if let condition = child.0 {
                    let range = currentRanges[condition.index]
                    
                    switch condition.op {
                    case .lessThan(let value):
                        let includedRange = range.lowerBound ... value - 1
                        let excludedRange = value ... range.upperBound
                        
                        currentRanges[condition.index] = includedRange
                        total += child.1.examine(currentRanges)
                        
                        currentRanges[condition.index] = excludedRange
                    case .greaterThan(let value):
                        let includedRange = value + 1 ... range.upperBound
                        let excludedRange = range .lowerBound ... value
                        
                        currentRanges[condition.index] = includedRange
                        total += child.1.examine(currentRanges)
                        
                        currentRanges[condition.index] = excludedRange
                    }
                } else {
                    total += child.1.examine(currentRanges)
                }
            }
            
            return total
        }
    }

    var data: String
    
    var parts: [[String:Int]] {
        data
            .split(separator: "\n\n")[1]
            .split(separator: "\n")
            .map {
                var result: [String:Int] = [:]
                
                for match in $0.matches(of: /([a-z])=(\d+)/) {
                    result[String(match.output.1)] = Int(match.output.2)!
                }
                
                return result
            }
    }
    
    var workflows: [String:Workflow] {
        let workflows = data
            .split(separator: "\n\n")[0]
            .split(separator: "\n")
            .map {
                let match = $0.firstMatch(of: /^([a-z]+)\{(.+)\}$/)!
                let name = String(match.output.1)
                let conditions = match.output.2.split(separator: ",").map {
                    if let match = $0.firstMatch(of: /^([a-z]+)([<>])(\d+):([a-zA-Z]+)/) {
                        let variable = String(match.output.1)
                        let amount = Int(match.output.3)!
                        let target = String(match.output.4)
                        
                        if match.output.2 == "<" {
                            return Condition.lessThan(variable, amount, target)
                        } else {
                            return Condition.greaterThan(variable, amount, target)
                        }
                    } else {
                        return Condition.goto(String($0))
                    }
                }
                
                return Workflow(name: name, conditions: conditions)
            }
        
        var result: [String:Workflow] = [:]
        
        for workflow in workflows {
            result[workflow.name] = workflow
        }
        
        return result
    }
    
    func part1() async throws -> Any {
        let workflows = self.workflows
        
        var total: Int = 0
        
        for part in parts {
            var target = "in"
            
            while target != "R" && target != "A" {
                let workflow = workflows[target]!
                target = workflow.process(part: part)
            }
            
            if target == "A" {
                total += part.values.reduce(0, +)
            }
        }
        
        return total
    }
    
    func part2() async throws -> Any {
        var nodes: [String:Node] = [:]
        
        for name in workflows.keys {
            nodes[name] = Node(name: name)
        }
        
        nodes["A"] = Node(name: "A")
        nodes["R"] = Node(name: "R")
        
        for workflow in workflows.values {
            let node = nodes[workflow.name]!
            
            for condition in workflow.conditions {
                switch condition {
                case .lessThan(let variable, let value, let target):
                    node.children.append((NodeCondition(op: .lessThan(value), index: variableToIndex(variable)), nodes[target]!))
                case .greaterThan(let variable, let value, let target):
                    node.children.append((NodeCondition(op: .greaterThan(value), index: variableToIndex(variable)), nodes[target]!))
                case .goto(let target):
                    node.children.append((nil, nodes[target]!))
                }
            }
        }
        
        let startRange = 1...4000
        let startData = [ClosedRange<Int>](repeating: startRange, count: 4)
        let startNode = nodes["in"]!
        
        return startNode.examine(startData)
    }
    
    private func variableToIndex(_ variable: String) -> Int {
        switch variable {
        case "a":
            return 0
        case "m":
            return 1
        case "s":
            return 2
        case "x":
            return 3
        default:
            fatalError("Unsupported variable: \(variable)")
        }
    }
}
