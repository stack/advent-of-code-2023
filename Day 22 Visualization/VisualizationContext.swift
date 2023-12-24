//
//  VisualizationContext.swift
//  Day 22 Visualization
//
//  Created by Stephen H. Gerstacker on 2023-12-23.
//

import Foundation
import Utilities
import Visualization
import simd

class VisualizationContext: Solution3DContext {
    
    struct Brick: CustomDebugStringConvertible {
        var id: String = UUID().uuidString
        var color = SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
        var point1: Point3D
        var point2: Point3D
        
        func overlaps(_ other: Brick) -> Bool {
            max(point1.x, other.point1.x) <= min(point2.x, other.point2.x) &&
            max(point1.y, other.point1.y) <= min(point2.y, other.point2.y)
        }
        
        var debugDescription: String {
            "\(id): \(point1) -> \(point2)"
        }
        
        var extents: SIMD3<Float> {
            let diff = point2 - point1 + Point3D(x: 1, y: 1, z: 1)
            return SIMD3<Float>(Float(diff.x), Float(diff.z), Float(diff.y))
        }
        
        var bottomZ: Float {
            Float(point1.z)
        }
    }
    
    override var name: String {
        "Day 22"
    }
    
    var columnHeight: Float = 0.0
    var xOffset: Float = 0.0
    var yOffset: Float = 0.0
    var frameNumber: Int = 0
    
    override func run() async throws {
        let dataURL = Bundle.main.url(forResource: "Day22", withExtension: "txt")!
        let data = try String(contentsOf: dataURL)
        
        let colors = [
            SIMD4<Float>(236.0 / 255.0, 88.0 / 255.0, 88.0 / 255.0, 1.0),
            SIMD4<Float>(253.0 / 255.0, 140.0 / 255.0, 4.0 / 255.0, 1.0),
            SIMD4<Float>(237.0 / 255.0, 242.0 / 255.0, 133.0 / 255.0, 1.0),
            SIMD4<Float>(147.0 / 255.0, 171.0 / 255.0, 211.0 / 255.0, 1.0)
        ]
        
        let bricks = data.split(separator: "\n").enumerated().map { index, line in
            let parts = line.split(separator: "~").map {
                let coords = $0.split(separator: ",").map { Int($0)! }
                return Point3D(x: coords[0], y: coords[1], z: coords[2])
            }
            
            return Brick(color: colors[index % colors.count], point1: parts[0], point2: parts[1])
        }.sorted(by: { $0.point1.z < $1.point1.z })
        
        for brick in bricks {
            print("Creating box \(brick.id): \(brick.point1) - \(brick.point2) = \(brick.extents)")
            try loadBoxMesh(name: "Box \(brick.id)", extents: brick.extents, baseColor: brick.color, metallicFactor: 0.2, roughnessFactor: 0.7)
            addNode(name: "Box \(brick.id)", mesh: "Box \(brick.id)")
        }
        
        columnHeight = Float(bricks.map { $0.point2.z }.max()!)
        xOffset = Float(bricks.map { $0.point2.x }.max()!) / 2.0
        yOffset = Float(bricks.map { $0.point2.y }.max()!) / 2.0
        
        try loadTexture(name: "Grass Color", resource: "GroundGrassGreen002_COL_2K", withExtension: "jpg")
        try loadTexture(name: "Grass Bump", resource: "GroundGrassGreen002_BUMP_2K", withExtension: "jpg")
        try loadTexture(name: "Grass Normal", resource: "GroundGrassGreen002_NRM_2K", withExtension: "jpg")
        try loadPlaneMesh(name: "Floor", extents: SIMD3<Float>(20, 0, 20), baseColorTexture: "Grass Color", roughnessFactor: 0.1, normalTexture: "Grass Normal")
        
        let lightIntensity: Float = 110.0
        let lightDistance = xOffset + 5
        
        addNode(name: "Floor", mesh: "Floor")
        updateNode(name: "Floor", transform: simd_float4x4(rotateAbout: SIMD3<Float>(0.0, 1.0, 0.0), byAngle: .pi))
        
        let lightStep: Float = 20.0
        var lightPosition: Float = 5.0
        
        while lightPosition < columnHeight {
            addPointLight(name: "Point 1 \(lightPosition)", color: SIMD3<Float>(1, 1, 1), intensity: lightIntensity)
            updateLight(name: "Point 1 \(lightPosition)", transform: simd_float4x4(translate: SIMD3<Float>(lightDistance, lightPosition, -lightDistance)))
            
            addPointLight(name: "Point 2 \(lightPosition)", color: SIMD3<Float>(1, 1, 1), intensity: lightIntensity)
            updateLight(name: "Point 2 \(lightPosition)", transform: simd_float4x4(translate: SIMD3<Float>(lightDistance, lightPosition, lightDistance)))
            
            addPointLight(name: "Point 3 \(lightPosition)", color: SIMD3<Float>(1, 1, 1), intensity: lightIntensity)
            updateLight(name: "Point 3 \(lightPosition)", transform: simd_float4x4(translate: SIMD3<Float>(-lightDistance, lightPosition, -lightDistance)))
            
            addPointLight(name: "Point 4 \(lightPosition)", color: SIMD3<Float>(1, 1, 1), intensity: lightIntensity)
            updateLight(name: "Point 4 \(lightPosition)", transform: simd_float4x4(translate: SIMD3<Float>(-lightDistance, lightPosition, lightDistance)))
            
            lightPosition += lightStep
        }
        
        var movingBricks = bricks
        
        for (index, brick) in movingBricks.enumerated() {
            var targetZ = 1
            
            for otherBrick in movingBricks[..<index] {
                if brick.overlaps(otherBrick) {
                    targetZ = max(targetZ, otherBrick.point2.z + 1)
                }
            }
            
            let distance = brick.point1.z - targetZ
            print("- Moving \(brick.id) by \(distance)")
            
            if distance > 0 {
                try render(bricks: movingBricks, movingBrick: brick.id, distance: distance)
            }
            
            movingBricks[index].point2.z -= brick.point1.z - targetZ
            movingBricks[index].point1.z = targetZ
        }
        
        for _ in 0 ..< 180 {
            for brick in movingBricks {
                let translate = brick.extents * 0.5 +
                    SIMD3<Float>(Float(brick.point1.x), Float(brick.point1.z - 1), Float(brick.point1.y)) -
                    SIMD3<Float>(xOffset, 0.0, yOffset)
                updateNode(name: "Box \(brick.id)", transform: simd_float4x4(translate: translate))
            }
            
            updateCameraAndLights(frameNumber: frameNumber)
            
            try snapshot()
            
            frameNumber += 1
        }
    }
    
    private func render(bricks: [Brick], movingBrick: String, distance: Int) throws {
        let secondsPerFrame = 1.0 / Float(frameRate)
        let animationTime = timeForDistance(Float(distance))
        
        var offset: Float = 0.0
        while offset < animationTime {
            let fallDistance = distanceForTime(offset)
            
            for brick in bricks {
                var translate = brick.extents * 0.5 +
                    SIMD3<Float>(Float(brick.point1.x), Float(brick.point1.z - 1), Float(brick.point1.y)) -
                    SIMD3<Float>(xOffset, 0.0, yOffset)
                
                if brick.id == movingBrick {
                    translate -= SIMD3<Float>(0.0, fallDistance, 0.0)
                }
                
                updateNode(name: "Box \(brick.id)", transform: simd_float4x4(translate: translate))
            }
            
            updateCameraAndLights(frameNumber: frameNumber)
            
            try snapshot()
            
            frameNumber += 1
            offset += secondsPerFrame
        }
    }
    
    private func timeForDistance(_ distance: Float) -> Float {
        sqrt((2.0 * distance) / 9.807)
    }

    private func distanceForTime(_ time: Float) -> Float {
        0.5 * 9.807 * (time * time)
    }
    
    private func updateCameraAndLights(frameNumber: Int) {
        let cameraRadius = Float(60.0)
        let angle = (Float(2.0) * .pi) * (Float(frameNumber) / (Float(self.frameRate) * 60.0))
        let cameraPosition = SIMD3<Float>(cameraRadius * cos(angle), (columnHeight / 3.0) + 2.0, cameraRadius * sin(angle))
        updateCamera(eye: cameraPosition, lookAt: SIMD3<Float>(0, columnHeight / 5, 0), up: SIMD3<Float>(0, 1, 0))
    }
}
