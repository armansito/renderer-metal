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
    var transform: Transform

    // Shape override:
    var triangleCount: UInt { get { 2 } }

    // Shape override:
    var triangleVertexData: ArraySlice<vector_float3> { get { self._vertices[...] } }

    private let _vertices: [vector_float3]

    init(transform: Transform) {
        self.transform = transform

        // TODO: Every instance currently stores its own set of vertex instances. A more efficient
        // scheme would only store transformations per-instance without duplicating vertex data.
        self._vertices = [
            // Triangle 1
            vector3(0.5, -0.5, 0),
            vector3(0.5, 0.5, 0),
            vector3(-0.5, -0.5, 0),

            // Triangle 2
            vector3(-0.5, -0.5, 0),
            vector3(0.5, 0.5, 0),
            vector3(-0.5, 0.5, 0)
        ];
    }
}
