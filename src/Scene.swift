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

    // Returns the GPU buffer that contains all the dynamic triangle vertex data in the scene.
    // Every element is a 3 dimensional vector of 32-bit floats.
    var vertexBuffer: MTLBuffer {
        get { _vertexPositions.buffer }
    }

    // Returns the GPU buffer that contains the constant uniform data. This contains a single
    // `Uniforms` instance.
    var uniformsBuffer: MTLBuffer {
        get { _uniforms.buffer }
    }

    // The GPU that this scene is being rendered on. Used to allocate GPU buffers that hold the
    // scene data.
    private let _device: MTLDevice

    // Buffer containing world-space coordinates of all vertices in the scene.
    private let _vertexPositions: Buffer<vector_float3>

    // The scene uniforms.
    private let _uniforms: Buffer<Uniforms>

    // TODO: Scene should define a vertex descriptor eventually. Attribute and buffer indices should
    //       get defined by the Scene.

    init(device: MTLDevice) throws {
        self._device = device
        self.camera = Camera()
        self.camera.lookAt(eye: vector_float3(2, 2, 2),
                            center: vector_float3(0, 0, 0),
                            up: vector_float3(0, 1, 0))

        self._vertexPositions = try Buffer<vector_float3>(device, count: 4)
        try self._vertexPositions.write(pos: 0, data: [
            vector3(0.5, -0.5, 0),
            vector3(0.5, 0.5, 0),
            vector3(-0.5, -0.5, 0),
            vector3(-0.5, 0.5, 0)
        ])

        self._uniforms = try Buffer<Uniforms>(device, count: 1)
        try updateUniforms()
    }

    func resizeViewport(width: Float, height: Float) {
        self.camera.perspective(fovY: self.camera.projection.fovy, width: width, height: height)
    }

    // Refresh the contents of the uniforms buffer.
    func updateUniforms() throws {
        var uniforms = Uniforms()
        uniforms.view = self.camera.view
        uniforms.projection = self.camera.projection
        try self._uniforms.write(pos: 0, data: [uniforms])
    }
}
