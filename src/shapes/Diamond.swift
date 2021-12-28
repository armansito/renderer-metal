//
//  Diamond.swift
//  Renderer
//
//  Created by Arman Uguray on 12/13/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Foundation

class Diamond : Geometry {
    // Shape overrides:
    let color: vector_float3
    var transform: Transform
    var triangleCount: UInt { UInt(_vertices.count) / 3 }
    var triangleVertexData: ArraySlice<Vertex> { _vertices[...] }

    private let _vertices: [Vertex]

    init(transform: Transform, color: vector_float3) {
        self.transform = transform
        self.color = color

        // TODO: Every instance currently stores its own set of vertex instances. A more efficient
        // scheme would only store transformations per-instance without duplicating vertex data.
        let rotX = simd_quatf(angle: .pi / 4, axis: vector3(-1, 0, 0))
        let baseNormal = rotX.act(vector3(0, 0, 1))
        let baseTriangle: [(vector_float3, vector_float3)] = [
            (vector3(-0.5, 0, 0.5), baseNormal),
            (vector3(0.5, 0, 0.5), baseNormal),
            (vector3(0, 0.5, 0), baseNormal),
        ]

        var vertices: [(vector_float3, vector_float3)] = []
        for angle in [0, Float.pi / 2, .pi, .pi * 3 / 2] {
            let r = simd_quatf(angle: angle, axis: vector3(0, 1, 0))
            vertices.append(contentsOf: baseTriangle.map { (p, n) in (r.act(p), r.act(n)) })
        }

        let rot180 = simd_quatf(angle: .pi, axis: vector3(0, 0, 1))
        vertices.append(contentsOf: vertices.map { (p, n) in (rot180.act(p), rot180.act(n)) })

        _vertices = vertices.map { (p, n) in Vertex(pos: p, normal: n, color: color) }
    }
}
