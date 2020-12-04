//
//  Shape.swift
//  Renderer
//
//  Created by Arman Uguray on 6/6/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Metal

struct Transform {
    var translate: vector_float3 = vector3(0.0, 0.0, 0.0)
    var scale: Float = 1.0
    var rotate: simd_quatf = simd_quatf()
}

protocol Shape {
    // Return the number of triangles that make up this shape.
    var triangleCount: UInt { get }

    // Return the triangle vertex data that make up this shape in coordinates that are typically
    // centered at origin. Vertices must be specified in counter-clockwise order.
    var triangleVertexData: ArraySlice<vector_float3> { get }

    // The model transformation that defines the world-space coordinates of this shape.
    var transform: Transform { get set }
}

extension Shape {
    // Returns the triangle vertex data of this shape in world-space coordinates by applying the
    // linear transformation defined by `transform`.
    func transformedTriangleVertexData() -> [vector_float3] {
        return triangleVertexData.map { (v: vector_float3) -> vector_float3 in
            self.transform.rotate.act(v) * self.transform.scale + self.transform.translate
        }
    }
}
