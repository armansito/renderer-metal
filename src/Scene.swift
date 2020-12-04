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
    let vertexPositions: Buffer<vector_float3>

    // The GPU buffer that contains the constant uniform data. This contains a single
    // `Uniforms` instance.
    let uniforms: Buffer<Uniforms>

    // The GPU that this scene is being rendered on. Used to allocate GPU buffers that hold the
    // scene data.
    private let _device: MTLDevice

    // The shapes in the scene.
    private let _shapes: [Shape]

    init(device: MTLDevice) throws {
        self._device = device
        self.camera = Camera()
        self.camera.lookAt(eye: vector_float3(2, 2, 2),
                           center: vector_float3(0, 0, 0),
                           up: vector_float3(0, 1, 0))

        self._shapes = [Cube(transform: Transform())]

        self.vertexPositions = try Self.allocateVertexBuffer(device, shapes: self._shapes[...])
        self.uniforms = try Buffer<Uniforms>(device, count: 1)

        try updateUniforms()
        try updateVertexData()
    }

    func resizeViewport(width: Float, height: Float) {
        self.camera.perspective(fovY: self.camera.projection.fovy, width: width, height: height)
    }

    // Refresh the contents of the uniforms buffer.
    func updateUniforms() throws {
        var uniforms = Uniforms()
        uniforms.view = self.camera.view
        uniforms.projection = self.camera.projection
        try self.uniforms.write(pos: 0, data: [uniforms])
    }

    func updateVertexData() throws {
        var offset: UInt = 0
        for shape in self._shapes {
            try self.vertexPositions.write(pos: offset,
                                           data: shape.transformedTriangleVertexData()[...])
            offset += shape.triangleCount * 3
        }
    }

    // Calculate the total vertex count for the scene.
    private static func allocateVertexBuffer(_ device: MTLDevice, shapes: ArraySlice<Shape>) throws -> Buffer<vector_float3> {
        let count = shapes.map({ s in s.triangleCount }).reduce(0, +) * 3
        return try Buffer<vector_float3>(device, count: count)
    }
}
