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
    // Returns the GPU buffer that contains all the dynamic triangle vertex data in the scene.
    // Every element is a 3 dimensional vector of 32-bit floats.
    var vertexBuffer: MTLBuffer {
        get {
            return self._vertexPositions.buffer
        }
    }

    // The GPU that this scene is being rendered on. Used to allocate GPU buffers that hold the
    // scene data.
    private let _device: MTLDevice

    // Buffer containing world-space coordinates of all vertices in the scene.
    private let _vertexPositions: Buffer<vector_float3>

    // TODO: Scene should define a vertex descriptor eventually. Attribute and buffer indices should
    //       get defined by the Scene.

    init(device: MTLDevice) throws {
        self._device = device
        guard let buffer = Buffer<vector_float3>(device, count: 3) else {
            throw RendererError.runtimeError("failed to create vertex buffer ")
        }
        self._vertexPositions = buffer
        self._vertexPositions.write(pos: 0, data: [
            vector3(0.5, -0.5, 0.0),
            vector3(0.0, 0.5, 0.0),
            vector3(-0.5, -0.5, 0.0)
        ])
    }
}
