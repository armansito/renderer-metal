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

    // The Scene that is being rendered.
    private let _scene: Scene

    // The currently active render pipeline.
    private var _currentPipeline: RenderPipeline

    init?(view: MTKView) {
        view.colorPixelFormat = MTLPixelFormat.rgba16Float
        view.sampleCount = 4
        view.drawableSize = view.frame.size

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

        do {
            self._scene = try Scene(device: self._device)

            var settings = RenderPipelineSettings()
            settings.rasterSampleCount = view.sampleCount
            settings.colorPixelFormat = .rgba16Float
            self._currentPipeline = try WireframePipeline(device: self._device,
                                                          library: self._library,
                                                          settings: settings,
                                                          scene: self._scene)
        } catch {
            print("failed to construct Scene and Pipeline: \(error)")
            return nil
        }

        super.init()
    }

    private func advanceBufferingStep() {
        _currentBufferingStep = (_currentBufferingStep + 1) % RendererConstants.maxBuffersInFlight
    }
    
    // MTKViewDelegate override:
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        do {
            try self._scene.resizeViewport(width: Float(size.width),
                                           height: Float(size.height))
        } catch {
            print("failed to resize viewport: \(error)")
        }
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
        commandBuffer.addCompletedHandler { commandBuffer in
            if let error = commandBuffer.error {
                print("error executing command buffer:", error)
            }
            semaphore.signal()
        }

        let renderPassDescriptor = view.currentRenderPassDescriptor!
        do {
            try self._currentPipeline.renderFrame(commandBuffer,
                                                  viewDescriptor: renderPassDescriptor)
        } catch {
            print("pipeline failed to render frame: \(error)")
            return
        }

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}
