//
//  Cube.swift
//  Renderer
//
//  Created by Arman Uguray on 12/3/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Foundation

// A 3D cuboid.
class Cube: Shape {
    // Shape override:
    var transform: Transform

    // Shape override:
    var triangleCount: UInt { UInt(_vertices.count) / 3 }

    // Shape override:
    var triangleVertexData: ArraySlice<vector_float3> { _vertices[...] }

    private let _vertices: [vector_float3]

    init(transform: Transform) {
        self.transform = transform
        var vertices: [vector_float3] = []

        // TODO: We currently define a cube as 6 quad faces containing 2 triangles each. This leads
        // to a lot of repetition of vertex data and a more efficient scheme could use instanced
        // data instead.
        let transforms: [(vector_float3, simd_quatf)] = [
            (vector3(0, 0, 0.5), simd_quatf()),
            (vector3(0.5, 0, 0), simd_quatf(angle: .pi / 2, axis: vector3(0, 1, 0))),
            (vector3(0, 0, -0.5), simd_quatf(angle: .pi, axis: vector3(0, 1, 0))),
            (vector3(-0.5, 0, 0), simd_quatf(angle: .pi * 3 / 2, axis: vector3(0, 1, 0))),
            (vector3(0, -0.5, 0), simd_quatf(angle: .pi / 2, axis: vector3(1, 0, 0))),
            (vector3(0, 0.5, 0), simd_quatf(angle: -.pi / 2, axis: vector3(1, 0, 0))),
        ]

        for (t, r) in transforms {
            let quad = Quad(transform: Transform(translate: t, scale: 1, rotate: r))
            vertices.append(contentsOf: quad.transformedTriangleVertexData())
        }

        _vertices = vertices
    }
}
