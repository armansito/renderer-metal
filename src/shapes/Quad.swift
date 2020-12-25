//
//  Plane.swift
//  Renderer
//
//  Created by Arman Uguray on 12/3/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Foundation

// A square segment of the XY plane centered at the origin with unit length sides. The surface
// normal points in the +Z direction.
class Quad: Shape {
    // Shape override:
    let color: vector_float3

    // Shape override:
    var transform: Transform

    // Shape override:
    var triangleCount: UInt { 2 }

    // Shape override:
    var triangleVertexData: ArraySlice<Vertex> { _vertices[...] }

    private let _vertices: [Vertex]

    init(transform: Transform, color: vector_float3) {
        self.transform = transform
        self.color = color

        // TODO: Every instance currently stores its own set of vertex instances. A more efficient
        // scheme would only store transformations per-instance without duplicating vertex data.
        let posNormal: [(vector_float3, vector_float3)] = [
            // Triangle 1
            (vector3(0.5, -0.5, 0), vector3(0, 0, 1)),
            (vector3(0.5, 0.5, 0), vector3(0, 0, 1)),
            (vector3(-0.5, -0.5, 0), vector3(0, 0, 1)),

            // Triangle 2
            (vector3(-0.5, -0.5, 0), vector3(0, 0, 1)),
            (vector3(0.5, 0.5, 0), vector3(0, 0, 1)),
            (vector3(-0.5, 0.5, 0), vector3(0, 0, 1)),
        ]
        _vertices = posNormal.map { (p, n) in Vertex(pos: p, normal: n, color: color) }
    }
}
