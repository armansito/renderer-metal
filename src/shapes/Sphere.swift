//
//  Sphere.swift
//  Renderer
//
//  Created by Arman Uguray on 3/15/21.
//  Copyright © 2021 Arman Uguray. All rights reserved.
//

import Foundation

class Sphere: Geometry {
    // Shape overrides:
    let color: vector_float3
    var transform: Transform
    var triangleCount: UInt { UInt(_vertices.count) / 3 }
    var triangleVertexData: ArraySlice<Vertex> { _vertices[...] }

    private let MERIDIANS = 48
    private let PARALLELS = 48
    private let _vertices: [Vertex]

    init(transform: Transform, color: vector_float3) {
        self.color = color
        self.transform = transform

        var vertices: [(vector_float3, vector_float3)] = []

        // Tesselate a unit sphere (diameter = 1) by iterating over polar coordinates and drawing a
        // meridianIncrement x parallelIncrement sized square patch at each coordinate.
        let radius: Float = 0.5
        let meridianIncrement = 2.0 * Float.pi / Float(MERIDIANS)
        let parallelIncrement = Float.pi / Float(PARALLELS)
        for vRadians in stride(from: Float.pi / 2, to: -Float.pi / 2, by: -parallelIncrement) {
            let hProj0 = radius * cos(vRadians)
            let hProj1 = radius * cos(vRadians - parallelIncrement)
            let y0 = radius * sin(vRadians)
            let y1 = radius * sin(vRadians - parallelIncrement)
            for hRadians in stride(from: 0, to: 2.0 * Float.pi, by: meridianIncrement) {
                let x0 = cos(hRadians)
                let z0 = -sin(hRadians)
                let x1 = cos(hRadians + meridianIncrement)
                let z1 = -sin(hRadians + meridianIncrement)

                // p0 - p1
                // |  \ |
                // p2 - p3
                //
                // Use the corner points as the normal vectors to approximate a curved surface via
                // linear interpolation during shading. The sphere is centered at the origin and the
                // point vectors are radius-sized (0.5) so multiplying each by 2.0 gives a
                // unit vector.
                let p0 = vector_float3(hProj0 * x0, y0, hProj0 * z0)
                let p1 = vector_float3(hProj0 * x1, y0, hProj0 * z1)
                let p2 = vector_float3(hProj1 * x0, y1, hProj1 * z0)
                let p3 = vector_float3(hProj1 * x1, y1, hProj1 * z1)
                vertices.append(contentsOf: [
                    (p0, 2.0 * p0),
                    (p2, 2.0 * p2),
                    (p3, 2.0 * p3),

                    (p3, 2.0 * p3),
                    (p1, 2.0 * p1),
                    (p0, 2.0 * p0),
                ])
            }
        }

        _vertices = vertices.map { p, n in Vertex(pos: p, normal: n, color: color) }
    }
}
