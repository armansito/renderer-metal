//
//  Renderer.swift
//  Renderer
//
//  Created by Arman Uguray on 4/17/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Metal
import MetalKit

struct RendererConstants {
    // We use a Triple Buffering approach to synchronize access to shared buffers between
    // the CPU and the GPU. With the current setting, the CPU will be at most 2 frames ahead of the
    // GPU.
    static let maxBuffersInFlight = 3;
}

class Renderer: NSObject, MTKViewDelegate {
    // Handle to the GPU that this Renderer was initialized with. All work is performed on the same
    // GPU.
    private let _device: MTLDevice

    // The cmmand queue for the current GPU.
    private let _commandQueue: MTLCommandQueue

    // The default shader libary of this app.
    private let _library: MTLLibrary

    // Semaphore used to limit the number of in-flight draw calls.
    private let _drawSemaphore = DispatchSemaphore(value: RendererConstants.maxBuffersInFlight)

    // The frame in the triple-buffering sequence used to index shared buffer regions.
    private var _currentBufferingStep = 0

    init?(view: MTKView) {
        view.colorPixelFormat = MTLPixelFormat.rgba16Float
        view.sampleCount = 1

        self._device = view.device!
        guard let queue = self._device.makeCommandQueue() else {
            print("failed to initialize command queue")
            return nil
        }
        guard let library = self._device.makeDefaultLibrary() else {
            print("failed to initialize shader library")
            return nil
        }

        self._commandQueue = queue
        self._library = library

        super.init()
    }

    private func advanceBufferingStep() {
        _currentBufferingStep = (_currentBufferingStep + 1) % RendererConstants.maxBuffersInFlight
    }
    
    // MTKViewDelegate override:
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO
    }
    
    // MTKViewDelegate override:
    func draw(in view: MTKView) {
        _ = _drawSemaphore.wait(timeout: DispatchTime.distantFuture)

        guard let commandBuffer = _commandQueue.makeCommandBuffer() else {
            print("faield to create command buffer for draw call")
            return
        }

        // Binding to capture the semaphore in the callback.
        let semaphore = _drawSemaphore
        commandBuffer.addCompletedHandler{ _ in semaphore.signal() }

        // TODO: move this out to its own special scene
        let renderPassDescriptor = view.currentRenderPassDescriptor!
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 0.0, 0.0, 0.1)
        if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
            renderEncoder.label = "Clear Color Pass"
            renderEncoder.endEncoding()
        }
        commandBuffer.present(view.currentDrawable!)

        commandBuffer.commit()
    }
}
