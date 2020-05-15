//
//  WireframePipeline.swift
//  Renderer
//
//  Created by Arman Uguray on 5/10/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Metal

// Global settings that the drawable view's has been configured with. Pipelines can use this to rely
// on the default render pass descriptor, however they are not required to do so (for example when
// rendering frames offline).
struct RenderPipelineSettings {
    // Number of samples computer per fragment during rendering stage. This can be set to a number
    // larger than 1 to enable multi-sampling effects (such as anti-aliasing) for pipelines that
    // perform their rendering using GPU rasterization (unlike ray-traced pipelines that perform
    // anti-aliasing directly in the shaders).
    var rasterSampleCount: Int = 1

    // The pixel formats assigned to the render pipeline attachments (color, depth, and stencil).
    var colorPixelFormat: MTLPixelFormat = MTLPixelFormat.invalid
    var depthPixelFormat: MTLPixelFormat = MTLPixelFormat.invalid
    var stencilPixelFormat: MTLPixelFormat = MTLPixelFormat.invalid
}

// A Render pipeline describes the operations that belong to one or more render passes.
protocol RenderPipeline {
    // The pipeline should initialize all of its resources (such as its pipeline states and buffers)
    // based on information from the scene.
    init(device: MTLDevice, library: MTLLibrary,
         settings: RenderPipelineSettings, scene: Scene) throws

    // Encode all commands that should be executed by the GPU to draw a single frame into the view.
    // The implementation should only use the commandBuffer to create command encoders. The
    // implementation should NOT modify, commit, or present the command buffer.
    //
    // `viewDescriptor` is the render pass descriptor that as pre-initialized by the MTKView that
    // owns the drawable that the frame will be rendered to. The implementation may use this to
    // construct a render encoder the configuration of which matches the RenderPipelineSettings
    // provided during initialization. Implementations are free to ignore this parameter.
    func renderFrame(_ commandBuffer: MTLCommandBuffer,
                     viewDescriptor: MTLRenderPassDescriptor) throws
}

extension RenderPipeline {
    // Helper function for constructing a render pipeline state
    static func makeRenderPipelineState(
        device: MTLDevice, library: MTLLibrary,
        settings: RenderPipelineSettings,
        vertexFunction: String, fragmentFunction: String,
        vertexDescriptor: MTLVertexDescriptor?
    ) throws -> MTLRenderPipelineState {
        // Obtain the vertex and fragment functions from the shader library.
        let vertexFunction = library.makeFunction(name: vertexFunction)
        let fragmentFunction = library.makeFunction(name: fragmentFunction)

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "RenderPipeline"
        pipelineDescriptor.rasterSampleCount = Int(settings.rasterSampleCount)
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor

        // Note: This project currently only renders to one of the color attachments.
        pipelineDescriptor.colorAttachments[0].pixelFormat = settings.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = settings.depthPixelFormat
        pipelineDescriptor.stencilAttachmentPixelFormat = settings.stencilPixelFormat

        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}
