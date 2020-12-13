//
//  WireframePipeline.swift
//  Renderer
//
//  Created by Arman Uguray on 5/14/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Metal

class DebugPipeline: RenderPipeline {
    private let _shapePipeline: MTLRenderPipelineState
    private let _scene: Scene

    // Render pipeline to draw an infinite horizontal grid.
    private let _gridVertices: Buffer<Vertex>
    private let _gridPipeline: MTLRenderPipelineState

    required init(device: MTLDevice, library: MTLLibrary,
                  settings: RenderPipelineSettings, scene: Scene) throws {
        _shapePipeline = try Self.buildShapePipeline(device, library, settings)
        _gridPipeline = try Self.buildGridPipeline(device, library, settings)
        _gridVertices = try Self.buildGridVertices(device)
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

        renderEncoder.label = "Debug Pipeline"
        drawCoordinateGrid(encoder: renderEncoder)
        drawShapes(encoder: renderEncoder)
        renderEncoder.endEncoding()
    }

    private func buildDescriptor(
        defaultDescriptor: MTLRenderPassDescriptor
    ) -> MTLRenderPassDescriptor {
        defaultDescriptor.colorAttachments[0].loadAction = .load
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
            fragmentFunction: "frag_solid_red_color",
            vertexDescriptor: nil)
    }

    private static func buildGridPipeline(
        _ device: MTLDevice, _ library: MTLLibrary, _ settings: RenderPipelineSettings
    ) throws -> MTLRenderPipelineState {
        return try Self.makeRenderPipelineState(
            device: device, library: library, settings: settings,
            vertexFunction: "vertex_infinite_grid",
            fragmentFunction: "frag_solid_color",
            vertexDescriptor: nil)
    }

    private static func buildGridVertices(_ device: MTLDevice) throws -> Buffer<Vertex> {
        let span = 20
        // Total number of lines in one dimension
        let lineCount = span * 2 + 1
        let vertexCount = lineCount * 4
        let buffer = try Buffer<Vertex>(device, count: UInt(vertexCount))
        var vertices = [vector_float3]()
        vertices.reserveCapacity(vertexCount)

        for i in 0 ..< lineCount {
            let x = Float(span)
            let z = Float(i - span)
            vertices.append(vector_float3(x, 0, z))
            vertices.append(vector_float3(-x, 0, z))
        }
        for i in 0 ..< lineCount {
            let z = Float(span)
            let x = Float(i - span)
            vertices.append(vector_float3(x, 0, z))
            vertices.append(vector_float3(x, 0, -z))
        }

        try buffer.write(pos: 0, data: vertices.map { (p: vector_float3) -> Vertex in
            Vertex(pos: p, normal: vector_float3(0, 1, 0), color: vector_float3(0.8, 0.2, 0.2))
        }[...])

        return buffer
    }

    private func drawShapes(encoder: MTLRenderCommandEncoder) {
        encoder.pushDebugGroup("Shapes (Debug)")
        encoder.setFrontFacing(.counterClockwise)
        encoder.setCullMode(.none)
        encoder.setTriangleFillMode(.lines)
        encoder.setRenderPipelineState(_shapePipeline)

        encoder.setVertexBuffer(_scene.uniforms.buffer,
                                offset: 0, index: BufferIndex.uniforms.rawValue)
        encoder.setVertexBuffer(_scene.vertexPositions.buffer,
                                offset: 0, index: BufferIndex.vertexPositions.rawValue)
        encoder.drawPrimitives(type: .triangle,
                               vertexStart: 0, vertexCount: _scene.vertexPositions.count)

        encoder.popDebugGroup()
    }

    private func drawCoordinateGrid(encoder: MTLRenderCommandEncoder) {
        encoder.pushDebugGroup("Coordinate Grid")
        encoder.setRenderPipelineState(_gridPipeline)

        encoder.setVertexBuffer(_scene.uniforms.buffer,
                                offset: 0, index: BufferIndex.uniforms.rawValue)
        encoder.setVertexBuffer(_gridVertices.buffer,
                                offset: 0, index: BufferIndex.vertexPositions.rawValue)
        encoder.drawPrimitives(type: .line,
                               vertexStart: 0, vertexCount: _gridVertices.count)

        encoder.popDebugGroup()
    }
}
