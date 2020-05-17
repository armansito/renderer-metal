//
//  WireframePipeline.swift
//  Renderer
//
//  Created by Arman Uguray on 5/14/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Metal

class WireframePipeline: RenderPipeline {
    private let _renderPipelineState: MTLRenderPipelineState
    private let _scene: Scene

    required init(device: MTLDevice, library: MTLLibrary,
                  settings: RenderPipelineSettings, scene: Scene) throws {
        self._renderPipelineState = try Self.makeRenderPipelineState(
            device: device, library: library, settings: settings,
            vertexFunction: "simpleVert",
            fragmentFunction: "solidColorFrag",
            vertexDescriptor: nil)
        self._scene = scene
    }

    func renderFrame(_ commandBuffer: MTLCommandBuffer,
                     viewDescriptor: MTLRenderPassDescriptor) throws {
        viewDescriptor.colorAttachments[0].loadAction = .clear
        viewDescriptor.colorAttachments[0].clearColor =
            MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: viewDescriptor) else {
                throw RendererError.runtimeError("failed to create render command encoder")
        }

        renderEncoder.label = "Wireframe Render Encoder"
        renderEncoder.pushDebugGroup("Draw Scene")
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setRenderPipelineState(self._renderPipelineState)

        // TODO: How to render connected lines for wireframe based on just Scene data?
        // TODO: Allow shapes in the scene to define how to draw themselves.
        renderEncoder.setVertexBuffer(self._scene.vertexBuffer,
                                      offset: 0, index: BufferIndex.vertexPositions.rawValue)
        renderEncoder.setVertexBuffer(self._scene.uniformsBuffer,
                                      offset:0, index: BufferIndex.uniforms.rawValue)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()
    }
}
