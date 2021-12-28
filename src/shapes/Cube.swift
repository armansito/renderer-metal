//
//  Cube.swift
//  Renderer
//
//  Created by Arman Uguray on 12/3/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Foundation

// A 3D cuboid.
class Cube: Geometry {
    // Shape override:
    let color: vector_float3

    // Shape override:
    var transform: Transform

    // Shape override:
    var triangleCount: UInt { UInt(_vertices.count) / 3 }

    // Shape override:
    var triangleVertexData: ArraySlice<Vertex> { _vertices[...] }

    private let _vertices: [Vertex]

    init(transform: Transform, color: vector_float3) {
        self.transform = transform
        self.color = color

        // TODO: We currently define a cube as 6 quad faces containing 2 triangles each. This leads
        // to a lot of repetition of vertex data and a more efficient scheme could use instanced
        // data instead.
        _vertices = [
            (vector_float3(0, 0, 0.5), simd_quatf()),
            (vector_float3(0.5, 0, 0), simd_quatf(angle: .pi / 2, axis: vector3(0, 1, 0))),
            (vector_float3(0, 0, -0.5), simd_quatf(angle: .pi, axis: vector3(0, 1, 0))),
            (vector_float3(-0.5, 0, 0), simd_quatf(angle: .pi * 3 / 2, axis: vector3(0, 1, 0))),
            (vector_float3(0, -0.5, 0), simd_quatf(angle: .pi / 2, axis: vector3(1, 0, 0))),
            (vector_float3(0, 0.5, 0), simd_quatf(angle: -.pi / 2, axis: vector3(1, 0, 0))),
        ].map({ (t, r) -> [Vertex] in
            Quad(transform: Transform(translate: t, rotate: r), color: color)
                .transformedTriangleVertexData()
        }).flatMap { $0 }
    }
}
