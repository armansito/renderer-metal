//
//  SolidColorPipeline.swift
//  Renderer
//
//  Created by Arman Uguray on 12/7/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Foundation
import Metal

class RasterPipeline: RenderPipeline {
    private let _scene: Scene
    private let _depthState: MTLDepthStencilState

    private let _solidColorState: MTLRenderPipelineState
    private let _phongState: MTLRenderPipelineState
    private var _activeState: MTLRenderPipelineState

    required init(device: MTLDevice, library: MTLLibrary,
                  settings: RenderPipelineSettings, scene: Scene) throws {
        _scene = scene
        _solidColorState = try Self.buildSolidColorPipelineState(device, library, settings)
        _phongState = try Self.buildPhongPipelineState(device, library, settings)
        _activeState = _phongState

        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .lessEqual
        depthDescriptor.isDepthWriteEnabled = true
        guard let depthState = device.makeDepthStencilState(descriptor: depthDescriptor) else {
            throw RendererError.runtimeError("failed to create depth stencil state")
        }
        _depthState = depthState
    }

    func togglePhong(_ enable: Bool) {
        _activeState = enable ? _phongState : _solidColorState
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
        defaultDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.01, green: 0.01,
                                                                         blue: 0.01, alpha: 1)
        return defaultDescriptor
    }

    private static func buildSolidColorPipelineState(
        _ device: MTLDevice, _ library: MTLLibrary, _ settings: RenderPipelineSettings
    ) throws -> MTLRenderPipelineState {
        return try Self.makeRenderPipelineState(
            device: device, library: library, settings: settings,
            vertexFunction: "vertex_default",
            fragmentFunction: "frag_solid_color",
            vertexDescriptor: nil)
    }

    private static func buildPhongPipelineState(
        _ device: MTLDevice, _ library: MTLLibrary, _ settings: RenderPipelineSettings
    ) throws -> MTLRenderPipelineState {
        return try Self.makeRenderPipelineState(
            device: device, library: library, settings: settings,
            vertexFunction: "vertex_default",
            fragmentFunction: "frag_phong",
            vertexDescriptor: nil)
    }

    private func drawShapes(encoder: MTLRenderCommandEncoder) {
        encoder.pushDebugGroup("Shapes (Debug)")
        encoder.setFrontFacing(.counterClockwise)
        encoder.setCullMode(.back)
        encoder.setTriangleFillMode(.fill)
        encoder.setRenderPipelineState(_activeState)
        encoder.setDepthStencilState(_depthState)

        // uniforms
        encoder.setVertexBuffer(_scene.uniforms.buffer, offset: 0,
                                index: BufferIndex.sceneUniforms.rawValue)
        encoder.setVertexBuffer(_scene.vertexPositions.buffer, offset: 0,
                                index: BufferIndex.vertexPositions.rawValue)

        encoder.setFragmentBuffer(_scene.uniforms.buffer, offset: 0,
                                  index: BufferIndex.sceneUniforms.rawValue)
        encoder.setFragmentBuffer(_scene.lights.buffer, offset: 0,
                                  index: BufferIndex.sceneLights.rawValue)

        // vertices
        encoder.drawPrimitives(type: .triangle,
                               vertexStart: 0, vertexCount: _scene.vertexPositions.count)

        encoder.popDebugGroup()
    }
}
