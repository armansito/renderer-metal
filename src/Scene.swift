//
//  Scene.swift
//  Renderer
//
//  Created by Arman Uguray on 4/22/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Metal

// A Scene describes the model of a 3D scene that can be supplied to a GPU pipeline for rendering.
// A Scene consists of a collection of shapes, lights, and a single camera.
class Scene {
    // The camera maps the coordinate space.
    let camera: Camera

    // The GPU buffer that contains all the dynamic triangle vertex data in the scene.
    // Every element is a 3 dimensional vector of 32-bit floats.
    // TODO: A more efficient scheme should make use of triangle strips and instanced data instead
    // of storing triangle vertices for instances in a single buffer. We represent everything in a
    // single buffer for now in preparation for MPSTriangleAccelerationStructure.
    let vertexPositions: Buffer<Vertex>

    // The GPU buffer that contains the constant uniform data. This contains a single
    // `Uniforms` instance.
    let uniforms: Buffer<Uniforms>

    // The GPU that this scene is being rendered on. Used to allocate GPU buffers that hold the
    // scene data.
    private let _device: MTLDevice

    // The shapes in the scene.
    private let _shapes: [Shape]

    init(device: MTLDevice) throws {
        _device = device
        camera = Camera()
        camera.lookAt(eye: vector_float3(0, 2, 9),
                      center: vector_float3(0, 2, 0),
                      up: vector_float3(0, 1, 0))

        _shapes = [
            // Walls
            Quad(transform: Transform(translate: vector_float3(-2, 2, 0),
                                      scale: vector_float3(4, 4, 4),
                                      rotate: simd_quatf(angle: .pi / 2, axis: vector3(0, 1, 0))),
                 color: vector_float3(1, 0, 0)),
            Quad(transform: Transform(translate: vector_float3(2, 2, 0),
                                      scale: vector_float3(4, 4, 4),
                                      rotate: simd_quatf(angle: -.pi / 2, axis: vector3(0, 1, 0))),
                 color: vector_float3(0.1, 1, 0.1)),
            Quad(transform: Transform(translate: vector_float3(0, 2, -2),
                                      scale: vector_float3(4, 4, 4)),
                 color: vector_float3(1, 1, 0.3)),
            Quad(transform: Transform(translate: vector_float3(0, 2, 2),
                                      scale: vector_float3(4, 4, 4),
                                      rotate: simd_quatf(angle: .pi, axis: vector3(0, 1, 0))),
                 color: vector_float3(0, 0, 1)),
            Quad(transform: Transform(translate: vector_float3(0, 0, 0),
                                      scale: vector_float3(4, 4, 4),
                                      rotate: simd_quatf(angle: -.pi / 2, axis: vector3(1, 0, 0))),
                 color: vector_float3(1, 1, 1)),
            Quad(transform: Transform(translate: vector_float3(0, 4, 0),
                                      scale: vector_float3(4, 4, 4),
                                      rotate: simd_quatf(angle: .pi / 2, axis: vector3(1, 0, 0))),
                 color: vector_float3(1, 1, 1)),

            // Cuboids
            Cube(transform: Transform(translate: vector_float3(-0.75, 0.5, 0),
                                      rotate: simd_quatf(angle: 0.175, axis: vector3(0, 1, 0))),
                 color: vector3(0.1, 0.1, 1)),
            Cube(transform: Transform(translate: vector_float3(0.75, 1, -1),
                                      scale: vector3(1, 2, 1),
                                      rotate: simd_quatf(angle: -.pi / 4, axis: vector3(0, 1, 0))),
                 color: vector3(0.9, 0.9, 0.9)),
        ]

        vertexPositions = try Self.allocateVertexBuffer(device, shapes: _shapes[...])
        uniforms = try Buffer<Uniforms>(device, count: 1)

        try updateUniforms()
        try updateVertexData()
    }

    func resizeViewport(width: Float, height: Float) {
        camera.perspective(fovY: camera.projection.fovy, width: width, height: height)
    }

    // Refresh the contents of the uniforms buffer.
    func updateUniforms() throws {
        var uniforms = Uniforms()
        uniforms.view = camera.view
        uniforms.projection = camera.projection
        try self.uniforms.write(pos: 0, data: [uniforms])
    }

    func updateVertexData() throws {
        var offset: UInt = 0
        for shape in _shapes {
            try vertexPositions.write(pos: offset,
                                      data: shape.transformedTriangleVertexData()[...])
            offset += shape.triangleCount * 3
        }
    }

    // Calculate the total vertex count for the scene.
    private static func allocateVertexBuffer(_ device: MTLDevice, shapes: ArraySlice<Shape>) throws -> Buffer<Vertex> {
        let count = shapes.map({ s in s.triangleCount }).reduce(0, +) * 3
        return try Buffer<Vertex>(device, count: count)
    }
}
