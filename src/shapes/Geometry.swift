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
    var scale: vector_float3 = vector_float3(1, 1, 1)
    var rotate: simd_quatf = simd_quatf()
}

protocol Geometry {
    // The color of the shape's surface material.
    // TODO: generalize this to a more comprehensive object material type and decouple it from geometry.
    var color: vector_float3 { get }

    // Return the number of triangles that make up this shape.
    var triangleCount: UInt { get }

    // Return the triangle vertex data that make up this shape in coordinates that are typically
    // centered at origin. Vertices must be specified in counter-clockwise order.
    var triangleVertexData: ArraySlice<Vertex> { get }

    // The model transformation that defines the world-space coordinates of this shape.
    var transform: Transform { get set }
}

extension Geometry {
    // Returns the triangle vertex data of this shape in world-space coordinates by applying the
    // linear transformation defined by `transform`.
    func transformedTriangleVertexData() -> [Vertex] {
        return self.triangleVertexData.map { (v: Vertex) -> Vertex in
            let p = self.transform.rotate.act(v.pos) * self.transform.scale + self.transform.translate
            let n = self.transform.rotate.act(v.normal)
            return Vertex(pos: p, normal: n, color: v.color)
        }
    }
}
