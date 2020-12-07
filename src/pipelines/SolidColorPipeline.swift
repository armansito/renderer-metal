//
//  SolidColorPipeline.swift
//  Renderer
//
//  Created by Arman Uguray on 12/7/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Foundation
import Metal

class SolidColorPipeline: RenderPipeline {
    private let _shapePipeline: MTLRenderPipelineState
    private let _scene: Scene

    required init(device: MTLDevice, library: MTLLibrary,
                  settings: RenderPipelineSettings, scene: Scene) throws {
        _shapePipeline = try Self.buildShapePipeline(device, library, settings)
        _scene = scene
    }

    // RenderPipeline override:
    func renderFrame(_ commandBuffer: MTLCommandBuffer,
                     viewDescriptor: MTLRenderPassDescriptor) throws {
        let renderPassDescriptor = buildDescriptor(defaultDescriptor: viewDescriptor)
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: renderPassDescriptor) else {
            throw RendererError.runtimeError("failed to create render command encoder")
        }

        renderEncoder.label = "Solod Color Pipeline"
        drawShapes(encoder: renderEncoder)
        renderEncoder.endEncoding()
    }

    private func buildDescriptor(
        defaultDescriptor: MTLRenderPassDescriptor
    ) -> MTLRenderPassDescriptor {
        defaultDescriptor.colorAttachments[0].loadAction = .clear
        defaultDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1,
                                                                         blue: 1, alpha: 1)
        return defaultDescriptor
    }

    private static func buildShapePipeline(
        _ device: MTLDevice, _ library: MTLLibrary, _ settings: RenderPipelineSettings
    ) throws -> MTLRenderPipelineState {
        return try Self.makeRenderPipelineState(
            device: device, library: library, settings: settings,
            vertexFunction: "vertex_default",
            fragmentFunction: "frag_solid_blue_color",
            vertexDescriptor: nil)
    }

    private func drawShapes(encoder: MTLRenderCommandEncoder) {
        encoder.pushDebugGroup("Shapes (Debug)")
        encoder.setFrontFacing(.counterClockwise)
        encoder.setCullMode(.back)
        encoder.setTriangleFillMode(.fill)
        encoder.setRenderPipelineState(_shapePipeline)

        encoder.setVertexBuffer(_scene.uniforms.buffer,
                                offset: 0, index: BufferIndex.uniforms.rawValue)
        encoder.setVertexBuffer(_scene.vertexPositions.buffer,
                                offset: 0, index: BufferIndex.vertexPositions.rawValue)
        encoder.drawPrimitives(type: .triangle,
                               vertexStart: 0, vertexCount: _scene.vertexPositions.count)

        encoder.popDebugGroup()
    }
}
