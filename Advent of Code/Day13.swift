//
//  Day13.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-13.
//  SPDX-License-Identifier: MIT
//

import Foundation

struct Day13: AdventDay {
    
    struct Mirror {
        
        var data: [String]
        
        static func parse(lines: any StringProtocol) -> Mirror {
            Mirror(
                data: lines.split(separator: "\n").map { String($0) }
            )
        }
        
        var columns: [String] {
            var columns = [String](repeating: "", count: data[0].count)
            
            for line in data {
                for (index, char) in line.enumerated() {
                    columns[index].append(char)
                }
            }
            
            return columns
        }
        
        var columnReflectionPoint: Int? {
            let hashes = columns.map {
                var hasher = Hasher()
                hasher.combine($0)
                return hasher.finalize()
            }
            
            return reflectionPoint(hashes: hashes)
        }
        
        var fixedColumnReflectionPoint: Int? {
            fixedReflectionPoint(lines: columns)
        }
        
        var fixedRowReflectionPoint: Int? {
            fixedReflectionPoint(lines: rows)
        }
        
        var rows: [String] {
            data
        }
        
        var rowReflectionPoint: Int? {
            let hashes = rows.map {
                var hasher = Hasher()
                hasher.combine($0)
                return hasher.finalize()
            }
            
            return reflectionPoint(hashes: hashes)
        }
        
        private func fixedReflectionPoint(lines: [String]) -> Int? {
            for lhsIndex in 0 ..< lines.count - 1 {
                for rhsIndex in lhsIndex + 1 ..< lines.count {
                    let lhsRow = lines[lhsIndex]
                    let rhsRow = lines[rhsIndex]
                    
                    let mismatches = zip(lhsRow, rhsRow).map { $0.0 != $0.1 }
                    let totalMismatches = mismatches.filter { $0 }.count
                    
                    if totalMismatches == 1 && (rhsIndex - lhsIndex) % 2 == 1 {
                        print("Mismatch for:")
                        print("-   \(lhsRow) @ \(lhsIndex)")
                        print("-   \(rhsRow) @ \(rhsIndex)")
                        
                        var newLines = lines
                        newLines[lhsIndex] = rhsRow
                        
                        let original = reflectionPoint(hashes: lines)
                        if let value = reflectionPoint(hashes: newLines, skipping: original) {
                            return value
                        }
                    }
                }
            }
        
            return nil
        }
        
        private func reflectionPoint<T: Equatable>(hashes: [T], skipping original: Int? = nil) -> Int? {
            let matchedPairs = hashes.adjacentPairs()
                .enumerated()
                .filter { $0.offset != original }
                .filter { $0.element.0 == $0.element.1 }
                .map { $0.offset }
            
            for index in matchedPairs {
                var lhs = index
                var rhs = index + 1
                
                while hashes[lhs] == hashes[rhs] {
                    lhs -= 1
                    rhs += 1
                    
                    if lhs == -1 || rhs == hashes.count {
                        return index
                    }
                }
            }
            
            return nil
        }
    }
    
    var data: String
    
    var maps: [Mirror] {
        data.split(separator: "\n\n").map { Mirror.parse(lines: $0) }
    }
    
    func part1() async throws -> Any {
        var total = 0
        
        for map in maps {
            let columnReflectionPoint = map.columnReflectionPoint
            let rowReflectionPoint = map.rowReflectionPoint
            
            if columnReflectionPoint != nil && rowReflectionPoint != nil {
                fatalError("Map \(map) has both reflection points")
            } else if let columnReflectionPoint {
                print("Column reflection point @ \(columnReflectionPoint)")
                total += columnReflectionPoint + 1
            } else if let rowReflectionPoint {
                print("Row reflection point @ \(rowReflectionPoint)")
                total += (rowReflectionPoint + 1) * 100
            } else {
                fatalError("Map \(map) has no reflection point")
            }
        }
        
        return total
    }
    
    func part2() async throws -> Any {
        var total = 0
        
        for map in maps {
            if let reflectionPoint = map.fixedColumnReflectionPoint {
                print("Fixed column reflection point @ \(reflectionPoint)")
                total += reflectionPoint + 1
            } else if let reflectionPoint = map.fixedRowReflectionPoint {
                print("Fixed row reflection point @ \(reflectionPoint)")
                total += (reflectionPoint + 1) * 100
            } else {
                fatalError("Map \(map) has no fixable reflection point")
            }
        }
        
        return total
    }
}
