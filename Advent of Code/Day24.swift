//
//  Day24.swift
//  Advent of Code
//
//  Created by Stephen H. Gerstacker on 2023-12-30.
//

import Accelerate
import Foundation

struct Day24: AdventDay {
    
    struct Hailstone: CustomDebugStringConvertible {
        var position: SIMD3<Int>
        var velocity: SIMD3<Int>
        
        var rawDescription: String {
            "{ \(position.x), \(position.y), \(position.z) } @ { \(velocity.x), \(velocity.y), \(velocity.z) }"
        }
        
        var debugDescription: String {
            rawDescription
        }
    }
    
    var data: String
    
    var hailstones: [Hailstone] {
        data.split(separator: "\n").map {
            let parts = $0.split(separator: " @ ")
            let lhs = parts[0].split(separator: ",").map { Int($0.trimmingCharacters(in: .whitespaces))! }
            let rhs = parts[1].split(separator: ",").map { Int($0.trimmingCharacters(in: .whitespaces))! }
            
            return Hailstone(
                position: SIMD3<Int>(lhs[0], lhs[1], lhs[2]),
                velocity: SIMD3<Int>(rhs[0], rhs[1], rhs[2])
            )
        }
    }
    
    func part1() async throws -> Any {
        let hailstones = self.hailstones
        
        let minValue: Double = hailstones.count == 5 ? 7 : 200000000000000
        let maxValue: Double = hailstones.count == 5 ? 27 : 400000000000000
        
        var intersections = 0
        
        for (index, lhs) in hailstones.enumerated() {
            for rhs in hailstones[(index + 1)...] {
                let a1 = Float(lhs.velocity.y)
                let b1 = Float(-lhs.velocity.x)
                let c1 = Float(lhs.velocity.y * lhs.position.x - lhs.velocity.x * lhs.position.y)
                
                let a2 = Float(rhs.velocity.y)
                let b2 = Float(-rhs.velocity.x)
                let c2 = Float(rhs.velocity.y * rhs.position.x - rhs.velocity.x * rhs.position.y)
                
                let aValues = [
                    a1, a2,
                    b1, b2,
                ]
                
                let bValues = [c1, c2]
                
                guard let result = nonsymmetric_general(a: aValues, dimension: 2, b: bValues, rightHandSideCount: 1)?.map({ Double($0) }) else {
                    continue
                }
                
                guard result[0] >= minValue && result[0] <= maxValue else { continue }
                guard result[1] >= minValue && result[1] <= maxValue else { continue }
                
                guard (result[0] - Double(lhs.position.x)) * Double(lhs.velocity.x) >= 0 else { continue }
                guard (result[1] - Double(lhs.position.y)) * Double(lhs.velocity.y) >= 0 else { continue }
                guard (result[0] - Double(rhs.position.x)) * Double(rhs.velocity.x) >= 0 else { continue }
                guard (result[1] - Double(rhs.position.y)) * Double(rhs.velocity.y) >= 0 else { continue }
                
                print("Intersection @ \(result[0]), \(result[1]))")
                print("- \(lhs.rawDescription)")
                print("- \(rhs.rawDescription)")
                
                intersections += 1
            }
        }
        
        return intersections
    }
}

/// Returns the _x_ in _Ax = b_ for a nonsquare coefficient matrix using `sgesv_`.
///
/// - Parameter a: The matrix _A_ in _Ax = b_ that contains `dimension * dimension`
/// elements.
/// - Parameter dimension: The order of matrix _A_.
/// - Parameter b: The matrix _b_ in _Ax = b_ that contains `dimension * rightHandSideCount`
/// elements.
/// - Parameter rightHandSideCount: The number of columns in _b_.
///
/// The function specifies the leading dimension (the increment between successive columns of a matrix)
/// of matrices as their number of rows.

/// - Tag: nonsymmetric_general
func nonsymmetric_general(a: [Float],
                          dimension: Int,
                          b: [Float],
                          rightHandSideCount: Int) -> [Float]? {
    
    var info: __LAPACK_int = 0
    
    /// Create a mutable copy of the right hand side matrix _b_ that the function returns as the solution matrix _x_.
    var x = b
    
    /// Create a mutable copy of `a` to pass to the LAPACK routine. The routine overwrites `mutableA`
    /// with the factors `L` and `U` from the factorization `A = P * L * U`.
    var mutableA = a
    
    var ipiv = [__LAPACK_int](repeating: 0, count: dimension)
    
    /// Call `sgesv_` to compute the solution.
    withUnsafePointer(to: __LAPACK_int(dimension)) { n in
        withUnsafePointer(to: __LAPACK_int(rightHandSideCount)) { nrhs in
            sgesv_(n,
                   nrhs,
                   &mutableA,
                   n,
                   &ipiv,
                   &x,
                   n,
                   &info)
        }
    }
    
    if info != 0 {
        // NSLog("nonsymmetric_general error \(info)")
        return nil
    }
    return x
}
